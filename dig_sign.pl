#!/usr/bin/perl -w
#
#   Digital Sign (ElGamal clone) algorithm implementation
#
#   Edvardas Ges
#   VU MIF
#   Kompiuteriu Mokslas
#   III kursas, 8 gr.
#



sub input_str {

    my $msg = $_[0];

    print("$msg");
    my $str = <STDIN>;
    chomp($str);

    return $str;
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

    my $srn = int($n ** 0.5); # find square root of n

    for ($i = 2; $i <= $srn; $i++) {

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
#   Finds primary p and q, such that: q|(p-1), 2^(L-1) < p < 2^(L),
#                                     2^(L_-1) < q < 2^(L_), L_ < L.
#
#   Input:  L
#   Output: (p, q)
#
sub find_pq {

    my @pq = (0, 0);

    my $L=$_[0];

    my $p_ulim = 1 << $L;       # upper limit of p
    my $p_llim = 1 << ($L - 1); # lower limit of p

    for ($p = next_prime($p_llim); $p < $p_ulim; $p = next_prime($p)) {

	for ($q = 3; $q < $p_llim; $q = next_prime($q)) {

	    if (($p - 1) % $q == 0) {

		@pq = ($p, $q);
		return @pq;

	    } # 2nd if

	} # 2nd for

    } # 1st for

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
#   Finds randomized h, such that: 1 < h < (p - 1), (h ^ (p - 1) / q mod p) > 1
#
#   Input:  p, q
#   Output: h
#
sub find_h {

    (my $p, my $q) = @_; # fetch args.

    my $h = 0;

    while (1) {

	$h = int(rand($p - 1)) + 1;

	if (powerm($h, ($p - 1) / $q, $p) > 1) {

	    return $h;

	}

    }

}

#
#   Finds g value
#
#   Input:  h, p, q
#   Output: g
#
sub find_g {

    (my $h, my $p, my $q) = @_;

    return powerm($h, ($p - 1) / $q, $p);

}

#
#   Finds x value
#
#   Input:  q
#   Output: x
#
sub find_x {

    my $q = $_[0];

    return int(random($q - 1)) + 1;
}

#
#   Finds y value
#
#   Input:  g, x, p
#   Output: g ^ x mod p
#
sub find_y {

    (my $g, my $x, my $p) = @_;

    return powerm($g, $x, $p);

}

#
#   Find k - "secret" number
#
#   Input:  q
#   Output: k
#
sub find_k {

    my $q = $_[0];

    return (int(rand($q - 1)) + 1);
}

sub main {

    my $m = input_str("Enter message: ");;
    my $mc = ord($m);

    my @res = find_pq(16);
    (my $p, my $q) = @res;

    my $h = find_h($p, $q);
    my $g = find_g($h, $res[0], $res[1]);
    my $x = int(rand($q - 1)) + 1;
    my $y = powerm($g, $x, $p);
    my $k = find_k($q);

    my $kmod = find_converse($k, $q);

    my $r = $y % $q;

    my $s = ($kmod * (($mc + $x * $r) % $q)) % $q;

    while ($s == 0) {
	my $k = find_k($q);
	my $kmod = find_converse($k, $q);
	$s = ($kmod * (($mc + $x * $r) % $q)) % $q;
    }

    print("Message: $m, digital sign: ($r, $s)\n");

    print("--- Verification process ---\n");

    my $r_new = input_str("Enter new r: ");
    my $s_new = input_str("Enter new s: ");

    my $w = find_converse($s_new, $q);

    my $u1 = ($mc * $w) % $q;
    my $u2 = ($r_new * $w) % $q;

    my $v = (($g ** $u1 * $y ** $u2) % $p) % $q;

    if ($v == $r_new) {
	print("The message is authentic.\n");
    } else {
	print("The message is not authentic.\n");
    }

}

main();
