package Test::Power::Core;
use strict;
use warnings;
use utf8;
use 5.010_001;

# TODO: support method call

use B qw(class ppname);
use B::Tap qw(tap);
use B::Tools qw(op_walk);

our @TAP_RESULTS;
our $ROOT;

sub null {
    my $op = shift;
    return class($op) eq "NULL";
}

sub give_me_power {
    my ($class,$code) = @_;

    my $cv= B::svref_2object($code);

    local @TAP_RESULTS;

    local $ROOT = $cv->ROOT;
    # local $B::overlay = {};
    if (not null $ROOT) {
        op_walk {
            if (need_hook($_)) {
                my @buf = ($_);
                tap($_, $cv->ROOT, \@buf);
                push @TAP_RESULTS, \@buf;
            }
        } $cv->ROOT;
    }
    if (0) {
        require B::Concise;
        my $walker = B::Concise::compile('', '', $code);
        $walker->();
    }
    my $retval = eval { $code->() };
    return (
        $retval,
        $@,
        [grep { @$_ > 1 } @TAP_RESULTS],
    );
}

sub need_hook {
    my $op = shift;
    return 1 if $op->name eq 'entersub';
    return 1 if $op->name eq 'padsv';
    return 1 if $op->name eq 'aelem';
    return 1 if $op->name eq 'helem';
    return 1 if $op->name eq 'null' && ppname($op->targ) eq 'pp_rv2sv';
    return 0;
}

1;
