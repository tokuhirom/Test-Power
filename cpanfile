requires 'perl', '5.014000';
requires 'B::Utils';
requires 'Text::Truncate';
requires 'Test::More', 0.98;
requires 'parent';
requires 'B::Tap';

on 'test' => sub {
    requires 'Test::Tester';
};

