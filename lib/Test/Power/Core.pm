package Test::Power::Core;
use strict;
use warnings;
use utf8;
use 5.010_001;

# TODO: support method call

use B qw(class);
use B::Tap qw(tap);

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
        B::walkoptree($cv->ROOT, 'power_test');
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

sub B::OP::power_test {
    my $self = shift;
    # warn $self->name;
}

sub B::BINOP::power_test {
    my $self = shift;
    my %supported_ops = (
        map { $_ => 1 }
        qw(
         eq  ne  gt  ge  lt  le
        seq sne sgt sge slt sle)
    );
    if ($supported_ops{$self->name}) {
        if ($self->first->name ne 'const') {
            my @buf = ($self->first);
            tap($self->first, $ROOT, \@buf);
            push @TAP_RESULTS, \@buf;
        }
        if ($self->last->name ne 'const') {
            my @buf = ($self->last);
            tap($self->last, $ROOT, \@buf);
            push @TAP_RESULTS, \@buf;
        }

    #   UNOP (0x1ac6b18) entersub [1]
    #       UNOP (0x1ac6b90) null [147]
    #           OP (0x1ac6b58) pushmark
    #           SVOP (0x1ac6c18) const  IV (0x1abbf28) 4
    #           UNOP (0x1ac6bd8) null [17]
    #               SVOP (0x1ac6c58) gv  GV (0x1abbf58) *tap
    }
}

1;
