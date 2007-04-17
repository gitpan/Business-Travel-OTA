#!/usr/local/bin/perl

use strict;
use Test::More qw(no_plan);
use App::Options;

chdir($1) if ($0 =~ /(.*)(\/|\\)(.*)/);
unshift @INC, "../lib";

require Business::Travel::OTA;
ok(1, "compiled version $Business::Travel::OTA::VERSION");

