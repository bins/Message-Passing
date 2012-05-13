package Log::Stash::Filter::T;
use Moo;
use List::MoreUtils qw/ all /;
use Scalar::Util qw/ blessed /;
use namespace::clean -except => 'meta';

has 'output_to' => (
    isa => sub {
        ref($_[0]) eq 'ARRAY' and all { $_->can('output_to') } @{$_[0]};
    },
    coerce => sub {
        [ map {
            if (ref($_) eq 'HASH') {
                my %stuff = %{$_};
                my $class = delete($stuff{class});
                Module::Runtime::use_module($class);
                $class->new(%stuff);
            }
            else {
                $_
            }
         } @{ $_[0] } ];
    },
    is => 'ro',
    required => 1,
);

with qw/
    Log::Stash::Role::Output
/;

sub consume {
    my ($self, $message) = @_;
    foreach my $output_to (@{ $self->output_to }) {
        $output_to->consume($message);
    }
}

1;

=head1 NAME

Log::Stash::Filter::T - Send a message stream to multiple outputs.

=head1 DESCRIPTION

This filter is used to duplicate a message stream to two or more outputs.

All messages are duplicated to all output streams, so you may want to follow
this with L<Log::Stash::Filter::Key> to one or more of those streams.

=head1 ATTRIBUTES

=head2 output_to

Just like a normal L<Log::Stash::Role::Input> class, except takes an array of outputs.

=head1 METHODS

=head2 consume

Sends the consumed message to all output_to instances.

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored it's development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut

1;

