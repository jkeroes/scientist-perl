package Scientist::Result;

=begin ruby

# The immutable result of running an experiment.
class Scientist::Result

=end ruby

=cut

use Set::Array;
use Moose;
use namespace::autoclean;

=begin ruby

  # An Array of candidate Observations.
  attr_reader :candidates

  # The control Observation to which the rest are compared.
  attr_reader :control

  # An Experiment.
  attr_reader :experiment

  # An Array of observations which didn't match the control, but were ignored.
  attr_reader :ignored

  # An Array of observations which didn't match the control.
  attr_reader :mismatched

  # An Array of Observations in execution order.
  attr_reader :observations

=end ruby

=cut

has candidates => (
	traits  => ['ARRAY'],
	is      => 'ro',
);

has control => (
	is => 'ro',
);

has experiment => (
	is => 'ro',
);

has ignored => (
	traits => ['ARRAY'],
	is     => 'ro',
	handles => {
		has_options    => 'count',
		add_option     => 'push',
		# has_no_options => 'is_empty',
	}
);

has mismatched => (
	traits  => ['ARRAY'],
	is      => 'ro',
	handles => {
		add_option     => 'push',
		has_options    => 'count',
		has_no_options => 'is_empty',
	},
);

has observations  => (
	traits => ['ARRAY'],
	is     => 'ro',
);

=begin ruby

  # Internal: Create a new result.
  #
  # experiment    - the Experiment this result is for
  # observations: - an Array of Observations, in execution order
  # control:      - the control Observation
  #
  def initialize(experiment, observations = [], control = nil)
    @experiment   = experiment
    @observations = observations
    @control      = control
    @candidates   = observations - [control]
    evaluate_candidates

    freeze
  end

=end ruby

=cut

sub BUILD {
	my $self = shift;

	# TODO Set::Array disjunction on:
	my $disj = Set::Array::Disjunction($self->observations, $self->control);

	$self->candidates($disj);
	$self->evaluate_candidates;

	# TODO
	# Not sure where this comes from:
	# freeze()
}

=begin ruby

  # Public: the experiment's context
  def context
    experiment.context
  end

=end ruby

=cut

sub context {
	my $self = shift;
	return $self->experiment->context;
}

=begin ruby

  # Public: the name of the experiment
  def experiment_name
    experiment.name
  end

=end ruby

=cut

sub experiment_name {
	my $self = shift;
	return $self->experiment->name;
}

=begin ruby

  # Public: was the result a match between all behaviors?
  def matched?
    mismatched.empty? && !ignored?
  end

=end ruby

=cut

sub is_matched {
	my $self = shift;
	return $self->mismatched->is_empty && ! $self->is_ignored;
}

=begin ruby

  # Public: were there mismatches in the behaviors?
  def mismatched?
    mismatched.any?
  end

=end ruby

=cut

sub is_mismatched {
	my $self = shift;
	return $self->mismatched->count;
}


=begin ruby

  # Public: were there any ignored mismatches?
  def ignored?
    ignored.any?
  end

=end ruby

=cut

sub is_ignored {
	my $self = shift;
	return $self->ignored->count;
}

=begin ruby

  # Internal: evaluate the candidates to find mismatched and ignored results
  #
  # Sets @ignored and @mismatched with the ignored and mismatched candidates.
  def evaluate_candidates
    mismatched = candidates.reject do |candidate|
      experiment.observations_are_equivalent?(control, candidate)
    end

    @ignored = mismatched.select do |candidate|
      experiment.ignore_mismatched_observation? control, candidate
    end

    @mismatched = mismatched - @ignored
  end
end

=end ruby

=cut

sub evaluate_candidates {
	my $self = shift;

	my $experiment = $self->experiment;
	my $control = $self->control;

	my @mismatched;
	for my $candidate ($self->candidates->reject) {
		push @mismatched, $candidate
			if $experiment->observations_are_equivalent(
				$control,
				$candidate,
			);
	}

	for my $candidate ($self->mismatched->select) {
		$self->ignored->push($candidate)
			if $experiment->ignore_mismatched_observation(
				$control,
				$candidate,
			);
	}

	my $disj = Set::Array::disjunction(\@mismatched, $self->ignored);
	$self->mismatched(@mismatched);
}

no Moose;

1;
