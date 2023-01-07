#!/usr/bin/perl -w
#
#   Reorders
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
#   These should be global
#
@result = ();
@set = ();
$N = 0;

#
#   Swaps two items of the global array @set
#
#   Input:  i, j
#   Output: none
#
sub my_swap {

    (my $i, my $j) = @_;

    my $tmp = $set[$i];
    $set[$i] = $set[$j];
    $set[$j] = $tmp;
}

#
#   Generates all permutations of a given set of numbers
#
#   Input:  i, N, set, result
#   Output: array of permutations
#
sub permutate {

    my $i = $_[0];

    if ($i == $N) {
	push(@result, [@set]);
    } else {
	my $j = $i;
	for (; $j < $N; $j++) {
	    my_swap($i, $j, @set);
	    permutate($i + 1);
	    my_swap($i, $j, @set);
	}
    }
}

#
#   Encrypts/Decrypts message
#
#   Input:  cipher/message, key
#   Output: message/cipher (array)
#
sub my_crypt {

    (my $mcref, my $keyref) = @_;
    my @mc = @$mcref;
    my @key = @$keyref;
    my $mc_len = $#mc + 1;
    my $key_len = $#key + 1;
    my @res = ();

    my $app = $mc_len % $key_len;

    if ($app) {
	for ($i = 0; $i < $key_len - $app; $i++) {
	    push(@mc, $mc[$i]);
	}
    }

    for ($i = 0; $i < $mc_len; $i += $key_len) {

	for ($j = 0; $j < $key_len; $j++) {

	    push(@res, $mc[$i + $key[$j] - 1]);

	}

    }

    return @res;

}

sub array2str {

    my @array = @_;
    my $str = "";

    for ($i = 0; $i <= $#array; $i++) {

	my $c = $array[$i];
	$str = $str."$c";

    }

    return $str;
}

sub main {

    @set = ();

    my $strkey = input_str("Enter key: ");
    @set = split(//, $strkey);
    $N = $#set;

    permutate(0);

    my $str = input_str("Enter message: ");
    my $subword = input_str("Enter any word that the message contains: ");
    my @cipher = my_crypt([split(//, $str)], [@set]);

    print("cipher: ", @cipher, "\n");

    foreach $ref (@result) {
	my @message = my_crypt([@cipher], [@$ref]);
	my $str = array2str(@message);

	if (index($str, $subword) >= 0) {

	    print("message: $str, key: @$ref\n");

	}
    }
}

main();
