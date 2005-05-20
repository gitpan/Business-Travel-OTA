
#############################################################################
## File: $Id: Client.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Client;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

=head1 NAME

Business::Travel::OTA::Client - Base class for all OTA clients

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Base class for all OTA clients

=cut


sub new {
    my $this = shift;      # might be a package string or an object reference
    my $class = ref($this) || $this;                          # get the class

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

    $self->init();

    return $self;
}

sub init {
    my ($self) = @_;
    # override this if appropriate in a subclass
}

sub send {
    my ($self, $request_xml) = @_;
    # this method is for overriding in a subclass that knows the protocol
    die "send(): don't know what protocol to use";
    my $response_xml = "<NotImplemented />";
    return($response_xml);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2005 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

