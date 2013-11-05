requires 'perl', '5.014000';
requires 'Text::Truncate';
requires 'Test::More', 0.98;
requires 'parent';
requires 'B::Tap', '0.08';
requires 'B::Tools', 0.01;

on 'test' => sub {
    requires 'Test::Tester';
};

