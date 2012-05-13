package Log::Stash::DSL::Factory;
use Moo;
use Log::Stash::Utils qw/ expand_class_name /;
use MooX::Types::MooseLike::Base qw/ HashRef /;
use Module::Runtime ();
use Scalar::Util qw/ blessed /;
use namespace::clean -except => 'meta';

has registry => (
    is => 'ro',
    isa => HashRef,
    default => sub { {} },
    lazy => 1,
    clearer => 'clear_registry',
);

sub registry_get { $_[0]->registry->{$_[1]} }
sub registry_has { exists($_[0]->registry->{$_[1]}) }
sub registry_set { $_[0]->registry->{$_[1]} = $_[2] }

sub make {
    my ($self, %opts) = @_;
    my $class = delete $opts{class}
        || confess("Class name needed");
    my $name = delete $opts{name};
    my $type = delete $opts{type};
    confess("We already have a thing named $name")
        if $self->registry_has($name);
    my $output_to = $opts{output_to};
    if ($output_to && !blessed($output_to)) {
        # We have to deal with the ARRAY case here for Filter::T
        if (ref($output_to) eq 'ARRAY') {
            my @out;
            foreach my $name_or_thing (@$output_to) {
                if (blessed($name_or_thing)) {
                    push(@out, $name_or_thing);
                }
                else {
                    my $thing = $self->registry_get($name_or_thing)
                        || confess("Do not have a component named '$name_or_thing'");
                    push(@out, $thing);
                }
            }
            $opts{output_to} = \@out;
        }
        else {
            my $proper_output_to = $self->registry_get($output_to)
                || confess("Do not have a component named '$output_to'");
            $opts{output_to} = $proper_output_to;
        }
    }
    $class = expand_class_name($type, $class);
    Module::Runtime::use_module($class);
    my $out = $class->new(%opts);
    $self->registry_set($name, $out);
    return $out;
}

1;

=head1 NAME

Log::Stash::DSL::Factory - Build a set of logstash chains using symbolic names

=head1 DESCRIPTION

No user serviceable parts inside. See L<Log::Stash::DSL>.

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored it's development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut

