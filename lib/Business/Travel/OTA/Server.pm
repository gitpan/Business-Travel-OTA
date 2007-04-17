
#############################################################################
## File: $Id: Server.pm,v 1.1 2006/04/19 03:59:32 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Server;

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Service;
use Business::Travel::OTA::Transport;

@ISA = qw(App::Service);

=head1 NAME

Business::Travel::OTA::Server - Base class for all OTA servers

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Base class for all OTA servers

=cut

sub send {
    &App::sub_entry if ($App::trace);
    my ($self, $request_xml) = @_;
    my $context = $self->{context};
    my $transport = $context->ota_transport($self->{transport});
    my $server_url = $self->{server_url};
    my $transport_options = $self;
    my $response_xml = $transport->send($request_xml, $transport_options);
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

