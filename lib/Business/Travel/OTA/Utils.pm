
######################################################################
## File: $Id: Utils.pm,v 1.4 2006/12/08 20:22:43 spadkins Exp $
######################################################################

package Business::Travel::OTA::Utils;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = do { my @r=(q$Revision: 1.4 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw();

@EXPORT_OK = qw(
    outer_tag
    parse
    substitute
    read_file
    dump
);

use XML::Simple;
use Data::Dumper;

=head1 NAME

Business::Travel::OTA::Utils - Useful functions for processing OTA messages

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Useful functions for processing OTA messages.

=cut

sub outer_tag {
    &App::sub_entry if ($App::trace);
    my ($xml) = @_;
    my ($tag);
    if (!$xml) {
        $tag = "none";
    }
    elsif ($xml =~ /<([A-Za-z][^<>\s]+)/) {
        $tag = $1;
    }
    $tag ||= "none";
    &App::sub_exit($tag) if ($App::trace);
    return($tag);
}

sub parse {
    &App::sub_entry if ($App::trace);
    my ($xml) = @_;

    #$xs = XML::Simple->new(
    #   ForceArray => [ "VehVendorAvail", "VehAvail", "VehicleCharge", "Calculation"],
    #   KeyAttr => [],
    #   GroupTags => {
    #      "VehVendorAvails" => "VehVendorAvail",
    #      "VehAvails" => "VehAvail",
    #      "VehicleCharges" => "VehicleCharge",
    #   },
    #);

    #my $xs = XML::Simple->new(
    #   ForceArray => [ "IHG:RoomStay", "IHG:RoomRate", "IHG:Rate" ],
    #   KeyAttr => [],
    #   GroupTags => {
    #      "IHG:RoomStays" => "IHG:RoomStay",
    #      "IHG:RoomRates" => "IHG:RoomRate",
    #      "IHG:Rates" => "IHG:Rate",
    #   },
    #);

    my ($ref);

    if ($xml) {
        my $xs = XML::Simple->new(
            XMLDecl => '<?xml version="1.0" encoding="utf-8"?>',
            KeepRoot => 1,
            ForceArray => [],
            KeyAttr => [],
            GroupTags => {
            },
        );
        $ref = $xs->XMLin($xml);
    }
    else {
        $ref = {};
    }

    &App::sub_exit($ref) if ($App::trace);
    return($ref);
}

sub substitute {
    &App::sub_entry if ($App::trace);
    my ($text, $params) = @_;
    $text =~ s/\{([^{}]+)\}/(defined $params->{$1}) ? $params->{$1} : ""/eg;
    &App::sub_exit($text) if ($App::trace);
    return($text);
}

sub read_file {
    &App::sub_entry if ($App::trace);
    my ($filename) = @_;
    open(Business::Travel::OTA::Utils::FILE, "< $filename") || die "Unable to open $filename: $!\n";
    local $/ = undef;
    my $data = <Business::Travel::OTA::Utils::FILE>;
    close(Business::Travel::OTA::Utils::FILE);
    &App::sub_exit($data) if ($App::trace);
    return($data);
}

sub dump {
    &App::sub_entry if ($App::trace);
    my ($ref, $name) = @_;
    $name ||= "data";
    my $d = Data::Dumper->new([ $ref ], [ $name ]);
    $d->Indent(1);
    my $dump = $d->Dump();
    &App::sub_exit($dump) if ($App::trace);
    return($dump);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

