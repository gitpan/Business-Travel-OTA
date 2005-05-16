
######################################################################
## File: $Id: Utils.pm,v 1.1 2005/05/05 19:46:02 spadkins Exp $
######################################################################

package Business::Travel::OTA::Utils;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw();

@EXPORT_OK = qw(
    outer_tag
    parse
    dump
);

use XML::Simple;
use Data::Dumper;

sub outer_tag {
    my ($xml) = @_;
    my ($tag);
    if ($xml =~ /<([A-Za-z][^<>\s]+)/) {
        $tag = $1;
    }
    return($tag);
}

sub parse {
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

    my $xs = XML::Simple->new(
       ForceArray => [],
       KeyAttr => [],
       GroupTags => {
       },
    );

    my $ref = $xs->XMLin($xml);

    return($ref);
}

sub dump {
    my ($ref, $name) = @_;
    $name ||= "data";
    my $d = Data::Dumper->new([ $ref ], [ $name ]);
    $d->Indent(1);
    return($d->Dump());
}

1;

