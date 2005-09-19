
######################################################################
## File: $Id: SOAP.pm,v 1.2 2005/09/19 02:54:18 spadkins Exp $
######################################################################

package Business::Travel::OTA::Client::SOAP;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Client;
use Business::Travel::OTA;

my (@options);

BEGIN {
    @options = ( +trace => [ "all" ] ) if ($App::options{debug});
}

use SOAP::Lite @options;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Client");

=head1 NAME

Business::Travel::OTA::Client::SOAP - Logic for transporting messages from a client via simple SOAP

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for transporting messages from a client via simple SOAP

=cut

sub send {
    my ($self, $request_xml) = @_;

    my $uri   = $App::options{soap_uri}   || "http://localhost/Business/Travel/OTA/Server";
    my $proxy = $App::options{soap_proxy} || "http://localhost/cgi-bin/otasoap";

    my ($response, $response_xml);

    #$response_xml = SOAP::Lite
    #    -> uri($uri)
    #    -> proxy($proxy)
    #    -> execute($request_xml)
    #    -> result;

    if ($App::options{with_attachments}) {
        # This is the SOAP-with-Attachments approach that considers the XML message
        # to be a MIME-encoded attachment. It works, and results in no escaping of
        # the XML (as long as the MIME encoding is binary).  However, the interoperability
        # is problematic with older versions of Win32 toolkits which rely exclusively
        # on DIME-encoding rather than MIME-encoding.

        # Encoding:        | Normally used when message contents are:
        # -------------------------------------------------------------------
        # 7bit             | 7-bit data with under 1000 chars/line, or multipart.
        # 8bit             | 8-bit data with under 1000 chars/line.
        # binary           | 8-bit data with some long lines (or no line breaks).
        # quoted-printable | Text files with some 8-bit chars (e.g., Latin-1 text).
        # base64           | Binary files.

        require "MIME/Entity.pm";  # only load if required
        my $request_entity = MIME::Entity->build(
            Type        => "text/xml",
            Charset     => "utf-8",
            Encoding    => "binary",          # binary, 8bit, base64, ...
            Data        => $request_xml,
            #Filename    => "ota_request.xml",
            #Path        => "/path/to/ota_request.xml",
            Id          => "<request>",
            Disposition => "inline",    # attachment/inline
        );
        print "#### REQ_ENT=[$request_entity]\n" if ($App::options{verbose});

        $response = SOAP::Lite
            -> uri($uri)
            -> proxy($proxy)
            -> parts($request_entity)
            -> call("execute","<hi />");
    }
    else {
        # This is the simple SOAP approach that considers the XML message to be
        # a simple string argument.  It works, and its portability is good (between
        # SOAP::Lite and Win32 toolkits), but the message XML has to be
        # wrapped in an XML envelope.
        # This results in escaping of every angle bracket and quote in the document.
        $response = SOAP::Lite
            -> uri($uri)
            -> proxy($proxy)
            -> call("execute", $request_xml);
    }

    if ($response->fault) {
        $response_xml = "[" . $response->faultcode() . "] " . $response->faultstring();
    }
    else {
        $response_xml = $response->result();
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

