
######################################################################
## File: $Id: General.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA::Dispatcher::General;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Dispatcher;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Dispatcher");

use File::Path;
use Business::Travel::OTA::Utils qw(outer_tag parse substitute read_file);

=head1 NAME

Business::Travel::OTA::Dispatcher::General - The General Dispatcher replies to OTA Request messages according to configuration files rather than hard-coded logic. It is useful for a test server or as a base class for a customized server.

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

This server class contains logic to process incoming OTA Request messages and reply with
reasonable OTA Response messages.  It parses the information on the Request message,
chooses an appropriate canned Response message which has been preformatted, makes a few
substitutions so that the content of the Response corresponds to the content of the 
Request, and replies with the message.

This is a General Dispatcher because it is driven by configuration files. This may or may not
be sufficient for a full production server.
It is smart enough to allow a user to make a decent test server so that he can test his client
software against it.
It may also serve as a base class for a customized Dispatcher.

=head1 METHODS

=head2 execute()

 * Signature: $dispatcher->execute($request_xml)
 * Param:     $request_xml      SCALAR
 * Returns:   $response_xml     SCALAR

=cut

sub execute {
    &App::sub_entry if ($App::trace);
    my ($self, $request_xml) = @_;

    my ($response_xml);
    eval {
        my $ota_message_dir = $App::options{ota_message_dir} || "$App::options{prefix}/share/ota/message";
        mkpath($ota_message_dir) if (! -d $ota_message_dir);

        my $request_tag = &outer_tag($request_xml);

        my $response_tag = $request_tag;
        $response_tag =~ s/RQ/RS/;

        my $request = &parse($request_xml);
        my $response_file = "$ota_message_dir/$response_tag.xml";
        $response_xml = &read_file($response_file);
        $response_xml = &substitute($response_xml, $request);
    };
    if ($@) {
        $response_xml = $self->_OTA_error($@);
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

