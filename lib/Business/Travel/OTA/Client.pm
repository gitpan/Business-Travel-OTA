
######################################################################
## File: $Id: Client.pm,v 1.2 2005/05/20 13:24:40 spadkins Exp $
######################################################################

package Business::Travel::OTA::Client;

use strict;
use vars qw($VERSION @ISA);

use App::Service;

$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
@ISA = ("App::Service");

use Business::Travel::OTA::Utils;
use Business::Travel::OTA::TestAccumulator;
use File::Spec;
use Date::Format;

=head1 NAME

Business::Travel::OTA::Client - Logic for sequencing and accumulating results for the test client

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Logic for sequencing and accumulating results for the test client

=cut

sub _init {
    my ($self) = @_;
    $self->{accumulator} = Business::Travel::OTA::TestAccumulator->new();
    my $dirs = $App::options{dirs};
    my (@dirs);
    if (!$dirs) {
        # do nothing
    }
    elsif ($dirs =~ /^.:/) {  # Windows platform
        @dirs = split(/[ ,;]+/, $App::options{dirs});
    }
    else {
        @dirs = split(/[ ,;:]+/, $App::options{dirs});
    }
    $self->{dirs} = [@dirs];
    my $context = $self->{context};
    my $options = $context->{options};
    my $xml_toolset = $context->xml_toolset("xmltoolset",
        xmlns => $options->{xmlns},
        schema_location => $options->{schema_location},
        validation => $options->{validation},
    );
    $self->{validation} = $options->{validation};
    $self->{xml_toolset} = $xml_toolset;
    $self->{conversation_values} = {};
    $self->{xml_documents} = {};
}

sub run {
    &App::sub_entry if ($App::trace);
    my ($self, @files) = @_;
    my $accumulator = $self->{accumulator};
    my ($filename);
    if ($#files == -1) {
        @files = ( "default.tests" );
    }
    $self->{files} = [ @files ];
    while ($#{$self->{files}} > -1) {
        $filename = shift @{$self->{files}};
        $self->run_file($filename);
    }
    $accumulator->print_results("Business::Travel::OTA Version $Business::Travel::OTA::VERSION");
    &App::sub_exit() if ($App::trace);
}

sub find_file {
    &App::sub_entry if ($App::trace);
    my ($self, $filename) = @_;
    my $verbose = $App::options{verbose};
    my ($filepath, $ext, $possible_filepath, $dir);
    my $dirs = $self->{dirs};
    my $fileext = "";
    if ($filename =~ /\.([a-z]+)$/) {
        $fileext = $1;
    }
    if ($fileext) {
        if (File::Spec->file_name_is_absolute($filename)) {
            if (-r $filename) {
                $filepath = $filename;
            }
        }
        else {
            foreach $dir (@$dirs) {
                $possible_filepath = File::Spec->catpath(undef, $dir, $filename);
                print "Checking for $possible_filepath ... \n" if ($verbose >= 4);
                if (-r $possible_filepath) {
                    $filepath = $possible_filepath;
                    last;
                }
            }
        }
    }
    else {
        foreach $ext ("tests", "scenario", "xml") {
            foreach $dir (@$dirs) {
                $possible_filepath = File::Spec->catpath(undef, $dir, "$filename.$ext");
                print "Checking for $possible_filepath ... \n" if ($verbose >= 4);
                if (-r $possible_filepath) {
                    $filepath = $possible_filepath;
                    $fileext = $ext;
                    last;
                }
            }
        }
    }
    &App::sub_exit($filepath) if ($App::trace);
    return($filepath);
}

sub read_file {
    &App::sub_entry if ($App::trace);
    my ($self, $filename) = @_;
    my ($filepath, $data);
    my $accumulator = $self->{accumulator};
    $filepath = $self->find_file($filename);
    my $fileext = "";
    if ($filename =~ /\.([^\.]+)$/) {
        $fileext = $1;
    }
    if ($filepath) {
        $data = &Business::Travel::OTA::Utils::read_file($filepath);
    }
    else {
        $accumulator->accumulate_results("file",$fileext,$filename,1,0);
    }
    &App::sub_exit($data) if ($App::trace);
    return($data);
}

sub read_file_lines {
    &App::sub_entry if ($App::trace);
    my ($self, $filename) = @_;
    my ($filepath, $include_file, $include_path, @lines, $line);
    my $accumulator = $self->{accumulator};
    $filepath = $self->find_file($filename);
    local(*FILE);
    my $fileext = "";
    if ($filename =~ /\.([^\.]+)$/) {
        $fileext = $1;
    }
    my $lineno = 0;
    $line = { text => "", file => $filepath, line => 0 };
    if ($filepath && open(FILE, "< $filepath")) {
        while (<FILE>) {
            $lineno ++;
            chomp;
            s/^\s+//;
            s/\s+$//;
            next if (/^$/);
            $line = { text => $_, file => $filepath, line => $lineno };
            if (/^INCLUDE\s+(\S+)/) {
                $include_file = $1;
                $include_path = $self->find_file($include_file);
                if ($include_path) {
                    push(@lines, $self->read_file_lines($include_path));
                }
                else {
                    $accumulator->accumulate_results("file",$fileext,$filename,1,0,$line,"File [$include_file] not found");
                }
            }
            else {
                push(@lines, $line);
            }
        }
        close(FILE);
        $accumulator->accumulate_results("file",$fileext,$filename,1,1);
    }
    else {
        $accumulator->accumulate_results("file",$fileext,$filename,1,0,$line,"File not found");
    }
    &App::sub_exit($#lines + 1) if ($App::trace);
    return(@lines);
}

sub run_file {
    &App::sub_entry if ($App::trace);
    my ($self, $filename) = @_;
    my $verbose = $App::options{verbose};
    my $accumulator = $self->{accumulator};
    my ($dir, $dirs, $filepath);
    $dirs = $self->{dirs};
    print "Running file: filename=[$filename]\n" if ($verbose >= 4);
    print "Searching dirs=[@$dirs]\n" if ($verbose >= 4);
    $filepath = $self->find_file($filename);
    my $fileext = "";
    if ($filename =~ /\.([a-z]+)$/) {
        $fileext = $1;
    }
    $filename =~ s/.*[\\\/]//;
    my $success = 0;
    if (!$filepath) {
        print "WARNING: Couldn't find file [$filename] in 'dirs' list:\n   ", join("\n   ", @$dirs), "\n";
    }
    elsif (!$fileext) {
        print "WARNING: Don't know how to run file [$filename] (missing ext)\n";
    }
    elsif ($fileext eq "tests") {
        $self->run_tests_file($filepath);
        $success = 1;
    }
    elsif ($fileext eq "scenario") {
        $self->run_scenario_file($filepath);
        $success = 1;
    }
    elsif ($fileext eq "xml") {
        $self->run_xml_file($filepath);
        $success = 1;
    }
    else {
        print "WARNING: Don't know how to run file [$filename] (unknown ext=[$fileext])\n";
    }
    $accumulator->accumulate_results("file",$fileext,$filename,1,$success);
    &App::sub_exit() if ($App::trace);
}

#<?xml version="1.0" encoding="UTF-8"?>
#<OTA_PingRQ
#    xmlns="http://www.opentravel.org/OTA/2002/08"
#    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#    xsi:schemaLocation="http://www.opentravel.org/OTA/2002/08 /usr/rubicon/spadkins/src/OTA/Business-Travel-OTA/schemas/2002A/OTA_PingRQ.xsd"
#    TimeStamp="2002-12-03T11:09:47-05:00"
#    Target="Production"
#    Version="2002A"
#    SequenceNmbr="1" >
#  <EchoData>Are you there?</EchoData>
#</OTA_PingRQ>

sub run_xml_file {
    &App::sub_entry if ($App::trace);
    my ($self, $filepath) = @_;
    my $verbose = $App::options{verbose};
    my ($valid, $filename);
    $filename = $filepath;
    $filename =~ s/.*[\\\/]//;
    print "Running XML file [$filepath]\n" if ($verbose >= 4);
    my $context = App->context();
    my $xml_toolset = $self->{xml_toolset};
    my $accumulator = $self->{accumulator};
    my $remote_server = $context->remote_server($App::options{server});
    my $request_xml = $self->read_file($filepath);
    $valid = $xml_toolset->validate_document($request_xml);
    $accumulator->accumulate_results("file","xml",$filename,1,$valid);
    my $response_xml = $remote_server->send($request_xml);
    $valid = $xml_toolset->validate_document($response_xml);
    $accumulator->accumulate_results("file","xml",$filename,1,$valid);
    &App::sub_exit() if ($App::trace);
}

sub run_scenario_file {
    &App::sub_entry if ($App::trace);
    my ($self, $filepath) = @_;
    my $verbose = $App::options{verbose};
    print "Running Scenario file [$filepath]\n" if ($verbose >= 4);

    my $accumulator = $self->{accumulator};

    my $context = $self->{context};
    my $remote_server = $context->remote_server($App::options{server});
    my @lines = $self->read_file_lines($filepath);

    my ($assignment_expr, $document_name, $source_document_name, $document_filename, $xml, $xmldom, $document);
    my ($var, $op, $expr, $lhs_value, $value, $default, $valid);
    my ($text, $lineno);

    my $file = $filepath;
    $file =~ s/.*[\/\\]//;

    my $xml_toolset  = $self->{xml_toolset};
    my $xml_documents = $self->{xml_documents};
    my $validate = 1;

    # print "SCENARIO:\n", join("\n", @lines), "\n";
    foreach my $line (@lines) {
        $text = $line->{text};
        # DOCUMENT         OTA_PingRQ.xml
        # DOCUMENT         [rq]     
        # DOCUMENT         [rs]                            = OTA_PingRS.xml
        # DOCUMENT         [rq]                            = [current]
        # DOCUMENT         [foo]                           = NEW OTA_PingRQ
        if ($text =~ /^DOCUMENT\s+(.+)$/) {
            $assignment_expr = $1;
            $source_document_name = "";
            $document_filename = "";

            if ($assignment_expr =~ /^\[([a-zA-Z0-9_]+)\]\s*=\s*(.*\S)/) {
                $document_name = $1;
                $document_filename = $2;
                if ($document_filename =~ /^\[([a-zA-Z0-9_]+)\]$/) {
                    $source_document_name = $1;
                    $document_filename = "";
                }
            }
            else {
                $document_name = "current";
                $document_filename = $assignment_expr;
            }

            if ($document_filename =~ /^NEW\s+(\S+)/) {
                my $root_element = $1;
                $document = $xml_toolset->new_document(root_element => $root_element);
                $xml_documents->{$document_name} = $document;
            }
            elsif ($document_filename) {
                $xml = $self->read_file($document_filename);
                $document = $xml_toolset->new_document($xml);
                $xml_documents->{$document_name} = $document;
                my (%results);
                $valid = $document->validate(\%results);
                $accumulator->accumulate_results("validate","xml",$document_filename,1,$valid,$line,$results{error});
            }
            else {
                $xml_documents->{$document_name} = $xml_documents->{$source_document_name};
            }
        }
        # VALIDATION      ON
        # VALIDATION      OFF
        elsif ($text =~ /^VALIDATION\s+([^ \t]+)$/) {
            $value   = $1;
            my $validation = ($value eq "OFF") ? 0 : 1;
            $self->{validation} = $validation;
            $self->{xml_toolset}->set_validation($validation);
        }
        # DEFAULT         CONVERSATION{Target}            = Production
        # DEFAULT         CONVERSATION{Version}           = 2004A
        # DEFAULT         CONVERSATION{SequenceNmbr}      = 1
        elsif ($text =~ /^DEFAULT\s+([^ \t=]+)\s*=\s*(\S+)$/) {
            $var     = $1;
            $expr    = $2;
            $default = $self->evaluate_expr($expr);
            $self->get($var, $default, 1);
        }
        # SET             CONVERSATION{current_datetime}  = SYSTEM{current_datetime}
        # SET             /OTA_PingRQ/@TimeStamp          = CONVERSATION{current_datetime}
        # SET             /OTA_PingRQ/@Target             = CONVERSATION{Target}
        # SET             /OTA_PingRQ/@Version            = CONVERSATION{Version}
        # SET             /OTA_PingRQ/@SequenceNmbr       = CONVERSATION{SequenceNmbr}
        # SET             /OTA_PingRQ/EchoData            = Hello world!
        elsif ($text =~ /^SET\s+([^ \t=]+)\s*=\s*(.*\S)/) {
            $var     = $1;
            $expr    = $2;
            $value = $self->evaluate_expr($expr);
            $self->set($var, $value);
        }
        # SEND
        elsif ($text =~ /^SEND\s*(\S*)$/) {
            $document_name = $1 || "[current]";
            if ($document_name =~ /^\[([a-zA-Z0-9_]+)\]$/) {
                $document_name = $1;
                $document = $xml_documents->{$document_name};
                my (%results);
                $valid = $document->validate(\%results);
                $accumulator->accumulate_results("validate","xml",$file,1,$valid,$line,$results{error});
                my $request_xml = $document->xml();
                my $response_xml = $remote_server->send($request_xml);
                %results = ();
                $valid = $xml_toolset->validate_document($response_xml,\%results);
                $accumulator->accumulate_results("validate","xml",$file,1,$valid,$line,$results{error});
            }
            else {
                $value = $self->evaluate_expr($expr);
                print "EXPR [$expr] = $value\n";
            }
        }
        # TEST            ROOT-ELEMENT                    =  OTA_PingRQ
        # TEST            /OTA_PingRQ/@xmlns              =  http://www.opentravel.org/OTA/2002/08
        # TEST            /OTA_PingRQ/@xmlns:xsi          =  http://www.w3.org/2001/XMLSchema-instance
        # TEST            /OTA_PingRQ/@xsi:schemaLocation =~ "^http://www.opentravel.org/OTA/2002/08 "
        # TEST            /OTA_PingRQ/@TimeStamp          >= CONVERSATION{current_datetime}
        # TEST            /OTA_PingRQ/@TimeStamp          <= SYSTEM{current_datetime}
        # TEST            /OTA_PingRQ/@Target             =  CONVERSATION{Target}
        # TEST            /OTA_PingRQ/@Version            =  CONVERSATION{Version}
        # TEST            /OTA_PingRQ/@SequenceNmbr       =  CONVERSATION{SequenceNmbr}
        # TEST            /OTA_PingRQ/EchoData            = Hello world!
        elsif ($text =~ /^TEST\s+([^ \t=]+)\s*([=<>!~]+)\s*(\S+)$/) {
            $var       = $1;
            $op        = $2;
            $expr      = $3;
            $lhs_value = $self->evaluate_expr($var);
            $value     = $self->evaluate_expr($expr);
        }
        elsif ($text =~ /^PRINT\s*(.*)$/) {
            $expr = $1;
            $expr = "[current]" if ($expr eq "");
            if ($expr =~ /^\[([a-zA-Z0-9_]+)\]$/) {
                $document_name = $1;
                $document = $xml_documents->{$document_name};
                print "DOCUMENT [$document_name]\n";
                print $document->xml();
            }
            else {
                $value = $self->evaluate_expr($expr);
                print "EXPR [$expr] = $value\n";
            }
        }
        elsif ($text =~ /^\s*#/) {
            # comment
        }
        elsif ($text =~ /^\s*$/) {
            # blank line
        }
        else {
            print STDERR "ERROR: Can't understand text [$text]\n   File: $line->{file}\n   Line: $line->{line}\n";
        }
    }

    &App::sub_exit() if ($App::trace);
}

sub evaluate_expr {
    &App::sub_entry if ($App::trace);
    my ($self, $expr) = @_;
    my ($value, $var);
    if ($expr =~ /^"(.*)"$/) {
        $value = $1;
    }
    elsif ($expr =~ /^SYSTEM\{(.*)\}$/) {
        $var = $1;
        if ($var eq "current_datetime") {
            $value = time2str("%Y-%m-%dT%H:%M:%S", time());
        }
    }
    elsif ($expr =~ /^CONVERSATION\{(.*)\}$/) {
        $var = $1;
        my $conversation_values = $self->{conversation_values};
        $value = $conversation_values->{$var};
    }
    elsif ($var =~ m!^\[([^\[\]]+)\](/.*)!) {
        $var = $2;
        my $document = $self->document($1);
        $value = $document->get_value($var);
    }
    elsif ($expr =~ m!^/!) {
        $var = $expr;
        my $document = $self->document("current");
        $value = $document->get_value($var);
    }
    else {
        $value = $expr;
    }
    &App::sub_exit($value) if ($App::trace);
    return($value);
}

sub get {
    &App::sub_entry if ($App::trace);
    my ($self, $var, $default, $set_default) = @_;
    my ($value);
    if ($var =~ /^CONVERSATION\{(.*)\}$/) {
        $var = $1;
        my $conversation_values = $self->{conversation_values};
        $value = $conversation_values->{$var};
        if (!defined $value) {
            $value = $default;
            $conversation_values->{$var} = $value if ($set_default);
        }
    }
    elsif ($var =~ m!^\[([^\[\]]+)\](/.*)!) {
        $var = $2;
        my $document = $self->document($1);
        $value = $document->get_value($var);
        if (!defined $value) {
            $value = $default;
            $document->set_value($var, $value) if ($set_default);
        }
    }
    elsif ($var =~ m!^/!) {
        my $document = $self->document("current");
        $value = $document->get_value($var);
        if (!defined $value) {
            $value = $default;
            $document->set_value($var, $value) if ($set_default);
        }
    }
    &App::sub_exit($value) if ($App::trace);
    return($value);
}

sub set {
    &App::sub_entry if ($App::trace);
    my ($self, $var, $value) = @_;
    if ($var =~ /^CONVERSATION\{(.*)\}$/) {
        $var = $1;
        my $conversation_values = $self->{conversation_values};
        $conversation_values->{$var} = $value;
    }
    elsif ($var =~ m!^\[([^\[\]]+)\](/.*)!) {
        $var = $2;
        my $document = $self->document($1);
        $document->set_value($var, $value);
    }
    elsif ($var =~ m!^/!) {
        my $document = $self->document("current");
        $document->set_value($var, $value);
    }
    &App::sub_exit() if ($App::trace);
}

sub document {
    &App::sub_entry if ($App::trace);
    my ($self, $name) = @_;
    my $xml_documents = $self->{xml_documents};
    my $document = $xml_documents->{$name};
    #if (!$document || $new) {
    #    my $context = $self->{context};
    #    my $xml_toolset = $self->{xml_toolset};
    #    $schema_location = $context->{options}{schema_location} if (!$schema_location);
    #    $document = $xml_toolset->new_document(root_element => $root_element, schema_location => $schema_location);
    #    $xml_documents->{$name} = $document;
    #}
    &App::sub_exit($document) if ($App::trace);
    return($document);
}

sub run_tests_file {
    &App::sub_entry if ($App::trace);
    my ($self, $filepath) = @_;
    my $verbose = $App::options{verbose};
    my (@files);
    if (open(FILE, "< $filepath")) {
        while (<FILE>) {
            chomp;
            s/#.*//;
            s/\s+$//;
            s/^\s+//;
            next if ($_ eq "");
            if (/^FILE\s+(.*)$/) {
                push(@files, $1);
            }
        }
        close(FILE);
    }
    else {
        print "Can't open [$filepath]: $!\n";
    }
    unshift(@{$self->{files}}, @files) if ($#files > -1);
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
    my ($self, @files) = @_;
    my $time = time();
    my $datetime = time2str("%Y-%m-%d %H:%M:%S %z", $time);
    my $server = $App::options{server};
    my $context = $self->{context};
    my $remote_server = $context->remote_server($server);
    my $transport = $remote_server->{transport};
    my $transport_values = $remote_server->{transport_values};
    print <<EOF;
========================================================================
Test Client:      Business::Travel::OTA Version $Business::Travel::OTA::VERSION
Test Date/Time:   $datetime
Server:           $server
EOF
    if ($transport_values) {
        foreach my $key (sort keys %$transport_values) {
            printf("                  %s (%s)\n", $transport_values->{$key}, $key);
        }
    }
    print <<EOF;
Files:            @files
========================================================================
EOF

    my $num_tests = $self->{num_tests} || 0;
    my $num_tests_fail = $self->{num_tests_fail} || 0;
    my $success_pct = $num_tests ? 100*($num_tests - $num_tests_fail)/$num_tests : 0;

    printf("Result Summary:   %5.1f%% Success (%d Failures on %d Tests)\n",
        $success_pct,
        $num_tests_fail,
        $num_tests);
    print "========================================================================\n";

    &App::sub_exit() if ($App::trace);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

