use strict;
use warnings;
use utf8;
use Test::More;
use Test::Power::Core;
use Data::Dumper;

# Test case for the low level API.

subtest 'return true value', sub {
    my ($retval, $out) = Test::Power::Core->give_me_power(sub { 2 });
    is $retval, 2;
};

subtest 'return undef value', sub {
    my ($retval, $out) = Test::Power::Core->give_me_power(sub { undef });
    is $retval, undef;
};

subtest 'expect data', sub {
    my @p;
    my ($retval, $out) = Test::Power::Core->give_me_power(sub { expect(\@p)->to_be(['a']) });
    ok !$retval;
    ok @$out > 0;
    like $out->[0], qr/expect/;
    diag Dumper($out);
};

done_testing;

{
    package E;
    sub to_be { 0 }
}

sub expect { bless +{}, E:: }
