package Test::Power::Core;
use strict;
use warnings;
use utf8;
use 5.010_001;

# TODO: support method call

use B qw(class);
use B::Generate;
use B::Utils;

use Test::Power::B qw(op_grep op_walk code_concise);

our @OP_STACK;
our @TAP_RESULTS;

sub null {
    my $op = shift;
    return class($op) eq "NULL";
}

sub give_me_power {
    my ($class,$code) = @_;

    my $cv= B::svref_2object($code);

    local @TAP_RESULTS;
    local @OP_STACK;


    my $root = $cv->ROOT;
    # local $B::overlay = {};
    if (not null $root) {
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
        [@TAP_RESULTS],
        [@OP_STACK],
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
            my $entersub = wrap_by_tap(
                $self->first,
                [$self->parent->kids]->[0]->next(),
                sub {
                    [$self->parent->kids]->[0]->next(@_);
                }
            );
            $entersub->next($self->last);
            $entersub->sibling($self->last);
            $self->first($entersub);
        }
        if ($self->last->name ne 'const') {
            my $nnext = $self->last->next;
            my $entersub = wrap_by_tap(
                $self->last,
                $self->first->next,
                sub {
                    $self->first->next(@_),
                }
            );
            $self->first->sibling($entersub);
            $entersub->next($nnext);
            $self->last($entersub);
        }

    #   UNOP (0x1ac6b18) entersub [1]
    #       UNOP (0x1ac6b90) null [147]
    #           OP (0x1ac6b58) pushmark
    #           SVOP (0x1ac6c18) const  IV (0x1abbf28) 4
    #           UNOP (0x1ac6bd8) null [17]
    #               SVOP (0x1ac6c58) gv  GV (0x1abbf58) *tap
    }
}

sub wrap_by_tap {
    my ($target, $target_entrypoint, $set_entrypoint) = @_;

    my $pushmark = B::OP->new('pushmark', 0);
    $pushmark->sibling($target);

    my $gv = B::GVOP->new('gv', 0, *tap);
    my $rv2cv = B::UNOP->new('rv2cv', 0, $gv);
    my $list = B::LISTOP->new('list', 0, $pushmark, $rv2cv);

    push @OP_STACK, $target;
    my $target_op_idx = B::SVOP->new('const', 0, 0+@OP_STACK-1);
    $target->sibling($target_op_idx);
    $target_op_idx->sibling($rv2cv);

    # B::OPf_STACKED | B::OPf_WANT_SCALAR | B::OPf_KIDS;
    my $entersub = B::UNOP->new(
        'entersub',
        $target->flags, # really?
        $list,
    );

    # Connect nodes next links.
    $set_entrypoint->($pushmark);
    $pushmark->next($target_entrypoint);
    $target->next($target_op_idx);
    $target_op_idx->next($gv);
    $gv->next($entersub);

    return $entersub;
}

sub tap {
    my ($stuff, $target_op_idx) = @_;
    push @TAP_RESULTS, [
        $stuff,
        $target_op_idx,
    ];
    return $stuff;
}


1;

