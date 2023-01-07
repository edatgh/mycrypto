#!/usr/bin/perl -w
#
#   Simplest Hash functions
#
#   Edvardas Ges
#   VU MIF
#   Kompiuteriu Mokslas
#   III kursas, 8 gr.
#



#
#   Converts each block of bits into decimal number
#
#   Input:  array of bit blocks
#   Output: array of decimal numbers
#
sub bin2code {

    my @blocks = @_;
    my @decimals = ();

    foreach $ref (@blocks) {

	my @n = @$ref;
	my $d = 0;
	for ($i = 0; $i <= $#n; $i++) {
	    $d = $d + $n[$i] * (1 << ($#n - $i));
	}

	push(@decimals, $d);
    }

    return @decimals;
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

    for ($i = 0; $i < length($str); $i++) {

	my $sc = ord(substr($str, $i, 1)); # ASCII code of the symbol
	my $bits = sprintf("%08b", $sc);   # binary representation of the code
	push(@bin_str, split(//,$bits));   # add the binary rep. to the array

    }

    my @blocks = ();

    my $len = int(($#bin_str + 1) / $k);

    for ($i = 0; $i < $len; $i++) {

	my @block = (); # (re)define array, those (re)makeing it empty

	for ($j = 0; $j < $k; $j++) {

	    push(@block, shift(@bin_str));

	}

	push(@blocks, [@block]);
    }

    return @blocks;
}

#
#
#
sub input_str {

    my $msg = $_[0];

    print("$msg");
    my $str = <STDIN>;
    chomp($str);

    return $str;
}

sub rol {

    my $n = $_[0];

    my $ms = $n & (1 << 15); # 32768

    if ($ms) {

	$ms = 1;

    }

    $n = ($n << 1) | $ms;

    return $n;

}

sub main {

    my $f = ord('Z') - ord('A') + 1;
    print("$f\n");
    return;

#    my $str = input_str("Enter message: ");

    $str = "QWER";

    my $C = 0;

    my @blocks = ascii2bin(16, $str);

    my @numbers = bin2code(@blocks);

    my $len = $#numbers + 1;

    for ($i = 0; $i < $len; $i++) {

	$C = rol($C);
	$C = $C ^ $numbers[$i];

    }

    print("C == $C\n");

    print("Initializing...\n");

    my $int_start = (ord('A') << 24) + (ord('A') << 16) + (ord('A') << 8) + (ord('A'));
    my $int_end = (ord('Z') << 24) + (ord('Z') << 16) + (ord('Z') << 8) + (ord('Z'));

    my $n1 = 0;
    my $n2 = 0;

    my $A = 0;
    my $cnt = 0;
    my $bit;
    my $n = (2 << 16) - 1;

    print("Calculating...\n");

    for ($i = $int_start; $i <= $int_end; $i++) {
#	print("i == $i\n");

	$n1 = $i >> 16;             #   higher word
	$n2 = $i & $n; #   lower word

	$A = 0;

	$A = $A ^ $n1;
	$bit = $A % 2;
	$A = $A << 1;
	$A = $A | $bit;
	$A = $A ^ $n2;

	if ($A == $C) {
	    $cnt++;
#	    print("cnt == $cnt\n");
	}
    }

    print("Done.\n");
    print("cnt == $cnt\n");
}

main();
