use strict;
use warnings;
use utf8;
use Test::More;
use Test::Power::Core;

subtest 'die', sub {
    my ($retval, $err, $out) = Test::Power::Core->give_me_power(sub { die });
    ok !$retval;
};

subtest 'return true value', sub {
    my ($retval, $err, $out) = Test::Power::Core->give_me_power(sub { 1 });
    ok $retval;
};

done_testing;

