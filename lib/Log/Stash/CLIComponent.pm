package Log::Stash::CLIComponent;
use strict;
use warnings;
use Import::Into;
use Carp qw/ confess /;
use MooX::Options ();
use namespace::clean;

sub import {
    my ($class, @opts) = @_;
    my $target = caller;
    if (scalar(@opts) % 2 != 0) {
        confess "Uneven number of options";
    }
    my %opts = @opts;
    my $name = $opts{name};
    confess("Must have a name") unless $name;
    my $default = $opts{default} || '';
    my $injected_moo = 0;
    if (!$target->can('option')) {
        MooX::Options->import::into($target);
        $injected_moo = 1;
    }
    my $code = qq{
        package $target;
        use MooX::Types::MooseLike::Base qw/ Str /;
        use JSON ();
        package $target;
        option $name => (
            isa => Str,
            is => 'rw',
            required => '$default' ? 0 : 1,
            '$default' ? ( default => sub { '$default' } ) : (),
            format => 's',
        );
        option "${name}_options" => (
            default => sub { {} },
            is => 'ro',
            coerce => sub {
                return \$_[0] if ref(\$_[0]);
                JSON->new->relaxed->decode(\$_[0]);
            },
            format => 's',
        );
    };
    #warn $code;
    eval $code;
    die $@ if $@;
    if ($injected_moo) {
        MooX::Options->unimport::out_of($target);
    }
}

1;

