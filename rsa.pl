#!/usr/bin/perl -w
#
#   RSA algorithm implementation
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
#
#
sub code2ascii {

    (my $k, my @codes) = @_;

    my @bits = ();

    foreach $code (@codes) {

	my $c = $code;
	my $len = 0;
	my @bit_block = ();

	while ($c) {

	    $len++;

	    unshift(@bit_block, $c % 2);
	    $c = int($c / 2);

	}

	for ($i = $len; $i < $k; $i++) {

	    unshift(@bit_block, 0);

	}

	push(@bits, @bit_block);

    }

    my @ascii = ();

    for ($i = 0; $i < (($#bits + 1) / 8); $i++) {

	my $d = 0;

	for ($j = 0; $j < 8; $j++) {

	    $d = $d + $bits[$i * 8 + $j] * (1 << 7 - $j);

	}

	push(@ascii, chr($d));

    }

    return @ascii;

}

#
#   Determinates if the given number is prime
#
#   Input:  n
#   Output: 1 - n is prime
#           0 - n is not prime
#
sub is_prime {

    my $n = $_[0]; # take the argument

    if ($n <= 1) {

	return 0;

    }

    for ($i = 2; $i <= int($n ** 0.5); $i++) {

	if ($n % $i == 0) {

	    return 0; # n is not prime

	}

    }

    return 1; # n is prime

}

#
#   Finds next prime, i.e. finds number which is greater than specified
#   and is prime
#
#   Input:  n (any number)
#   Output: nn - prime greater than n
#
sub next_prime {

    my $nn = $_[0] + 1;

    while (1) {

	if (is_prime($nn)) {

	    last;

	} else {

	    $nn++;

	}

    }

    return $nn;
}

#
#   Finds primary p and q, such that p * q > 2^k
#
#   Input:  2^k
#   Output: (p, q)
#
sub find_pq {

    my @pq = (2, 2); # 2 is smallest prime number (assign it to p and q)
    my $p = 0; # index of p in the array
    my $q = 1; # index of q
    my $twopk = $_[0]; # take input

    while (1) {

	if ($pq[$p] * $pq[$q] > $twopk) {

	    last;

	}

	if (int(rand(100)) % 2 == 1) {

	    $pq[$p] = next_prime($pq[$p]);

	} else {

	    $pq[$q] = next_prime($pq[$q]);

	}
    }

    return @pq;
}

#
#   Finds Euler's function result (this is a very simple case, when result of the function is
#   simply (p - 1) * (q - 1) )
#
#   Input:  p, q
#   Output: fi(n) ( in this case: (p - 1) * (q - 1) )
#
sub fi_n {

    my @pq = @_;

    return (($pq[0] - 1) * ($pq[1] - 1));

}

#
#   Finds e, such that gcd(e, fi_n) == 1
#
#   Input:  fi_n
#   Output: e or 0 if e not found
#
sub find_e {

    my $fn = $_[0]; # argument

    # NOTE: 1 < e < fi_n
    for ($e = 2; $e < $fn; $e++) {

	if (gcd($e, $fn) == 1) {

	    return $e;

	}

    }

    return 0; # e not found

}

#
#   Finds a^b mod n
#
#   Input:  a, b, n
#   Output: res
#
sub powerm {

    (my $a, my $b, my $n) = @_; # fetch arguments

    if ($b == 0) {

	return 1;

    } else {

	my $t = powerm($a, int($b / 2), $n);

	$t *= $t;

	if ($b % 2) {

	    $t *= $a;

	}

	return $t % $n;

    }

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
#   Calculates array of values C by rule: Ci = Mi ^ e mod n
#
#   Input:  array of M values (messages), e, n
#   Output: array of C values (ciphers)
#
sub encrypt {

    (my $messages, my $e, my $n) = @_;
    my @ciphers = ();

    foreach $msg (@$messages) {
	my $c = powerm($msg, $e, $n);
	push(@ciphers, $c);
    }

    return @ciphers;
}

sub decrypt {

    (my $cyphers, my $d, my $n) = @_;

    my @messages = ();

    foreach $ciph (@$cyphers) {
	my $m = powerm($ciph, $d, $n);
	push(@messages, $m);
    }

    return @messages;
}

sub input_str {

    my $msg = $_[0];

    print("$msg");
    my $str = <STDIN>;
    chomp($str);

    return $str;
}

sub main {

    my @pq = find_pq(65536);
    my $n = $pq[0] * $pq[1];
    print("pq == @pq\n");

    my $fn = fi_n(@pq);
    print("fi(n) == $fn\n");

    my $e = find_e($fn);
    print("e == $e\n");

    my $d = find_converse($e, $fn);
    print("d == $d\n");

    my $str = input_str("Enter message: ");
    my $bitnr = input_str("Enter block length: ");

    my @bin = ascii2bin($bitnr, $str);

    my @decimals = bin2code(@bin);
    print("decimals: @decimals\n");

    my @ciphers = encrypt([@decimals], $e, $n);
    print("ciphers: @ciphers\n");

    my @messages = decrypt([@ciphers], $d, $n);
    print("msgs: @messages\n");

    my @str = code2ascii($bitnr, @messages);
    print(@str, "\n");
}

main();
