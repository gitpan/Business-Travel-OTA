
#############################################################################
## File: $Id: Client.pm,v 1.1 2005/05/05 19:46:02 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Client;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};


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

    return $self;
}

sub send {
    my ($request_xml) = @_;
    # this method is for overriding in a subclass that knows the protocol
    die "send(): don't know what protocol to use";
    my $response_xml = "<NotImplemented />";
    return($response_xml);
}

use XML::Simple;

1;

