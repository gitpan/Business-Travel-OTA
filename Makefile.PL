
######################################################################
## File: $Id: Makefile.PL 7990 2006-10-27 18:40:09Z spadkins $
######################################################################

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @programs = (
    "bin/otaclient",
);

%opts = (
    "NAME"         => "Business-Travel-OTA",
    "DISTNAME"     => "Business-Travel-OTA",
    "VERSION"      => "0.901",
    "EXE_FILES"    => [ @programs ],
    "PREREQ_PM"    => {
        "App::Options"   => 0.01,  # needed for option parsing
        "App::Context"   => 0.01,  # needed for option parsing
        "XML::Simple"    => 0.01,  # parsing of XML files into perl data structures
        #"LWP::UserAgent" => 0.01,  # passing messages via HTTP
        "SOAP::Lite"     => 0.01,  # enables SOAP protocol
        # "MIME::Entity"   => 0.01,  # needed for SOAP with Attachments (multipart/mime) via MIME-tools
        "XML::DOM"       => 0.01,  # use the DOM to manipulate XML documents
        "XML::XPath"     => 0.01,  # using XPath on the XML document
        # "Crypt::SSLeay"  => 0.01,  # support HTTPS
    },
    "dist"         => {"COMPRESS"=>"gzip -9f", "SUFFIX" => "gz",
                       "ZIP"=>"/usr/bin/zip", "ZIPFLAGS"=>"-rl"},
);

WriteMakefile(%opts);

sub MY::postamble {
    return <<EOF;

install ::
	@\$(MOD_INSTALL) htdocs    \$(PREFIX)/htdocs
	@\$(MOD_INSTALL) cgi-bin   \$(PREFIX)/cgi-bin
	@\$(MOD_INSTALL) share     \$(PREFIX)/share

EOF
}

