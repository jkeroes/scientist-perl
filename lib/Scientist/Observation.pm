package Scientist::Observation;

=begin ruby

# What happened when this named behavior was executed? Immutable.
class Scientist::Observation

=end ruby

=cut

use Moose;
use Try::Tiny;

=begin ruby

  # The experiment this observation is for
  attr_reader :experiment

  # The instant observation began.
  attr_reader :now

  # The String name of the behavior.
  attr_reader :name

  # The value returned, if any.
  attr_reader :value

  # The raised exception, if any.
  attr_reader :exception

  # The Float seconds elapsed.
  attr_reader :duration

=end ruby

=cut

has experiment => (
	is  => 'ro',
	isa => 'Scientist::Experiment',
);

has now => (
	is  => 'ro',
	# isa => '',
	builder => '_build_now',
);

# TODO What kind of time should we return?
sub _build_now {
	return time;
}

has name => (
	is  => 'ro',
	isa => 'Str'
);

has value => (
	is  => 'ro',
	isa => 'Str'
);


# has exception => (
# 	is  => 'ro',
# 	isa => 'Scientist::Exception',
# 	builder => '_build_exception',
# );

# sub _build_exception {
# 	return Scientist::Exception->new;
# }

has duration  => (
	is  => 'ro',
	isa => 'Num',
);

=begin ruby

  def initialize(name, experiment, &block)
    @name       = name
    @experiment = experiment
    @now        = Time.now

    begin
      @value = block.call
    rescue Object => e
      @exception = e
    end

    @duration = (Time.now - @now).to_f

    freeze
  end

=end ruby

=cut

sub BUILD {
	my $self = shift;

	my ($value, $exception);
	try {
		$value = $self->block->();
	}
	catch {
		# TODO: read about rescue and figure out what to do with the exception now.
		$exception = $_;
	};

	$self->value($value);
	$self->duration($self->now - time);
}

__PACKAGE__->meta->make_immutable;

1;
