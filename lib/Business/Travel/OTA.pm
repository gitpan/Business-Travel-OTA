
######################################################################
## File: $Id: OTA.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA;

use strict;
use vars qw($VERSION);

# This module version number serves as the version number for the
# distribution.  I did this so that it would be available for 
# programmatic use.

$VERSION = "0.52";

=head1 NAME

Business::Travel::OTA - Tools for handling OTA-compliant (Open Travel Alliance) messages

=head1 SYNOPSIS

  # This tests the "otaserver" with an OTA_PingRQ message
  otaclient --ping --verbose

=head1 DESCRIPTION

The Business::Travel::OTA module is the main module for the Business-Travel-OTA
distribution in the OTA-Tools project.
Your can see the project web site at SourceForge.

  http://sourceforge.net/projects/ota-tools

The OTA-Tools project is a
set of software tools useful for building, testing, and exercising web
services (and other interfaces) for the travel industry which comply with the
specifications of the Open Travel Alliance (OTA).
You can see the OTA web site here.

  http://www.opentravel.org

This project is initiated by members of the OTA, but it is not an 
official project of the OTA.  It represents an opportunity for
OTA members to collaborate on tools, test suites, and reference
implementation software for the purposes of reducing the learning
curve for newcomers and enhancing interoperability.

The Business-Travel-OTA distribution is a set of Perl modules and programs
which demonstrate the creation, validation, transmission, processing, parsing,
and manipulation of OTA messages.  This software also implements reference
client and server capabilities which can be adapted as necessary.

=head1 OVERVIEW

Programs:

  otaclient - [bin] submit OTA messages to an OTA server
  otaserver - [cgi-bin] respond to OTA messages sent by a client

Modules:

  Business::Travel::OTA - this documentation (no code yet)
  Business::Travel::OTA::Utils - some useful functions
  Business::Travel::OTA::Client - base class for the OTA client logic
  Business::Travel::OTA::Client::HTTP - transports messages via simple HTTP
  Business::Travel::OTA::Client::Local - emulate sending to a server
  Business::Travel::OTA::Server - base class for OTA message dispatch logic

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2005 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

