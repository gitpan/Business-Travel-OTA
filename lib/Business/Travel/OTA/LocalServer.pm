
#############################################################################
## File: $Id: LocalServer.pm,v 1.2 2006/12/08 20:22:43 spadkins Exp $
#############################################################################

package Business::Travel::OTA::LocalServer;

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Service;

@ISA = qw(App::Service);

=head1 NAME

Business::Travel::OTA::LocalServer - Base class for logic to process messages and send replies

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Base class for logic to process messages and send replies.

=cut

sub dispatch_message {
    &App::sub_entry if ($App::trace);
    my ($self, $request_xml) = @_;

    #my $request_tag = &outer_tag($request_xml);
    # my $doc = &parse($request_xml);

    my $response_xml = &_OTA_ping();

    &App::sub_exit($response_xml) if ($App::trace);
    return($response_xml);
}

# HERE ONLY TEMPORARILY
sub _OTA_ping {
    &App::sub_entry if ($App::trace);
    my ($self, $message) = @_;
    $message ||= "Hello";
    my $response_xml = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<OTA_PingRS
    xmlns="http://www.opentravel.org/OTA/2003/05"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opentravel.org/OTA/2003/05 C:/OTA/2003B/20021031/OTA_PingRS.xsd"
    TimeStamp="2002-12-03T11:09:49-05:00"
    Target="Production"
    Version="1.0"
    SequenceNmbr="1" >
  <Success/>
  <EchoData>$message</EchoData>
</OTA_PingRS>
EOF
    &App::sub_exit($response_xml) if ($App::trace);
    return($response_xml);
}

sub _OTA_error {
    &App::sub_entry if ($App::trace);
    my ($self, $message) = @_;
    $message ||= "Error";
    my $response_xml = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<OTA_ErrorRS
    xmlns="http://www.opentravel.org/OTA/2002/08"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opentravel.org/OTA/2002/08 C:/OTA/2003B/20021031/OTA_Ping.xsd"
    TimeStamp="2002-12-03T11:09:49-05:00"
    Target="Production"
    Version="2002A"
    SequenceNmbr="1" >
  <Success/>
  <EchoData>$message</EchoData>
</OTA_ErrorRS>
EOF
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

