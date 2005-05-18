
use App::Build;

my $build = App::Build->new (
    dist_name         => "Business-Travel-OTA",
    dist_version_from => "lib/Business/Travel/OTA.pm",
    dist_author       => "stephen.adkins\@officevision.com",
    dist_abstract     => "Tools for handling OTA-compliant (Open Travel Alliance) messages",
    license           => "perl",
    requires => {
        "App::Options"   => 0,  # needed for option parsing
        "XML::Simple"    => 0,  # parsing of XML files into perl data structures
        "XML::XPath"     => 0,  # using XPath on the XML document
        "Data::Dumper"   => 0,  # printing out perl data structures
        "LWP::UserAgent" => 0,  # passing messages via HTTP
        "Crypt::SSLeay"  => 0,  # support HTTPS
    },
    build_requires => {
        "App::Build"     => 0,  # needed for installing the software
        "File::Spec"     => 0,  # platform-neutral directory processing
    },
    extra_dirs => [ "bin", "cgi-bin", "htdocs", ],
    #recommends => {
    #    "Foo::Bar"       => 0,  # recommends the Foo::Bar module
    #},
    dynamic_config => 1,
);

$build->create_build_script;

