
######################################################################
## File: $Id: Local.pm,v 1.2 2006/12/08 20:22:43 spadkins Exp $
######################################################################

package Business::Travel::OTA::Transport::Local;

use strict;
use vars qw($VERSION @ISA);

use Business::Travel::OTA::Transport;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("Business::Travel::OTA::Transport");

use Business::Travel::OTA::Dispatcher;

=head1 NAME

Business::Travel::OTA::Transport::Local - Logic for handing messages to the server dispatch locally (without IPC)

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for handing messages to the server dispatch locally (without IPC)

=cut

sub send {
    &App::sub_entry if ($App::trace);
    my ($self, $request_xml, $options) = @_;
    my $dispatcher = Business::Travel::OTA::Dispatcher->new();
    my $response_xml = $dispatcher->execute($request_xml);
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

