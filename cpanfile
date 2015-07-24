requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Moo', '2.0';
    requires 'namespace::autoclean', '0';
    requires 'strictures', '2';
};

