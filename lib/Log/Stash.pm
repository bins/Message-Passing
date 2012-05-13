package Log::Stash;
use Moo;
use JSON ();
use Getopt::Long qw(:config pass_through);
use namespace::clean -except => 'meta';
use Log::Stash::Utils qw/ expand_class_name /;
use Module::Runtime ();
use 5.8.4;

with 'MooseX::Getopt';

our $VERSION = '0.002';
$VERSION = eval $VERSION;

sub build_chain {
    my $self = shift;
    use Data::Dumper;
    my $input_class = expand_class_name('Input', $self->input);
    my $output_class = expand_class_name('Output', $self->output);
    my $filter_class = expand_class_name('Filter', $self->filter);
    Module::Runtime::use_module($input_class);
    Module::Runtime::use_module($output_class);
    Module::Runtime::use_module($filter_class);
    $input_class->new(%{$self->input_options}, output_to =>
        $filter_class->new(%{$self->filter_options}, output_to =>
            $output_class->new(%{$self->output_options})
        )
    );
}

use Log::Stash::CLIComponent (name => 'input');
use Log::Stash::CLIComponent (name => 'output');
use Log::Stash::CLIComponent (name => 'filter', default => 'Null');

1;

=head1 NAME

Log::Stash - a perl subset of Logstash <http://logstash.net>

=head1 SYNOPSIS

    logstash --input STDIN --output STDOUT
    {"foo": "bar"}
    {"foo":"bar"}

=head1 DESCRIPTION

A lightweight but inter-operable subset of logstash
L<http://logstash.net>

This implementation is currently a prototype, and as such should be considered
alpha and subject to change at any point.

=head2 BASIC PREMISE

You have data for discrete events, represented by a hash (and
serialized as JSON).

This could be a text log line, an audit record of an API
event, a metric emitted from your application that you wish
to aggregate and process - anything that can be a simple hash really..

You want to be able to shove these events over the network easily,
and aggregate them / filter and rewrite them / split them into worker queues.

This module is designed as a simple framework for writing components
that let you do all of these things, in a simple and easily extensible
manor.

For a practical example, You generate events from a source (e.g.
ZeroMQ output of logs and performance metrics from your Catalyst FCGI
or Starman workers) and run one script that will give you a central
application log file, or push the logs into L<ElasticSearch>.

There are a growing set of components you can plug together
to make your logging solution.

Getting started is really easy - you can just use the C<logstash>
command installed by the distribution. If you have a common config
that you want to repeat, or you want to write your own server
which does something more flexible than the normal script allows,
then see L<Log::Stash::DSL>.

To dive straight in, see the documentation for the command line utility
L<logstash>, and see the examples in L<Log::Stash::Manual::Cookbook>.

For more about how the system works, see L<Log::Stash::Manual::Concepts>.

=head1 COMPONENTS

Below is a non-exhaustive list of components available.

=head2 INPUTS

Inputs receive data from a source (usually a network protocol).

They are responsible for decoding the data into a hash before passing
it onto the next stage.

Inputs include:

=over

=item L<Log::Stash::Input::STDIN>

=item L<Log::Stash::Input::ZeroMQ>

=item L<Log::Stash::Input::Test>

=back

You can easily write your own input, just use L<AnyEvent>, and
consume L<Log::Stash::Role::Input>.

=head2 FILTER

Filters can transform a message in any way.

Examples include:

=over

=item L<Log::Stash::Filter::Null> - Returns the input unchanged.

=item L<Log::Stash::Filter::All> - Stops any messages it receives from being passed to the output. I.e. literally filters all input out.

=item L<Log::Stash::Filter::T> - Splits the incoming message to multiple outputs.

=back

You can easily write your own filter, just consume
L<Log::Stash::Role::Filter>.

Note that filters can be chained, and a filter can return undef to
stop a message being passed to the output.

=head2 OUTPUTS

Outputs send data to somewhere, i.e. they consume messages.

=over

=item L<Log::Stash::Output::STDOUT>

=item L<Log::Stash::Output::AMQP>

=item L<Log::Stash::Output::ZeroMQ>

=item L<Log::Stash::Output::WebHooks>

=item L<Log::Stash::Output::ElasticSearch>

=item L<Log::Stash::Output::Test>

=back

=head1 SEE ALSO

=over

=item L<Log::Message::Structured> - For creating your log messages.

=item L<Log::Dispatch::Log::Stash> - use Log::Stash outputs from L<Log::Dispatch>.

=back

=head1 THIS MODULE

This is a simple L<MooseX::Getopt> script, with one input, one filter
and one output.

=head2 METHODS

=head3 build_chain

Builds and returns the configured chain of input => filter => output

=head3 start

Class method to call the run_log_server function with the results of
having constructed an instance of this class, parsed command line options
and constructed a chain.

This is the entry point for the logstash script.

=head1 AUTHOR

Tomas (t0m) Doran <bobtfish@bobtfish.net>

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored it's development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 COPYRIGHT

Copyright Suretec Systems Ltd. 2012.

Logstash (upon which many ideas for this project is based, but
which we do not reuse any code from) is copyright 2010 Jorden Sissel.

=head1 LICENSE

GNU Affero General Public License, Version 3

If you feel this is too restrictive to be able to use this software,
please talk to us as we'd be willing to consider re-licensing under
less restrictive terms.

=cut

1;

