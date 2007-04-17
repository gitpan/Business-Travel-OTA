
######################################################################
## File: $Id: RemoteServer.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA::RemoteServer;

use strict;
use vars qw($VERSION @ISA);

use App::Service;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("App::Service");

=head1 NAME

Business::Travel::OTA::RemoteServer - Logic for handing messages to a remote server

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for handing messages to a remote server.

=cut

sub send {
    &App::sub_entry if ($App::trace);
    my ($self, $request_xml, $request_values) = @_;
    my $context      = $self->{context};
    my $transport    = $context->transport($self->{transport});
    my $req_message  = $transport->wrap_message($request_xml, $request_values);
    my $res_message  = $transport->send_message($req_message, $request_values, $self->{transport_values});
    my $response_xml = $transport->unwrap_message($res_message, $request_values);
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

