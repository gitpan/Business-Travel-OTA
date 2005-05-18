
######################################################################
## File: $Id: Local.pm,v 1.1 2005/05/17 18:16:29 spadkins Exp $
######################################################################

package Business::Travel::OTA::Client::Local;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Client;

$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Client");

use Business::Travel::OTA::Server;

sub send {
    my ($self, $request_xml) = @_;
    my $server = Business::Travel::OTA::Server->new();
    my $response_xml = $server->execute($request_xml);
    return($response_xml);
}

1;

