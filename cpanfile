requires 'perl', '5.014000';

requires 'Text::Truncate';
requires 'Test::More', 0.98;
requires 'parent';
requires 'Devel::CodeObserver', '0.16';

on 'test' => sub {
    requires 'Test::Tester';
};

