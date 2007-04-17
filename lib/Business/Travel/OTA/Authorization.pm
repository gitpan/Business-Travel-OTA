
#############################################################################
## File: $Id: Authorization.pm,v 1.2 2006/12/08 20:22:43 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Authorization;

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Service;

@ISA = qw(App::Service);

=head1 NAME

Business::Travel::OTA::Authorization - Base class for OTA authorization approaches

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Base class for OTA authorization approaches

=cut

sub is_authorized {
    &App::sub_entry if ($App::trace);
    my ($self, $username) = @_;
    my $is_authorized = 1;
    &App::sub_exit($is_authorized) if ($App::trace);
    return($is_authorized);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

