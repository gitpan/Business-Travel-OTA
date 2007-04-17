
#############################################################################
## File: $Id: Release.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Release;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use LWP::UserAgent;
use App;

=head1 NAME

Business::Travel::OTA::Release - Administer/install a release of OTA message schemas

=head1 SYNOPSIS

  use Business::Travel::OTA::Release;
  $rel = Business::Travel::OTA::Release->new("2004B");
  $rel->install();

=head1 DESCRIPTION

Administer/install a release of OTA message schemas.

=cut

my %release = (
    "2001A" => {
        url => "http://www.opentravel.org/downloads/2001a_xsd.zip",
    },
    "2001B" => {
        url => "http://www.opentravel.org/downloads/2001B_xsd.zip",
    },
    "2001C" => {
        url => "http://www.opentravel.org/downloads/2001C_xsd.zip",
    },
    "2002A" => {
        url => "http://www.opentravel.org/downloads/2002A_XSD.zip",
    },
    "2002B" => {
        url => "http://www.opentravel.org/downloads/2002B_XSD.zip",
    },
    "2003A" => {
        url => "http://www.opentravel.org/downloads/OTA_2003A.zip",
    },
    "2003B" => {
        url => "http://www.opentravel.org/downloads/OTA_2003B.zip",
    },
    "2004A" => {
        url => "http://www.opentravel.org/downloads/OTA2004A.zip",
    },
    "2004B" => {
        url => "http://www.opentravel.org/downloads/OTA2004B.zip",
    },
    "2005A" => {
        url => "http://www.opentravel.org/downloads/OTA2005A.zip",
    },
    "2005B" => {
        url => "http://www.opentravel.org/downloads/OTA2005A_Publication.zip",
    },
    "2006A" => {
        url => "http://www.opentravel.org/downloads/OTA2006A_PublicReview.zip",
    },
);

sub new {
    &App::sub_entry if ($App::trace);
    my $this = shift;      # might be a package string or an object reference
    my $class = ref($this) || $this;                          # get the class

    my (@initial_values);
    if ($#_ >= 0 && ref($_[0]) eq "HASH") {    # if first arg is a hashref...
        my $initial_values = shift;    # it is a set of initial attrib values
        @initial_values = { %$initial_values };
    }
    if ($#_ >= 0 && $#_ % 2 == 0) {             # an even number of args left
        push(@initial_values,("release", shift));
    }
    if ($#_ >= 0 && $#_ % 2 == 1) {             # an even number of args left
        push(@initial_values,@_);
    }

    my $self = { @initial_values };             # create new object reference
    bless $self, $class;                   # bless it into the required class

    &App::sub_exit($self) if ($App::trace);
    return $self;
}

sub install {
    &App::sub_entry if ($App::trace);
    my ($self) = @_;
    my $verbose = $App::options{verbose};
    my $release = $self->{release};
    print "Installing [$release] ...\n" if ($verbose);
    $self->download();
    print "Done [$release]\n" if ($verbose);
    &App::sub_exit() if ($App::trace);
}

sub download {
    &App::sub_entry if ($App::trace);
    my ($self) = @_;
    my $verbose = $App::options{verbose};
    my $ua = LWP::UserAgent->new();
    my $release = $self->{release};
    my $url = $release{$release}{url} || "http://www.opentravel.org/downloads/OTA_${release}.zip";
    my $prefix = $App::options{prefix};
    mkdir("$prefix/src") if (! -d "$prefix/src");
    mkdir("$prefix/src/archive") if (! -d "$prefix/src/archive");
    my $file = "$prefix/src/archive/OTA_${release}.zip";
    print "Mirroring [$url] to [$file]...\n" if ($verbose);
    $ua->mirror($url, $file);
    &App::sub_exit() if ($App::trace);
}

sub unpack {
    &App::sub_entry if ($App::trace);
    my ($self) = @_;
    my $verbose = $App::options{verbose};
    my $release = $self->{release};
    my $prefix = $App::options{prefix};
    my $file = "$prefix/src/archive/OTA${release}.zip";
    print "Unpacking [$file]...\n" if ($verbose);
    #$ua->mirror($url, $file);
    &App::sub_exit() if ($App::trace);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

