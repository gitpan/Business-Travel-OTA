
######################################################################
## File: $Id: HTTP.pm,v 1.1 2005/05/05 19:46:02 spadkins Exp $
######################################################################

package Business::Travel::OTA::Client::HTTP;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Client;

$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Client");

sub send {
    my ($request_xml) = @_;
    my $verbose = $App::options{verbose};

    ##################################################################
    # Create a USER-AGENT
    ##################################################################
    my $agent = LWP::UserAgent->new();

    ##################################################################
    # Create a REQUEST
    ##################################################################
    my $req = HTTP::Request->new(POST => $App::options{responder});
    $req->content_length(length($request_xml)); # set Content-length (REQUIRED)
    if (!$App::options{minimal}) {
        $req->content_type("application/xml");  # set Content-type to "application/xml"
    }
    $req->content($request_xml);                # assign the content
    print "REQUEST:\n", $req->as_string if ($verbose);

    ##################################################################
    # Send REQUEST and get a RESPONSE
    ##################################################################
    my $res = $agent->request($req);  # handles Basic Authentication/SSL
    my $response_xml = $res->content();

    if ($verbose) {
        print "RESPONSE:\n", $res->as_string;
        if ($res->is_success()) {
            print $response_xml;
        }
        else {
            print $res->status_line(), "\n";
        }
    }

    return($response_xml);
}

1;

