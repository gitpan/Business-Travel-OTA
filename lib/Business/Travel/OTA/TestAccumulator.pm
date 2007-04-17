
######################################################################
## File: $Id: TestAccumulator.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA::TestAccumulator;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use File::Spec;
use Date::Format;

=head1 NAME

Business::Travel::OTA::TestAccumulator - Accumulate and print test results

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Accumulate and print test results.

=cut

sub new {
    my ($this) = @_;
    my $class = ref($this) || $this;
    my $self = {};
    $self->{errors} = [];
    bless $self, $class;
    return($self);
}

# $test_type = [file,usage_profile,scenario,use_case]
sub accumulate_results {
    &App::sub_entry if ($App::trace);
    my ($self, $test_type, $test_type_cat, $test_item, $tries, $successes, $line, $errmsg) = @_;
    $self->{total}{tries}     += $tries;
    $self->{total}{successes} += $successes;
    $self->{summary}{$test_type}{tries}     += $tries;
    $self->{summary}{$test_type}{successes} += $successes;
    $self->{detail}{$test_type}{$test_type_cat}{$test_item}{tries}     += $tries;
    $self->{detail}{$test_type}{$test_type_cat}{$test_item}{successes} += $successes;
    if ($tries > $successes) {
        my (%error);
        %error = %$line if ($line);
        $error{errmsg} = $errmsg || "Unknown error";
        push(@{$self->{errors}}, \%error);
    }
    &App::sub_exit() if ($App::trace);
}

#========================================================================
#Test Client:      OTA-Interoperability-Test-Suite Version 1.0
#Test Date/Time:   2006-11-20 13:22:05
#Test Battery:     OTA_Baseline_Hotel_Tests_2006-11-13
#Test Battery MD5: B8810CE9F337612A434DD93457A0
#Server URL:       http://otatest.mycompany.com/cgi-bin/prod/otaserver
#========================================================================
#Result Summary:   91.8% Success (12 Failures on 146 Tests)
#========================================================================
#Result Detail:
# 
#RemoteServer:
#    [class org.opentravel.app.remoteserver.Standard v1.11] - <test result info>
#    http://localhost:8080/ota
#Transport:
#    [class org.opentravel.app.transport.HTTPSimple v1.05] - <test result info>
#Authentication: 
#    [class org.opentravel.app.authen.HTTPBasic v1.35] - <test result info>
#Conversation: 
#    [class org.opentravel.app.conversation.Global v1.16] - <test result info>
#XMLToolset: 
#    [class org.opentravel.app.xml.XercesJ v1.78] - <test result info>
#UseCase: 
#    Ping - [class org.opentravel.app.usecase.Ping v1.22] - <test result info>
#    HotelAvail01 - [class org.opentravel.app.usecase.HotelAvail01 v1.02] - <test result info>
#    HotelAvail02 - [class org.opentravel.app.usecase.HotelAvail02 v1.10] - <test result info>
#Message: 
#    OTA_PingRQ/OTA_PingRS - <test result info>
#    OTA_HotelAvailRQ/OTA_HotelAvailRS - <test result info>
#Transform: 
#    HotelAvail01PRE - <test result info>
#    HotelAvail01POST - <test result info>

sub print_results {
    &App::sub_entry if ($App::trace);
    my ($self, $client_desc) = @_;
    my $time = time();
    my $datetime = time2str("%Y-%m-%d %H:%M:%S %z", $time);
    my $server = $App::options{server};
    my $context = App->context();
    my $remote_server = $context->remote_server($server);
    my $transport = $remote_server->{transport};
    my $transport_values = $remote_server->{transport_values};

    print <<EOF;
========================================================================
Test Client:      $client_desc
Test Date/Time:   $datetime
Server:           $server
EOF
    if ($transport_values) {
        foreach my $key (sort keys %$transport_values) {
            printf("                  %s (%s)\n", $transport_values->{$key}, $key);
        }
    }
    print <<EOF;
========================================================================
EOF
# $test_type = [file,usage_profile,scenario,use_case]

    my ($test_type_label, $test_type, $test_type_cat, $test_item);
    my ($tries, $successes, $failures, $success_pct);

    $tries = $self->{total}{tries} || 0;
    $successes = $self->{total}{successes} || 0;
    $failures = $tries - $successes;
    $success_pct = $tries ? 100*$successes/$tries : 100;
    printf("%-17s %5.1f%% Success (%d Failures on %d Tests)\n",
        "Totals:", $success_pct, $failures, $tries);
    print "------------------------------------------------------------------------\n";

    my @test_type = qw(use_case scenario usage_profile file);
    my %test_type = map { $_ => 1 } @test_type;
    foreach $test_type (@test_type) {
        $test_type_label = ucfirst($test_type);
        $test_type_label =~ s/_([a-z])/" " . uc($1)/eg;
        $tries = $self->{summary}{$test_type}{tries} || 0;
        $successes = $self->{summary}{$test_type}{successes} || 0;
        $failures = $tries - $successes;
        $success_pct = $tries ? 100*$successes/$tries : 100;
        printf("%-17s %5.1f%% Success (%d Failures on %d Tests)\n",
            "$test_type_label:", $success_pct, $failures, $tries);
    }

    foreach $test_type (sort keys %{$self->{summary}}) {
        if (!$test_type{$test_type}) {
            $test_type{$test_type} = 1;
            push(@test_type, $test_type);
            $test_type_label = ucfirst($test_type);
            $test_type_label =~ s/_([a-z])/" " . uc($1)/eg;
            $tries = $self->{summary}{$test_type}{tries} || 0;
            $successes = $self->{summary}{$test_type}{successes} || 0;
            $failures = $tries - $successes;
            $success_pct = $tries ? 100*$successes/$tries : 100;
            printf("%-17s %5.1f%% Success (%d Failures on %d Tests)\n",
                "$test_type_label:", $success_pct, $failures, $tries);
        }
    }
    print "========================================================================\n";

    #foreach $test_type (@test_type) {
    #    $test_type_label = ucfirst($test_type);
    #    $test_type_label =~ s/_([a-z])/" " . uc($1)/eg;
    #    $tries = $self->{summary}{$test_type}{tries} || 0;
    #    $successes = $self->{summary}{$test_type}{successes} || 0;
    #    $failures = $tries - $successes;
    #    $success_pct = $tries ? 100*$successes/$tries : 100;
    #    printf("%-17s %5.1f%% Success (%d Failures on %d Tests)\n",
    #        "$test_type_label:", $success_pct, $failures, $tries);
    #    if ($self->{detail}{$test_type}) {
    #        foreach $test_type_cat (sort keys %{$self->{detail}{$test_type}}) {
    #            foreach $test_item (sort keys %{$self->{detail}{$test_type}{$test_type_cat}}) {
    #                $tries = $self->{detail}{$test_type}{$test_type_cat}{$test_item}{tries} || 0;
    #                $successes = $self->{detail}{$test_type}{$test_type_cat}{$test_item}{successes} || 0;
    #                $failures = $tries - $successes;
    #                $success_pct = $tries ? 100*$successes/$tries : 0;
    #                printf("  %-15s %5.1f%% Success (%d Failures on %d Tests) - $test_item\n",
    #                    "[$test_type_cat]", $success_pct, $failures, $tries);
    #            }
    #        }
    #    }
    #    print "========================================================================\n";
    #}

    my $errors = $self->{errors};
    if ($#$errors > -1) {
        foreach my $error (@$errors) {
            print "ERROR: $error->{errmsg}\n";
            print "       Text: $error->{text}\n";
            print "       File: $error->{file}\n";
            print "       Line: $error->{line}\n";
        }
        print "========================================================================\n";
    }

    &App::sub_exit() if ($App::trace);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

