#!/usr/local/bin/perl -w

use strict;
use App::Options;
use Test::More qw(no_plan);
use lib "lib";
use lib "../lib";

$| = 1;

use Business::Travel::OTA::Utils qw(outer_tag parse dump);

use_ok("Business::Travel::OTA::Client::Local");
my $client = Business::Travel::OTA::Client::Local->new();
isa_ok($client, "Business::Travel::OTA::Client", "client");
ok($client->can("send"), "can send()");

my $request_xml = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<OTA_PingRQ
    xmlns="http://www.opentravel.org/OTA/2002/08"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opentravel.org/OTA/2002/08 /usr/rubicon/spadkins/src/OTA/Business-Travel-OTA/schemas/2002A/OTA_PingRQ.xsd"
    TimeStamp="2002-12-03T11:09:47-05:00"
    Target="Production"
    Version="2002A"
    SequenceNmbr="1" >
  <EchoData>Are you there?</EchoData>
</OTA_PingRQ>
EOF
my $request_type = &outer_tag($request_xml);
is($request_type, "OTA_PingRQ", "outer_tag()");

my $expected_response_type = $request_type;
$expected_response_type =~ s/RQ/RS/;
is($expected_response_type, "OTA_PingRS", "expected response");

my $response_xml = $client->send($request_xml);
ok($response_xml =~ m!<\?xml!, "response is xml");

my $response_type = &outer_tag($response_xml);
is($response_type, $expected_response_type, "response outer tag");
my $response = &parse($response_xml);

#print "RESPONSE=[$response_type]\n", &dump($response);

exit(0);

