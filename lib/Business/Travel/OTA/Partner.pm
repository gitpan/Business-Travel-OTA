
#############################################################################
## File: $Id: Partner.pm,v 1.1 2006/04/19 03:59:32 spadkins Exp $
#############################################################################

package Business::Travel::OTA::Partner;

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};

use App;
use App::Service;

@ISA = qw(App::Service);

use Business::Travel::OTA::Utils qw(outer_tag parse read_file);
use XML::Toolset;

=head1 NAME

Business::Travel::OTA::Partner - Base class for logic for an OTA trading partner

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

Base class for logic for an OTA trading partner.

=cut

sub perform {
    &App::sub_entry if ($App::trace);
    my ($self, $action, $server, $session) = @_;
    my $context = $self->{context};
    my $xml_toolset_type = $self->{xml_toolset_type} || "BestAvailable";
    my $xml_toolset = XML::Toolset->new(Type => $xml_toolset_type);
print "xml_toolset=[$xml_toolset]\n";

    my @message_path = $self->path("message");

    my $pre_file = $self->locate_file_in_path($action, \@message_path, "pre");
    my $xml_file = $self->locate_file_in_path($action, \@message_path, "xml");

    my ($request_msg, $request_xml, $response_xml);

    if ($xml_file) {
        $request_xml = &read_file($xml_file);
        $request_msg = $xml_toolset->message($request_xml);
    }
    else {
        $request_msg = $xml_toolset->message();
    }

    my $is_transformed = 0;
    if ($pre_file) {
        my $xform = &read_file($pre_file);
        $request_msg->transform($xform);
        $is_transformed = 1;
    }
    if ($self->{xform}) {
        $request_msg->transform($self->{xform});
        $is_transformed = 1;
    }
    if ($is_transformed) {
        $request_xml = $request_msg->as_xml();
    }

    if ($request_xml) {
        $response_xml = $server->send($request_xml);
    }
    else {
        print "ERROR: No request XML found for message [$action] in path [@message_path]\n";
    }

    &App::sub_exit() if ($App::trace);
}

sub path {
    &App::sub_entry if ($App::trace);
    my ($self, $path_type) = @_;
    my (@path, $path);
    my $options = $self->{context}{options};
    my $name = $self->{name};
    my $path_key = "${path_type}_path";
    $path = $self->{$path_key} || $options->{$path_key} ||
        "$options->{prefix}/share/ota/$path_type/$name,$options->{prefix}/share/ota/$path_type";
    if (ref($path)) {
        push(@path, @$path);
    }
    else {
        push(@path, split(/[,;]+/,$path));
    }
    &App::sub_exit(@path) if ($App::trace);
    return(@path);
}

sub locate_file_in_path {
    &App::sub_entry if ($App::trace);
    my ($self, $file_base, $path, $ext_list) = @_;
    $path = [ $path ] if (!ref($path));
    $ext_list = [ $ext_list ] if (!ref($ext_list));

    my ($filepath, $testfile);
    foreach my $dir (@$path) {
        $testfile = "$dir/$file_base";
        $filepath = $testfile if (-f $testfile);
        if (!$filepath && $ext_list) {
            foreach my $ext (@$ext_list) {
                $testfile = "$dir/$file_base.$ext";
                $filepath = $testfile if (-f $testfile);
                last if ($filepath);
            }
        }
        last if ($filepath);
    }

    &App::sub_exit($filepath) if ($App::trace);
    return($filepath);
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <sadkins@therubicongroup.com>
 * Copyright: (c) 2007 Stephen Adkins (for the purpose of making it Free)
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

