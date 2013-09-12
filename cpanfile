requires 'perl', '5.010001';
requires 'B::Generate';
requires 'B::Utils';
requires 'Text::Truncate';
requires 'Test::More', 0.98;
requires 'parent';

on 'test' => sub {
    requires 'Test::Tester';
};

