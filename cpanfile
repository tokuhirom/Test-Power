requires 'perl', '5.008001';
requires 'B::Generate';
requires 'B::Utils';
requires 'Text::Truncate';
requires 'Test::More', 0.98;

on 'test' => sub {
    requires 'Test::Tester';
};

