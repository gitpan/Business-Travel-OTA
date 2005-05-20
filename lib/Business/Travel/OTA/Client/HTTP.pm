
######################################################################
## File: $Id: HTTP.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA::Client::HTTP;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Client;
use Business::Travel::OTA;
use LWP::UserAgent;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Client");

=head1 NAME

Business::Travel::OTA::Client::HTTP - Logic for transporting messages from a client via simple HTTP

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for transporting messages from a client via simple HTTP

=cut

sub init {
    my ($self) = @_;
    ##################################################################
    # Create a USER-AGENT
    ##################################################################
    my $agent = LWP::UserAgent->new();

    $agent->agent("OTA-Tools/$Business::Travel::OTA::VERSION (http://sourceforge.net/projects/ota-tools)");
    # This would cause the User-agent: header not to be sent
    # $agent->agent("");
    # This would append the libwww-perl version
    # $agent->agent("OTA-Tools/0.50 (http://sourceforge.net/projects/ota-tools) " .
    #     $agent->_agent());
    $self->{agent} = $agent;
}

sub send {
    my ($self, $request_xml) = @_;
    my $verbose = $App::options{verbose};

    my $agent = $self->{agent};
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

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2005 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

