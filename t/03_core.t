use strict;
use warnings;
use utf8;
use Test::More;
use Test::Power::Core;
use Data::Dumper;

subtest 'die', sub {
    my ($retval, $err, $out) = Test::Power::Core->give_me_power(sub { die });
    ok !$retval;
};

subtest 'return true value', sub {
    my ($retval, $err, $out) = Test::Power::Core->give_me_power(sub { 1 });
    ok $retval;
};

subtest 'expect', sub {
    my @p;
    my ($retval, $err, $out) = Test::Power::Core->give_me_power(sub { expect(\@p)->to_be(['a']) });
    ok !$retval;
    diag $err;
    diag Dumper($out);
};

done_testing;

{
    package E;
    sub to_be { 0 }
}

sub expect { bless +{}, E:: }
