use strict;
use warnings;
use utf8;
use Test::More;
use Test::Power;

sub foo { 5 }
sub bar { 5,4,3 }
expect { foo() == 3 };
expect { bar() == 3 };

done_testing;

