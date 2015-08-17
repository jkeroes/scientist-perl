package Scientist::Experiment;

use Moose;
use Carp;
use namespace::autoclean;
use Try::Tiny;

=begin ruby

# This mixin provides shared behavior for experiments. Includers must implement
# `enabled?` and `publish(result)`.
#
# Override Scientist::Experiment.new to set your own class which includes and
# implements Scientist::Experiment's interface.
module Scientist::Experiment

  # Create a new instance of a class that implements the Scientist::Experiment
  # interface.
  #
  # Override this method directly to change the default implementation.
  def self.new(name)
    Scientist::Default.new(name)
  end

=end ruby

=cut

# requires Perl hash-style args

sub BUILD {
	my $self = shift;
	return Scientist::Default->new(@_);
};

# sub BUILDARGS {
#
# }

=begin ruby

  # A mismatch, raised when raise_on_mismatches is enabled.
  class MismatchError < StandardError

    attr_reader :name, :result

    def initialize(name, result)
      @name   = name
      @result = result
      super "experiment '#{name}' observations mismatched"
    end

=end ruby

=cut

# implemented with confess/die eg

# die "experiment $name observations mismatched (MismatchError)";

=begin ruby

    # The default formatting is nearly unreadable, so make it useful.
    #
    # The assumption here is that errors raised in a test environment are
    # printed out as strings, rather than using #inspect.
    def to_s
      super + ":\n" +
      format_observation(result.control) + "\n" +
      result.candidates.map { |candidate| format_observation(candidate) }.join("\n") +
      "\n"
    end

=end ruby

=cut

# TODO: figure out what to do with the stringification of super.

	# sub to_s {
	# 	my $self = shift;
	# 	my $result = $self->result;

	# 	return
	# 		$self->... . ":\n" .
	# 		$self->format_observation($result->control) . "\n" .
	# 		join("\n", map { $_->format_observation } $result->candidates) .
	# 		"\n";
	# }

=begin ruby

    def format_observation(observation)
      observation.name + ":\n" +
      if observation.raised?
        observation.exception.inspect.prepend("  ") + "\n" +
          observation.exception.backtrace.map { |line| line.prepend("    ") }.join("\n")
      else
        observation.value.inspect.prepend("  ")
      end
    end
  end

=end ruby

=cut

sub format_observation {
	my ($self, $observation) = @_;

	my $string = $observation->name . ":\n";

	try {
		$string .= "  " . $observation->value;
	}
	catch {
		s/^/    /mg;            # indent confession
		# $string .= "  ...\n"; # prepend exception.inspect()
		$string .= $_;          # return formatted confession
	}

	return $string;
}

=begin ruby

  module RaiseOnMismatch
    # Set this flag to raise on experiment mismatches.
    #
    # This causes all science mismatches to raise a MismatchError. This is
    # intended for test environments and should not be enabled in a production
    # environment.
    #
    # bool - true/false - whether to raise when the control and candidate mismatch.
    def raise_on_mismatches=(bool)
      @raise_on_mismatches = bool
    end

    # Whether or not to raise a mismatch error when a mismatch occurs.
    def raise_on_mismatches?
      @raise_on_mismatches
    end
  end

=end ruby

=cut

# package RaiseOnMismatch;

has raise_on_mismatches => (
	is        => 'ro',
	isa       => 'Bool',
	# default => 0;
);

=begin ruby

  def self.included(base)
    base.extend RaiseOnMismatch
  end

=end ruby

=cut

# skip

=begin ruby

  # Define a block of code to run before an experiment begins, if the experiment
  # is enabled.
  #
  # The block takes no arguments.
  #
  # Returns the configured block.
  def before_run(&block)
    @_scientist_before_run = block
  end

=end ruby

=cut

has before_run => (
	traits => ['Code'],
	is     => 'ro',
	# skip _scientist_before_run
);

=begin ruby

  # A Hash of behavior blocks, keyed by String name. Register behavior blocks
  # with the `try` and `use` methods.
  def behaviors
    @_scientist_behaviors ||= {}
  end

=end ruby

=cut

has _scientist_behaviors => (
	traits  => ['Hash'],
	is      => 'ro',
	isa     => 'HashRef[CodeRef]',
	default => {},
);

=begin ruby

  # A block to clean an observed value for publishing or storing.
  #
  # The block takes one argument, the observed value which will be cleaned.
  #
  # Returns the configured block.
  def clean(&block)
    @_scientist_cleaner = block
  end

=end ruby

=cut

has clean => (
	traits    => ['Code'],
	is        => 'ro',
	predicate => 'has_clean',
	# skip: "_scientist_cleaner"
);

=begin ruby

  # Internal: Clean a value with the configured clean block, or return the value
  # if no clean block is configured.
  #
  # Rescues and reports exceptions in the clean block if they occur.
  def clean_value(value)
    if @_scientist_cleaner
      @_scientist_cleaner.call value
    else
      value
    end
  rescue StandardError => ex
    raised :clean, ex
    value
  end

=end ruby

=cut

sub clean_value {
	my ($self, $value) = @_;

	return $value unless $self->has_clean;

	my ($cleaned_value, $error);
	try {
		$cleaned_value = $self->clean->execute($value);
	}
	catch {
		# TODO: rescue
	};

	return $cleaned_value || $error;

}

=begin ruby

  # A block which compares two experimental values.
  #
  # The block must take two arguments, the control value and a candidate value,
  # and return true or false.
  #
  # Returns the block.
  def compare(*args, &block)
    @_scientist_comparator = block
  end

=end ruby

=cut

has compare => (
	traits    => ['Code'],
	is        => 'ro',
	# predicate => 'has_clean',
	# skip: "_scientist_comparator"
);

=begin ruby

  # A Symbol-keyed Hash of extra experiment data.
  def context(context = nil)
    @_scientist_context ||= {}
    @_scientist_context.merge!(context) if !context.nil?
    @_scientist_context
  end

=end ruby

=cut

# XXX In progress:
has context => (
	traits => ['Hash'],
	builder => '_build_context',
);

# XXX In progress:
sub _build_context {
	my ($self, $new_context) = @_;
	$new_context ||= {};
	$self->context->merge($new_context) if keys %$new_context;
}

=begin ruby

  # Configure this experiment to ignore an observation with the given block.
  #
  # The block takes two arguments, the control observation and the candidate
  # observation which didn't match the control. If the block returns true, the
  # mismatch is disregarded.
  #
  # This can be called more than once with different blocks to use.
  def ignore(&block)
    @_scientist_ignores ||= []
    @_scientist_ignores << block
  end

=end ruby

=cut

# TODO

=begin ruby

  # Internal: ignore a mismatched observation?
  #
  # Iterates through the configured ignore blocks and calls each of them with
  # the given control and mismatched candidate observations.
  #
  # Returns true or false.
  def ignore_mismatched_observation?(control, candidate)
    return false unless @_scientist_ignores
    @_scientist_ignores.any? do |ignore|
      begin
        ignore.call control.value, candidate.value
      rescue StandardError => ex
        raised :ignore, ex
        false
      end
    end
  end

=end ruby

=cut



=begin ruby

  # The String name of this experiment. Default is "experiment". See
  # Scientist::Default for an example of how to override this default.
  def name
    "experiment"
  end

  # Internal: compare two observations, using the configured compare block if present.
  def observations_are_equivalent?(a, b)
    if @_scientist_comparator
      a.equivalent_to?(b, &@_scientist_comparator)
    else
      a.equivalent_to? b
    end
  rescue StandardError => ex
    raised :compare, ex
    false
  end

  # Called when an exception is raised while running an internal operation,
  # like :publish. Override this method to track these exceptions. The
  # default implementation re-raises the exception.
  def raised(operation, error)
    raise error
  end

  # Internal: Run all the behaviors for this experiment, observing each and
  # publishing the results. Return the result of the named behavior, default
  # "control".
  def run(name = nil)
    behaviors.freeze
    context.freeze

    name = (name || "control").to_s
    block = behaviors[name]

    if block.nil?
      raise Scientist::BehaviorMissing.new(self, name)
    end

    unless should_experiment_run?
      return block.call
    end

    if @_scientist_before_run
      @_scientist_before_run.call
    end

    observations = []

    behaviors.keys.shuffle.each do |key|
      block = behaviors[key]
      observations << Scientist::Observation.new(key, self, &block)
    end

    control = observations.detect { |o| o.name == name }

    result = Scientist::Result.new self, observations, control

    begin
      publish(result)
    rescue StandardError => ex
      raised :publish, ex
    end

    if self.class.raise_on_mismatches? && result.mismatched?
      raise MismatchError.new(self.name, result)
    end

    if control.raised?
      raise control.exception
    else
      control.value
    end
  end

  # Define a block that determines whether or not the experiment should run.
  def run_if(&block)
    @_scientist_run_if_block = block
  end

  # Internal: does a run_if block allow the experiment to run?
  #
  # Rescues and reports exceptions in a run_if block if they occur.
  def run_if_block_allows?
    (@_scientist_run_if_block ? @_scientist_run_if_block.call : true)
  rescue StandardError => ex
    raised :run_if, ex
    return false
  end

  # Internal: determine whether or not an experiment should run.
  #
  # Rescues and reports exceptions in the enabled method if they occur.
  def should_experiment_run?
    behaviors.size > 1 && enabled? && run_if_block_allows?
  rescue StandardError => ex
    raised :enabled, ex
    return false
  end

  # Register a named behavior for this experiment, default "candidate".
  def try(name = nil, &block)
    name = (name || "candidate").to_s

    if behaviors.include?(name)
      raise Scientist::BehaviorNotUnique.new(self, name)
    end

    behaviors[name] = block
  end

  # Register the control behavior for this experiment.
  def use(&block)
    try "control", &block
  end
end

=end ruby

=cut

__PACKAGE__->meta->make_immutable;

1;

