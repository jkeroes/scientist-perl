package Scientist;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.0.4.001";

use Moose;
use namespace::autoclean;

use Carp;
use Scientist::Default;
use Scientist::Errors;
use Scientist::Experiment;
use Scientist::Observation;
use Scientist::Result;

=begin ruby

  # Define and run a science experiment.
  #
  # name - a String name for this experiment.
  # opts - optional hash with the the named test to run instead of "control",
  #        :run is the only valid key.
  #
  # Yields an object which implements the Scientist::Experiment interface.
  # See `Scientist::Experiment.new` for how this is defined.
  #
  # Returns the calculated value of the control experiment, or raises if an
  # exception was raised.
  def science(name, opts = {})
    experiment = Experiment.new(name)
    experiment.context(default_scientist_context)

    yield experiment

    test = opts[:run] if opts
    experiment.run(test)
  end

=end ruby

=cut

sub science {
	my ($self, $name, $opts) = @_;
	croak '$opts must be a hashref' if $opts && ref $opts ne 'HASH';

	my $experiment = Scientist::Experiment->new($name);
	$experiment->context($self->default_scientist_context);

	my $test = $opts->{run} if $opts;
	$experiment->run($test);
}

=begin ruby

  # Public: the default context data for an experiment created and run via the
  # `science` helper method. Override this in any class that includes Scientist
  # to define your own behavior.
  #
  # Returns a Hash.
  def default_scientist_context
    {}
  end

=end ruby

=cut

has default_scientist_context => (
	is      => 'ro',
	default => {},
);

__PACKAGE__->meta->make_immutable;

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

