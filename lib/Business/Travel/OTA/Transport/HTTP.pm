
######################################################################
## File: $Id: HTTP.pm,v 1.2 2006/12/08 20:22:43 spadkins Exp $
######################################################################

package Business::Travel::OTA::Transport::HTTP;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Transport;
use Business::Travel::OTA;
use LWP::UserAgent;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Transport");

=head1 NAME

Business::Travel::OTA::Transport::HTTP - Logic for transporting messages from a client via simple HTTP

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for transporting messages from a client via simple HTTP

=cut

sub _init {
    &App::sub_entry if ($App::trace);
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
    &App::sub_exit() if ($App::trace);
}

sub send_message {
    &App::sub_entry if ($App::trace);
    my ($self, $request_xml, $request_values, $transport_values) = @_;
    my $verbose = $App::options{verbose};

    my $agent = $self->{agent};
    my $server_url = $transport_values->{server_url} || die "No server_url supplied in transport_values";
    ##################################################################
    # Create a REQUEST
    ##################################################################
    my $req = HTTP::Request->new(POST => $server_url);
    $req->content_length(length($request_xml)); # set Content-length (REQUIRED)
    if (!$App::options{minimal}) {
        $req->content_type("application/xml");  # set Content-type to "application/xml"
    }
    $req->content($request_xml);                # assign the content
    if ($verbose) {
        if ($verbose >= 2) {
            print "##################################################################\n";
            print "# REQUEST:\n";
            print "##################################################################\n";
        }
        if ($verbose >= 3) {
            print $req->as_string;
        }
        elsif ($verbose >= 2) {
            print $request_xml;
        }
        if ($verbose >= 2) {
            print "##################################################################\n";
        }
    }


    ##################################################################
    # Send REQUEST and get a RESPONSE
    ##################################################################
    my $res = $agent->request($req);  # handles Basic Authentication/SSL
    my $response_xml = $res->content();

    if ($verbose) {
        if ($verbose >= 2) {
            print "##################################################################\n";
            print "# RESPONSE:\n";
            print "##################################################################\n";
        }
        if ($verbose >= 3) {
            print $res->as_string;
        }
        else {
            print $response_xml;
        }
        if ($verbose >= 2) {
            print "##################################################################\n";
            print "[", $res->status_line(), "]\n";
        }
    }

    &App::sub_exit($response_xml) if ($App::trace);
    return($response_xml);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

