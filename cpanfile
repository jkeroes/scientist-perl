requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Moose', '2.1202';
    requires 'namespace::autoclean', '0';
    requires 'Set::Array', '0';
};

