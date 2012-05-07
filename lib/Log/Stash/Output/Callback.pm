package Log::Stash::Output::Callback;
use Moo;
use MooX::Types::MooseLike::Base qw/ CodeRef /;
use namespace::clean -except => 'meta';

has cb => (
    isa => CodeRef,
    is => 'ro',
);

sub consume {
    my ($self, $msg) = @_;
    $self->cb->($msg);
}

with 'Log::Stash::Role::Output';

1;

=head1 NAME

Log::Stash::Output::Callback - Output to call back into your code

=head1 SYNOPSIS

    Log::Stash::Output::Callback->new(
        cb => sub {
            my $message = shift;
        },
    );

=head1 SEE ALSO

L<Log::Stash>

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

