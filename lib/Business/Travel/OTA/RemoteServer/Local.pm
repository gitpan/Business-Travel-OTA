
######################################################################
## File: $Id: Local.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA::Client::Local;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Client;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Client");

use Business::Travel::OTA::Server;

=head1 NAME

Business::Travel::OTA::Client::Local - Logic for handing messages to the server dispatch locally (without IPC)

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for handing messages to the server dispatch locally (without IPC)

=cut

sub send {
    my ($self, $request_xml) = @_;
    my $server = Business::Travel::OTA::Server->new();
    my $response_xml = $server->execute($request_xml);
    return($response_xml);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

