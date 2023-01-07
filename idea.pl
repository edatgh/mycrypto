#!/usr/bin/perl -w
#
#   IDEA algorithm implementation
#
#   Edvardas Ges
#   VU MIF
#   Kompiuteriu Mokslas
#   III kursas, 8 gr.
#



#use bigint;

#
#   Reads a string from stdin, removes leading new-line
#
#   Input:  msg
#   Output: string
#
sub input_str {

    my $msg = $_[0];

    print("$msg");
    my $str = <STDIN>;
    chomp($str);

    return $str;
}

#
#   Converts each block of bits into decimal number
#
#   Input:  array of bit blocks
#   Output: array of decimal numbers
#
sub bin2code {

    my @bits = @_;
    my $d = 0;

    my $n = $#bits + 1;

    for (my $i = 0; $i < $n; $i++) {
	$d = $d + $bits[$i] * (1 << ($n - $i - 1));
    }

    return $d;
}

#
#   Converts ASCII string to binary representation and
#   splits the array of bits into k-length blocks.
#
#   Input:  k, ASCII string
#   Output: array of k-length binary strings
#
sub ascii2bin {

    (my $k, my $str) = (@_);
    my @bin_str = ();

    for (my $i = 0; $i < length($str); $i++) {

	my $sc = ord(substr($str, $i, 1)); # ASCII code of the symbol
	my $bits = sprintf("%08b", $sc);   # binary representation of the code
	push(@bin_str, split(//,$bits));   # add the binary rep. to the array

    }

    my @blocks = ();

    my $len = int(($#bin_str + 1) / $k);

    for ( my $i = 0; $i < $len; $i++) {

	my @block = (); # (re)define array, those (re)makeing it empty

	for (my $j = 0; $j < $k; $j++) {

	    push(@block, shift(@bin_str));

	}

	push(@blocks, [@block]);
    }

    return @blocks;
}

#
#   Finds x^-1 mod n
#
#   Input:  x, n
#   Output: x^-1 mod n, or 0 - if non-existing
#
sub inverse {

    (my $x, my $n) = @_;

    (my $x1, my $x2, my $x3) = (1, 0, $n);
    (my $y1, my $y2, my $y3) = (0, 1, $x);

    my $q = 0;
    (my $t1, my $t2, my $t3) = (0, 0, 0);

    while (1) {

	if ($y3 == 0) {

	    return 0;

	} # not found

	if ($y3 == 1) {

	    if ($y2 < 0) {

		if (-$y2 < $n) {
		    $y2 = $y2 + $n;
		} else {
		    my $n_part = (-$y2) % $n;
		    $y2 = $y2 + ($n_part + 1) * $n;
		}
	    }

	    return $y2;

	}

	$q = int($x3 / $y3);

	($t1, $t2, $t3) = ($x1 - $q * $y1, $x2 - $q * $y2, $x3 - $q * $y3);
	($x1, $x2, $x3) = ($y1, $y2, $y3);
	($y1, $y2, $y3) = ($t1, $t2, $t3);

    }

}

#
#   Circular left shift by 25 (see IDEA description)
#
#   Input:  128-bit array
#   Output: ROL(array, 25)
sub rol25 {
    my @key = @_;
    my $bit = 0;

    for (my $i = 0; $i < 25; $i++) {

	$bit = $key[0]; #   save the last bit

	#
	#   Shift
	#
	for (my $j = 0; $j <= 126; $j++) {
	    $key[$j] = $key[$j + 1];
	}

	$key[127] = $bit;
    }
}

#
#
#
sub generate_dsubkeys {
    my @subkeys = @_;
    my @dsubkeys = ();

    $dsubkeys[0] = inverse($subkeys[48], 65537);
    $dsubkeys[1] = (65536-$subkeys[49]) % 65536;
    $dsubkeys[2] = (65536-$subkeys[50]) % 65536;
    $dsubkeys[3] = inverse($subkeys[51], 65537);

    my $x = 4;
    my $y = 46;

    for (my $i = 0; $i < 8; $i++) {
	$dsubkeys[$x]     = $subkeys[$y];
	$dsubkeys[$x + 1] = $subkeys[$y + 1];

	$dsubkeys[$x + 2] = inverse($subkeys[$y - 4], 65537);
	$dsubkeys[$x + 3] = (-$subkeys[$y - 2]) % 65536;
	$dsubkeys[$x + 4] = (-$subkeys[$y - 3]) % 65536;
	$dsubkeys[$x + 5] = inverse($subkeys[$y - 1], 65537);

	$x += 6;
	$y -= 6;
    }

    return @dsubkeys;
}

#
#   Input:  128-bit array (IDEA key)
#   Output: array with 52 generated subkeys
#
sub generate_subkeys {
    my @key = @_;     #   take the 128-bit key from argument

    my @subkeys = (); #   number array
    my @subkey = ();  #   16-bit array

    my $nr_keys = 0;

    for (my $i = 0; $i < 52; $i += 8) {
	for (my $j = 0; $j <= 112; $j += 16) {
	    for (my $k = 0; $k < 16; $k++) {
		$subkey[$k] = $key[$j + $k];
	    }
	    my $code = bin2code(@subkey);
	    push(@subkeys, $code);
	    $nr_keys = $i + $j / 16 + 1;
#	    print("Subkey $nr_keys generated.\n");
	    if ($nr_keys == 52) {
		$i = 52;
		last;
	    }
	}
	rol25(@key);
    }

    return @subkeys;
}

#
#   Input:  p1, p2, p3, p4, s1, s2, s3, s4, s5, s6
#   Output: dx1, dx2, dx3, dx4
#
sub make_round {

    (my $p1, my $p2, my $p3, my $p4, my $s1, my $s2, my $s3, my $s4, my $s5, my $s6) = @_;
    my @res = ();

    my $d1 = ($p1 * $s1) % 65537;
    my $d2 = ($p2 + $s2) % 65536;
    my $d3 = ($p3 + $s3) % 65536;
    my $d4 = ($p4 * $s4) % 65537;

    my $d5 = $d1 ^ $d3;
    my $d6 = $d2 ^ $d4;

    my $d7  = ($d5 * $s5) % 65537;
    my $d8  = ($d6 + $d7) % 65536;
    my $d9  = ($d8 * $s6) % 65537;
    my $d10 = ($d7 + $d9) % 65536;

    my $d11 = $d1 ^ $d9;
    my $d12 = $d3 ^ $d9;
    my $d13 = $d2 ^ $d10;
    my $d14 = $d4 ^ $d10;

    push(@res, $d11, $d12, $d13, $d14);

    return @res;
}

#
#   Input:  A, B, C, D; array of 52 subkeys
#
sub encrypt {
    (my $A, my $B, my $C, my $D, my @s) = @_; #   read args.

    my @inputs = make_round($A, $B, $C, $D, $s[0], $s[1], $s[2], $s[3], $s[4], $s[5]);

    for (my $i = 1; $i <= 7; $i++) {
	@inputs = make_round(@inputs,
			     $s[$i * 6 + 0],
			     $s[$i * 6 + 1],
			     $s[$i * 6 + 2],
			     $s[$i * 6 + 3],
			     $s[$i * 6 + 4],
			     $s[$i * 6 + 5]);
	if ($i < 7) {
	    my $tmp = $res[1];
	    $res[1] = $res[2];
	    $res[2] = $tmp;
	}
    }

    my $c1 = ($inputs[0] * $s[48]) % 65537;
    my $c2 = ($inputs[1] + $s[49]) % 65536;
    my $c3 = ($inputs[2] + $s[50]) % 65536;
    my $c4 = ($inputs[3] * $s[51]) % 65537;

    my @ciphers = ($c1, $c2, $c3, $c4);

    return @ciphers;
}

sub main {
#    my $key = input_str("Enter 16 characters: ");
    my @bkey = ascii2bin(128, "abcdefghijklmnop");
    my $ref = $bkey[0];
    my @subkeys = generate_subkeys(@$ref);

    my $msg = input_str("Enter 8 char. (64-bit) length message: ");
    my @blocks = ascii2bin(16, $msg);

    my @m = (); # 64-bit length message (array of 4 16-bit numbers)

    for $ref (@blocks) {
	push(@m, bin2code(@$ref));
    }

    print("Message: @m\n");
    my @ciphers = encrypt(@m, @subkeys);
    print("Ciphers: @ciphers\n");

    my @dsubkeys = generate_dsubkeys(@subkeys);
#    print("Decryption subkeys: @dsubkeys\n");

    my @msgs = encrypt($ciphers[0], $ciphers[1], $ciphers[2], $ciphers[3], @dsubkeys);
    print("Message: @msgs\n");
}

main();
