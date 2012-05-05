package Log::Stash::Role::Input;
use Moo::Role;
use JSON qw/ from_json /;
use Sub::Quote;
use namespace::autoclean;

sub decode { from_json( $_[1], { utf8  => 1 } ) }

has output_to => (
    isa => quote_sub(q{ die $_[0] . "Does not have a ->consume method" unless blessed($_[0]) && $_[0]->can('consume') }),
    is => 'ro',
    required => 1,
    # FIXME - We need to be able to coerce from HashRef here
    # coerce => 1
);

1;

=head1 NAME

Log::Stash::Role::Input

=head1 DESCRIPTION

Produces messages.

=head1 ATTRIBUTES

=head2 output_to

Required, must perform the L<Log::Stash::Role::Output> role.

=head1 METHODS

=head2 decode

JSON decodes a message supplied as a parameter.

=head1 SEE ALSO

=over

=item L<Log::Stash>

=item L<Log::Stash::Manual::Concepts>

=back

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

