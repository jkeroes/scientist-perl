requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Carp', '0';           # core
    requires 'Test::More', '0.98';  # core
    requires 'Moose', '2.1202';
    requires 'namespace::autoclean', '0';
    requires 'Set::Array', '0';
    requires 'Try::Tiny', '0';
    requires 'Time::HiRes', '0';
};

