
#############################################################################
## File: $Id: Server.pm,v 1.1 2005/05/17 18:16:29 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Server;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use Business::Travel::OTA::Utils qw(outer_tag parse);

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

sub execute {
    my ($self, $request_xml) = @_;

    my $request_tag = &outer_tag($request_xml);
    my $doc = &parse($request_xml);

    my $response_xml = &OTA_ping();

    return($response_xml);
}

# HERE ONLY TEMPORARILY
sub OTA_ping {
    my $response = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<OTA_PingRS
    xmlns="http://www.opentravel.org/OTA/2002/08"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opentravel.org/OTA/2002/08 C:/OTA/2003B/20021031/OTA_Ping.xsd"
    TimeStamp="2002-12-03T11:09:49-05:00"
    Target="Production"
    Version="2002A"
    SequenceNmbr="1" >
  <Success/>
  <EchoData>Are you There</EchoData>
</OTA_PingRS>
EOF
    return($response);
}

1;
