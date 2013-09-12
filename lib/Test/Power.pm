package Test::Power;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Test::More 0.98 ();
use B::Deparse;
use Data::Dumper ();
use Text::Truncate qw(truncstr);
use parent qw(Exporter);

use Test::Power::Core;
use Test::Power::FromLine;

our @EXPORT = qw(ok done_testing subtest plan pass fail);
*done_testing = *Test::More::done_testing;
*subtest      = *Test::More::subtest;
*plan         = *Test::More::plan;
*pass         = *Test::More::pass;
*fail         = *Test::More::fail;

use constant {
    RESULT_VALUE => 0,
    RESULT_OPINDEX => 1,
};

our $DEPARSE = B::Deparse->new;
our $DUMP_CUTOFF = 80;

sub ok(&) {
    my ($code) = @_;

    my ($package, $filename, $line_no, $line) = Test::Power::FromLine::inspect_line(0);

    my $BUILDER = Test::More->builder;

    local $@;
    my ($retval, $err, $tap_results, $op_stack)
        = Test::Power::Core->give_me_power($code);
    my $description = "L$line_no" . (length($line) ? " : $line" : '');
    if ($retval) {
        $BUILDER->ok(1, $description);
    } else {
        $BUILDER->ok(0, $description);
        $BUILDER->diag($err) if $err;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Indent = 0;
        for my $result (@$tap_results) {
            $BUILDER->diag($DEPARSE->deparse($op_stack->[$result->[RESULT_OPINDEX]]));
            $BUILDER->diag("   => " . truncstr(Data::Dumper::Dumper($result->[RESULT_VALUE]), $DUMP_CUTOFF, '...'));
        }
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

Test::Power - With great power, comes great responsibility.

=head1 SYNOPSIS

    use Test::Power;

    sub foo { 4 }
    ok { foo() == 3 };
    ok { foo() == 4 };

Output:

    not ok 1 - L12 : ok { foo() == 3 };
    #   Failed test 'L12 : ok { foo() == 3 };'
    #   at foo.pl line 12.
    # foo()
    #    => 4
    ok 2 - L13 : ok { foo() == 4 };
    1..2
    # Looks like you failed 1 test of 2.

=head1 DESCRIPTION

B<WARNINGS: This module is currently ALPHA state. Any APIs will change without notice. And this module uses the B power, it may cause segmentation fault.>

Test::Power is yet another testing framework.

Test::Power shows progress data if it's fails. For example, here is a testing script using Test::Power. This test may fail.

    use Test::Power;

    sub foo { 3 }
    ok { foo() == 2 };
    done_testing;

Output is:

    not ok 1 - L6: ok { foo() == 2 };
    # foo()
    #    => 3
    1..1

Woooooooh! It's pretty magical. C<Test::Power> shows the calculation progress! You don't need to use different functions for testing types, like ok, cmp_ok, is...

=head1 EXPORTABLE FUNCTIONS

=over 4

=item C<< ok(&code) >>

    ok { $foo };

This simply run the C<&code>, and uses that to determine if the test succeeded or failed.
A true expression passes, a false one fails.  Very simple.

=item C<< subtest() >>

Same as C<Test::More::subtest>.

=item C<< plan() >>

Same as C<Test::More::plan>.

=item C<< done_testing() >>

Same as C<Test::More::done_testing>.

=item C<< pass() >>

Same as C<Test::More::pass>.

=back

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

L<Test::More>

=cut

