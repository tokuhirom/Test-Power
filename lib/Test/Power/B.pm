package Test::Power::B;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Exporter);
use B;

our @EXPORT = qw(op_walk op_grep code_concise);

sub code_concise {
    my ($code) = @_;

    require B::Concise;
    my $walker = B::Concise::compile('', '', $code);
    $walker->();
}

sub op_grep(&$) {
    my ($code, $op) = @_;

    my @ret;
    op_walk(sub {
        local $_ = shift;
        if ($code->()) {
            push @ret, $_;
        }
    }, $op);
    return @ret;
}

sub op_walk(&$) {
    my ($code, $op) = @_;
    local *B::OP::walkoptree_simple = $code;
    B::walkoptree($op, 'walkoptree_simple');
}

1;

