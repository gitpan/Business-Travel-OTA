#!/usr/local/bin/perl -w

use strict;
use App::Options;
use Test::More qw(no_plan);
use lib "lib";
use lib "../lib";

use_ok("Business::Travel::OTA::Client::HTTP");
my $client = Business::Travel::OTA::Client::HTTP->new();
isa_ok($client, "Business::Travel::OTA::Client", "client");
ok($client->can("send"), "can send()");

exit(0);

