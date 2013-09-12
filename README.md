# NAME

Test::Power - With great power, comes great responsibility.

# SYNOPSIS

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

# DESCRIPTION

__WARNINGS: This module is currently ALPHA state. Any APIs will change without notice. And this module uses the B power, it may cause segmentation fault.__

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

Woooooooh! It's pretty magical. `Test::Power` shows the calculation progress! You don't need to use different functions for testing types, like ok, cmp\_ok, is...

# EXPORTABLE FUNCTIONS

- `ok(&code)`

        ok { $foo };

    This simply run the `&code`, and uses that to determine if the test succeeded or failed.
    A true expression passes, a false one fails.  Very simple.

- `subtest()`

    Same as `Test::More::subtest`.

- `plan()`

    Same as `Test::More::plan`.

- `done_testing()`

    Same as `Test::More::done_testing`.

- `pass()`

    Same as `Test::More::pass`.

# LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokuhirom <tokuhirom@gmail.com>

# SEE ALSO

[Test::More](http://search.cpan.org/perldoc?Test::More)
