#!/usr/local/bin/perl -w

use strict;
use App::Options;
use Test::More qw(no_plan);
use lib "lib";
use lib "../lib";

my $dir = (-d "t") ? "t" : ".";
my $samples_dir = $App::options{samples_dir} || "samples";
my $schema_dir  = $App::options{schema_dir} || "schema";
$samples_dir = "$dir/$samples_dir" if ($samples_dir !~ m!^/!);
$schema_dir  = "$dir/$schema_dir" if ($schema_dir !~ m!^/!);

{
    print "samples dir =[$samples_dir]\n";
    my @xmlfiles = <$samples_dir/*.xml>;
    if ($#xmlfiles > -1) {
        foreach my $xmlfile (@xmlfiles) {
            if ($App::options{verbose}) {
                print "===========================================================================\n";
                print "= $xmlfile\n";
                print "===========================================================================\n";
            }
            &validate_well_formed($xmlfile);
            # &validate_schema_xml_checker($xmlfile);
            # &validate_schema_xml_dom_valparser($xmlfile);
            # &validate_schema_xml_validator_schema($xmlfile);
            # &validate_schema_xml_libxml($xmlfile);
            &validate_schema_xml_xerces($xmlfile);
        }
    }
    else {
        ok(1,"no xml files");
    }
}

exit(0);


sub validate_well_formed {
    my ($xmlfile) = @_;
    my $file = $xmlfile;
    $file =~ s!.*/!!;

    eval "use XML::DOM;";
    my $parser = XML::DOM::Parser->new();
    my ($dom);
    eval {
        $dom = $parser->parsefile($xmlfile);
    };
    if ($@) {
        ok(0, "[$file] well formed: $@");
    }
    else {
        ok(1, "[$file] well formed: ok");
    }
}


sub validate_schema_xml_checker {
    my ($xmlfile) = @_;
    my $file = $xmlfile;
    $file =~ s!.*/!!;

    eval "use XML::Checker::Parser;";

    my $parser = XML::Checker::Parser->new();
    eval {
        local $XML::Checker::FAIL = \&die_xml_checker;
        $parser->parsefile($xmlfile);
    };
    if ($@) {
        ok(0, "[$file] validated schema (XML::Checker): $@");
    }
    else {
        ok(1, "[$file] validated schema (XML::Checker): ok");
    }
}

# Throws an exception (with die) when an error is encountered, this
# will stop the parsing process.
# Don't die if a warning or info message is encountered, just print a message.
sub die_xml_checker {
    my $code = shift;
    die XML::Checker::error_string ($code, @_) if $code < 200;
    XML::Checker::print_error ($code, @_);
}

sub validate_schema_xml_dom_valparser {
    my ($xmlfile) = @_;
    my $file = $xmlfile;
    $file =~ s!.*/!!;

    eval "use XML::DOM::ValParser;";

    my $parser = XML::DOM::ValParser->new();
    my ($dom);
    eval {
        local $XML::Checker::FAIL = \&die_xml_checker;
        $dom = $parser->parsefile($xmlfile);
    };
    if ($@) {
        ok(0, "[$file] validated schema (XML::DOM::ValParser): $@");
    }
    else {
        ok(1, "[$file] validated schema (XML::DOM::ValParser): ok");
    }
}

sub validate_schema_xml_validator_schema {
    my ($xmlfile) = @_;
    my $file = $xmlfile;
    $file =~ s!.*/!!;

    eval "use XML::SAX::ParserFactory;";
    eval "use XML::Validator::Schema;";

    my ($xsd, $version, $namespace) = &get_xsd($xmlfile);
    my ($validator, $sax_parser);
    eval {
        $validator = XML::Validator::Schema->new(file => "$schema_dir/$version/$xsd");
        $sax_parser = XML::SAX::ParserFactory->parser(Handler => $validator);
        $sax_parser->parse_uri($xmlfile)
    };
    if ($@) {
        ok(0, "[$file] validated schema (XML::Validator::Schema): $@");
    }
    else {
        ok(1, "[$file] validated schema (XML::Validator::Schema): ok");
    }
}

sub validate_schema_xml_libxml {
    my ($xmlfile) = @_;
    my $file = $xmlfile;
    $file =~ s!.*/!!;

    eval "use XML::LibXML;";

    my ($doc);
    my $parser = XML::LibXML->new();
    $parser->validation(1);
    my $xml = &get_locally_validatable_xml($xmlfile);
print
"===============\n",
$xml,
"===============\n";
    eval {
        $doc = $parser->parse_string($xml);
    };
    if ($@) {
        ok(0, "[$file] validated schema (XML::LibXML::Parser): $@");
    }
    else {
        ok(1, "[$file] validated schema (XML::LibXML::Parser): ok");
    }
}

sub validate_schema_xml_xerces {
    my ($xmlfile) = @_;
    my $file = $xmlfile;
    $file =~ s!.*/!!;

    use XML::Xerces;

    my $validator = XML::Xerces::SchemaValidator->new();
    my $parser = XML::Xerces::XercesDOMParser->new($validator);
    $parser->setValidationScheme($XML::Xerces::AbstractDOMParser::Val_Auto);
    $parser->setErrorHandler(XML::Xerces::PerlErrorHandler->new());
    $parser->setDoNamespaces(0);
    $parser->setDoSchema(1);
    my ($xsd, $version, $namespace) = &get_xsd($xmlfile);
    my $xsdfile = "$schema_dir/$version/$xsd";
    $xsdfile = "$schema_dir/$xsd" if (! -f $xsdfile);
    $parser->setExternalSchemaLocation("$namespace $xsdfile");
    $parser->setValidationSchemaFullChecking(1);
    $parser->setExitOnFirstFatalError(0);
    $parser->setValidationConstraintFatal(1);

    eval {
        $parser->parse($xmlfile);
    };
    if ($@) {
        ok(0, "[$file] validated schema (XML::Xerces): $@");
    }
    else {
        ok(1, "[$file] validated schema (XML::Xerces): ok");
    }
}

sub get_xsd {
    my ($file) = @_;
    local(*FILE);
    open(main::FILE, "< $file") || die "Unable to open $file: $!\n";
    my $data = join("", <main::FILE>);
    close(main::FILE);
    my ($xsd, $version, $namespace);
    # xsi:schemaLocation="http://www.opentravel.org/OTA/2002/08 /usr/rubicon/spadkins/src/OTA/Business-Travel-OTA/schemas/2002A/OTA_PingRQ.xsd"
    if ($data =~ m!xsi:schemaLocation="([^\s]*)\s+([^"]*[\\/])?([^ \\/]+.xsd)"!s) {
        $namespace = $1;
        $xsd = $3;
    }
    else {
        die "couldn't parse schemaLocation\n$data\n";
    }
    if ($data =~ /Version="([^"]+)"/) {
        $version = $1;
    }
    else {
        die "couldn't get version information\n$data\n";
    }
    return($xsd, $version, $namespace);
}

sub get_locally_validatable_xml {
    my ($file) = @_;
    local(*FILE);
    open(main::FILE, "< $file") || die "Unable to open $file: $!\n";
    my $xml = join("", <main::FILE>);
    close(main::FILE);
    my ($xsd, $version, $url);
    if ($xml =~ m!xsi:schemaLocation="[^"]*[ \\/]([^ \\/]+.xsd)"!s) {
        $xsd = $1;
    }
    elsif ($xml =~ m!xsi:schemaLocation="([^"/\\]+.xsd)"!) {
        $xsd = $1;
    }
    if ($xml =~ /Version="([^"]+)"/) {
        $version = $1;
    }
    if (-d "t") {
        $url = "file:schemas/$version/$xsd";
    }
    else {
        $url = "file:../schemas/$version/$xsd";
    }
    $xml =~ s!xsi:schemaLocation="[^"]*"!xsi:schemaLocation="$url"!s;
    return($xml);
}

exit 0;

