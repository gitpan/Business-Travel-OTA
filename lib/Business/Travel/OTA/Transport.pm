
#############################################################################
## File: $Id: Transport.pm,v 1.2 2006/12/08 20:22:43 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Transport;

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Service;

@ISA = qw(App::Service);

=head1 NAME

Business::Travel::OTA::Transport - Base class for all OTA transport protocols

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Base class for all OTA transport protocols

=cut

sub send_message {
    &App::sub_entry if ($App::trace);
    my ($self, $msg_string, $request_values, $transport_values) = @_;
    die "send_message() not yet implemented";
    &App::sub_exit($msg_string) if ($App::trace);
    return($msg_string);
}

sub wrap_message {
    &App::sub_entry if ($App::trace);
    my ($self, $msg_string, $request_values) = @_;
    # default: do nothing (add no envelope)
    &App::sub_exit($msg_string) if ($App::trace);
    return($msg_string);
}

sub unwrap_message {
    &App::sub_entry if ($App::trace);
    my ($self, $msg_string, $request_values) = @_;
    # default: do nothing (remove no envelope)
    &App::sub_exit($msg_string) if ($App::trace);
    return($msg_string);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

