package Scientist;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.0.4.001";



1;
__END__

=encoding utf-8

=head1 NAME

Scientist - carefully refactor critical paths

=head1 SYNOPSIS

    use Scientist;

    my $experiment = Scientist::Default->new('thing-study');

    $experiment->use( sub { do_old_thing() } );
    $experiment->try( sub { do_new_thing() } );
    $experiment->run;

=head1 DESCRIPTION

=head2 How do I science?

...

=head1 LICENSE

Copyright (C) Joshua Keroes.

See LICENSE file.

=head1 AUTHOR

Joshua Keroes E<lt>joshua.keroes@dreamhost.comE<gt>

=cut

