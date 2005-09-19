
######################################################################
## File: $Id: OTA.pm,v 1.3 2005/09/19 02:55:48 spadkins Exp $
######################################################################

package Business::Travel::OTA;

use strict;
use vars qw($VERSION);

# This module version number serves as the version number for the
# distribution.  I did this so that it would be available for 
# programmatic use.

$VERSION = "0.53";

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

  otaclient  - [bin] submit OTA messages to an OTA server
  otarelease - [bin] download, install, and manage versions of the OTA specification
  otaserver  - [cgi-bin] respond to OTA messages sent by a client

Modules:

  Business::Travel::OTA - this documentation (no code yet)
  Business::Travel::OTA::Utils - some useful functions
  Business::Travel::OTA::Client - base class for the OTA client logic
  Business::Travel::OTA::Client::HTTP - transports messages via simple HTTP
  Business::Travel::OTA::Client::Local - emulate sending to a server
  Business::Travel::OTA::Server - base class for OTA message dispatch logic

Getting Started:

  1. Install the Business-Travel-OTA Software distribution
  2. Install a version of the OTA message schema specifications
  3. Validate some XML messages against their OTA schema specifications
  4. Configure and test a Demo Client and Server
  5. Use the Demo Client to send a message to a real server
  6. Use a real client to send messages to the Demo Server
  7. Explore other code distributions built on the Business-Travel-OTA distribution
  8. Write your own code distribution built on Business-Travel-OTA

=head1 INSTALLATION

Please see the documentation for Business::Travel::OTA::installguide
and Business::Travel::OTA::installguide::win32 for details on installation.

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2005 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

