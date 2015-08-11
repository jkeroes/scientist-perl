package Scientist::Default;

=begin ruby

require "scientist/experiment"

# A null experiment.
class Scientist::Default
  include Scientist::Experiment

=end ruby

=cut

use Moose;
use namespace::autoclean;

use Scientist::Experiment;

=begin ruby

  attr_reader :name

  def initialize(name)
    @name = name
  end

=end ruby

=cut

has name => (
    is  => 'ro',
    isa => 'Str',
);

=begin ruby

  # Run everything every time.
  def enabled?
    true
  end

=end ruby

=cut

has is_enabled => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

=begin ruby

  # Don't publish anything.
  def publish(result)
  end
end

=end ruby

=cut

sub publish {
	return;
}

__PACKAGE__->meta->make_immutable;

1;

