#!/usr/bin/perl -w
#
#   Merkle-Hellman algorithm implementation
#
#   Edvardas Ges
#   VU MIF
#   Kompiuteriu Mokslas
#   III kursas, 8 gr.
#



#
#   GCD - Greatest Common Divider
#
#   Input:  a, b
#   Output: n
#
sub gcd {

    my $a = $_[0];
    my $b = $_[1];

    my $min = $a;

    if ($min > $b) {

	$min = $b;

    }

    my $res = 1;

    for ($i = 1; $i <= $min; $i++) {

	if ($a % $i == 0 && $b % $i == 0) {

	    $res = $i;

	}

    }

    return $res;

}

#
#   Converts block of bits into decimal number
#
#   Input:  array of bits
#   Output: decimal number
#
sub bin2code {

    my @bits = @_;

    my $d = 0;

    my $n = $#bits + 1;

    for ($i = 0; $i < $n; $i++) {

	$d = $d + $bits[$i] * (1 << ($n - $i - 1));

    }

    return $d;
}

#
#   Converts ASCII string to binary representation.
#
#   Input:  ASCII string
#   Output: array of bits
#
sub ascii2bin {

    my $str = $_[0];
    my @bin_str = ();

    for ($i = 0; $i < length($str); $i++) {

	my $sc = ord(substr($str, $i, 1)); # ASCII code of the symbol
	my $bits = sprintf("%08b", $sc);   # binary representation of the code
	push(@bin_str, split(//,$bits));   # add the binary rep. to the array

    }

    return @bin_str;
}

#
#   Generates public and private keys
#
#   Input:  Array of message bits
#   Output: keys[ [@a], P, M, W, [@b] ]
#
sub generate_keys {

    my @bits = @_;
    my $n = $#bits + 1; # number of bits in the message

    my @keys = ();

    my @b = ();
    my $M = 0;
    my $W = 0;
    my @P = ();
    my @a = ();

    for ($i = 0; $i < $n; $i++) {

	my $bi = 1 << $i;

	push(@b, $bi);

	$M = $M + $bi;

    }

    print("b: @b\n");

    #
    #   Calc. M
    #
    $M = $M + 1 + int(rand($n));

    print("M: $M\n");

    #
    #   Find W
    #
    while (1) {
	$W = int(rand($M - 1)) + 1;

	if (gcd($W, $M) == 1) {

	    last;

	}
    }

    print("W: $W\n");

    for ($i = 0; $i < $n; $i++) {

	push(@P, 0);

    }

    for ($i = 1; $i <= $n; $i++) {
	while (1) {
	    my $idx = int(rand($n)); # generates idx from 0 .. n-1
	    if ($P[$idx] == 0) {
		$P[$idx] = $i;
		last;
	    } # if
	} # while
    } # for

    print("P: @P\n");

    for ($i = 0; $i < $n; $i++) {

	push(@a, ($b[$P[$i] - 1] * $W) % $M);

    }

    print("a: @a\n");

    push(@keys, [@a], [@P], $M, $W, [@b]);

    return @keys;
}

#
#   Finds x^-1 mod n
#
#   Input:  x, n
#   Output: x^-1 mod n, or 0 - if non-existing
#
sub find_converse {

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
#   Encrypts input bits using public key
#
#   Input:  pointer to public key, pointer to message bits
#   Output: cipher
#
sub mh_encrypt {

    (my $pkeyref, my $msgref) = @_;

    my @public_key = @$pkeyref; # dereference public key reference
    my @message = @$msgref;     # dereference message reference

    print("message: @message\n");
    print("public key: @public_key\n");

    my $cipher = 0;

    for ($i = 0; $i <= $#public_key; $i++) {

	$cipher = $cipher + $public_key[$i] * $message[$i];

    }

    return $cipher;

}

#
#   Decrypts given cipher using private key
#
#   Input:  cipher, M, W, bref
#   Output: message bits
#
sub mh_decrypt {

    (my $c, my $M, my $W, my $bref, my $pref) = @_;

    my @b = @$bref;
    my @P = @$pref;
    my $n = $#b + 1;

    my $d = (find_converse($W, $M) * $c % $M) % $M;

    print("d: $d\n");

    my @r = ();

    for ($i = 0; $i < $n; $i++) {

	push(@r, 0);

    }

    my $sum = 0;

    #
    #   Calculate r
    #
    for ($i = $n - 1; $i >= 0; $i--) {

	$sum = $sum + $b[$i];

	if ($sum <= $d) {
	    $r[$i] = 1;
	}

	if ($sum > $d) {
	    $sum = $sum - $b[$i];
	}

    }

    print("r: @r\n");

    #
    #   Find message bits
    #
    @msg = ();

    for ($i = 0; $i < $n; $i++) {

	push(@msg, $r[$P[$i] - 1]);

    }

    return @msg;
}

sub main {

    $str = "A";

    @bits = ascii2bin($str);

    (my $aref, my $pref, my $M, my $W, my $bref) = generate_keys(@bits);

    my @a = @$aref;
    my @P = @$pref;
    my @b = @$bref;

    my $c = mh_encrypt($aref, [@bits]);

    print("cipher: $c\n");

    my @mbits = mh_decrypt($c, $M, $W, $bref, $pref);

    print("message bits: @mbits\n");

    my $m = bin2code(@mbits);

    my $t = chr($m);
    print("Message: $t\n");
}

sub find_w {

    $M = $_[0];
    #
    #   Find W
    #
    while (1) {
	$W = int(rand(324 - 1)) + 1;

	if (gcd($W, $M) == 1) {

	    last;

	}
    }

    print "W: ", $W, "\n";
}

find_w(257);

print "Converse: ", find_converse(6, 257), "\n";

main();
