
#############################################################################
## File: $Id: Message.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Message;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

=head1 NAME

Business::Travel::OTA::Message - Helper class to parse and build XML messages

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Helper class to parse and build XML messages.

=cut


sub new {
    &App::sub_entry if ($App::trace);
    my $this = shift;      # might be a package string or an object reference
    my $class = ref($this) || $this;                          # get the class

    my ($message_info, $message_file);
    if ($#_ >= 0 && ref($_[0]) eq "") {         # if first arg is a scalar...
        $message_info = shift;                   # it is a message (or file?)
    }

    my (@initial_values);
    if ($#_ >= 0 && ref($_[0]) eq "HASH") {    # if first arg is a hashref...
        my $initial_values = shift;    # it is a set of initial attrib values
        @initial_values = { %$initial_values };
    }

    if ($#_ >= 0 && $#_ % 2 == 1) {             # an even number of args left
        push(@initial_values,@_);
    }

    my $self = { @initial_values };             # create new object reference
    bless $self, $class;                   # bless it into the required class

    &App::sub_exit($self) if ($App::trace);
    return $self;
}

sub parse {
    &App::sub_entry if ($App::trace);
    my ($self, $values) = @_;
    &App::sub_exit() if ($App::trace);
}

sub build {
    &App::sub_entry if ($App::trace);
    my ($self, $values) = @_;
    &App::sub_exit() if ($App::trace);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

