package InfoGopher::InfoTransform::ATOM2JSON ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Moose;
use Try::Tiny;

extends 'InfoGopher::InfoTransform' ;
with 'InfoGopher::InfoTransform::_InfoTransform' ;

use XML::Parser ;
use JSON::MaybeXS ;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;
use InfoGopher::InfoTransform::XML_ATOM_Style ;

# ATOM XML Example: https://en.wikipedia.org/wiki/Atom_(Web_standard)
# application/rss+xml
has 'xml_parser' => (
    documentation   => 'xml parser for reading ATOM',
    is              => 'rw',
    isa             => 'Maybe[XML::Parser]',
    lazy            => 1,
    builder         => '_build_xml_parser' ,
) ;

sub _build_xml_parser
    {
    return XML::Parser -> new( Style => 'InfoGopher::InfoTransform::XML_ATOM_Style' ) ;
    }

# -----------------------------------------------------------------------------
# transform
#
# in    $info_bite
#
# ret   $info_bites
#
sub transform
    {
    my ( $self, $info_bite) = @_ ;

    my $mime = $info_bite -> mime_type ;

    ThrowException("wrong mime type") 
        if ( $mime ne 'application/atom+xml' ) ;

    my $atom_tree ;

    try
        {
        # Might die ...
        $atom_tree = $self -> xml_parser -> parse ( $info_bite -> data ) ;
        }
    catch
        {
        # ... so we translate this to an exception 
        ThrowException("Invalid XML received: " . $_) ;
        } ;

    my $ibites = InfoGopher::InfoBites -> new () ;

    if ( $self -> get_option('split') )
        {
        foreach my $entry ( @{$atom_tree ->{entries}} )
            {
            #!dump($entry->{title})!
            my $json_item = { } ;
            foreach my $key ( qw ( title link id updated summary content ) )
                {
                $json_item -> {$key} = $entry -> {$key} ;
                }
            # mimetype is application/json..
            my $new_bit = $info_bite -> clone ;
            $new_bit -> mime_type ( 'application/json' ) ;
            $new_bit -> data ( JSON -> new -> encode($json_item) ) ;
            $ibites -> add ( $new_bit ) ;
            }        
        }
    else
        {
        my $new_bit = $info_bite -> clone ;
        $new_bit -> mime_type ( 'application/json' ) ;
        $new_bit -> data ( JSON -> new -> encode($atom_tree) ) ;
        $ibites -> add ( $new_bit ) ;
        }

    return $ibites ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoTransform::RSS2JSON - transform RSS to JSON

Creates one infobit for each item from each channel

=head1 USAGE

my $deRSS = InfoGopher::InfoTransform::RSS2JSON -> new () ;

my $json_infobits = $transformation -> transform ($rss_infobit) 

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
