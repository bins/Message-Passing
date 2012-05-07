package Log::Stash::Output::Test;
use Moo;
use MooX::Types::MooseLike::Base qw/ ArrayRef /;
use namespace::clean -except => 'meta';

extends 'Log::Stash::Output::Callback';

has '+cb' => (
    default => sub { sub {} },
);

has messages => (
    isa => ArrayRef,
    default => sub { [] },
#    traits => ['Array'],
#    handles => {
#        consume_test => 'push',
#        message_count => 'count',
#        messages => 'elements',
#    },
    clearer => 'clear_messages',
    lazy => 1,
);

sub messages { @{$_[0]->{messages}} }
sub consume_test { push(@{$_[0]->{messages}}, $_[1]) }
sub message_count { scalar  @{$_[0]->{messages}} }

after consume => sub {
    shift()->consume_test(@_);
};

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Log::Stash::Output::Test - Output for use in unit tests

=head1 SYNOPSIS

    You only want this if you're writing tests...
    See the current tests for examples..

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

