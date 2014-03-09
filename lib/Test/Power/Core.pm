package Test::Power::Core;
use strict;
use warnings;
use utf8;
use 5.010_001;

our $VERSION = "0.13";

# TODO: support method call

use B qw(class ppname);
use B::Tap qw(tap);
use B::Tools qw(op_walk);
use B::Deparse;
use Data::Dumper ();
use Try::Tiny;

sub null {
    my $op = shift;
    return class($op) eq "NULL";
}

sub give_me_power {
    my ($class,$code) = @_;

    my $cv= B::svref_2object($code);

    my @tap_results;

    my $root = $cv->ROOT;
    # local $B::overlay = {};
    if (not null $root) {
        op_walk {
            if (need_hook($_)) {
                my @buf = ($_);
                tap($_, $cv->ROOT, \@buf);
                push @tap_results, \@buf;
            }
        } $cv->ROOT;
    }
    if (0) {
        require B::Concise;
        my $walker = B::Concise::compile('', '', $code);
        $walker->();
    }

    my $retval = $code->();

    return (
        $retval,
        dump_pairs($code, [grep { @$_ > 1 } @tap_results]),
    );
}

sub dump_pairs {
    my ($code, $tap_results) = @_;

    my @pairs;
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 0;
    for my $result (@$tap_results) {
        my $op = shift @$result;
        for my $value (@$result) {
            # take first argument if the value is scalar.
            try {
                # Suppress warnings for: sub { expect(\@p)->to_be(['a']) }
                local $SIG{__WARN__} = sub { };

                my $deparse = B::Deparse->new();
                $deparse->{curcv} = B::svref_2object($code);
                push @pairs, $deparse->deparse($op);
                push @pairs, Data::Dumper::Dumper($value->[1]);
            } catch {
                warn $_
            };
        }
    }
    return \@pairs;
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
