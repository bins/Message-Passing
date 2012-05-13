package Log::Stash::Utils;
use strict;
use warnings;
use String::RewritePrefix;

use Exporter qw/ import unimport /;

our @EXPORT_OK = qw/
    expand_class_name
/;

sub expand_class_name {
    my ($type, $name) = @_;
    String::RewritePrefix->rewrite({
        '' => 'Log::Stash::' . $type . '::',
        '+' => ''
    }, $name);
}

1;

