package InfoGopher::InfoTransform::RSS2JSON ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Moose;
use Try::Tiny;

use XML::Parser ;
use JSON ;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;
use InfoGopher::InfoTransform::XML_RSS_Style ;

# RSS XML Example: https://de.wikipedia.org/wiki/RSS_(Web-Feed)
# application/rss+xml
has 'xml_parser' => (
    documentation   => 'xml parser for reading RSS',
    is              => 'rw',
    isa             => 'Maybe[XML::Parser]',
    lazy            => 1,
    builder         => '_build_xml_parser' ,
) ;

sub _build_xml_parser
    {
    return XML::Parser -> new( Style => 'InfoGopher::InfoTransform::XML_RSS_Style' ) ;
    #return XML::Parser -> new( Style => 'Tree' ) ;
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
        if ( $mime ne 'application/rss+xml' ) ;

    my $rss_tree ;

    try
        {
        # Might die ...
        $rss_tree = $self -> xml_parser -> parse ( $info_bite -> data ) ;
        }
    catch
        {
        # ... so we translate this to an exception
        ThrowException("Invalid XML received: " . $_) ;
        } ;

    my $tree = $rss_tree  ;
    #!dump( $tree )!

    my $ibites = InfoGopher::InfoBites -> new () ;

    #!dump("Channels: ". @{$tree -> {channels}} )!
    foreach my $channel ( @{$tree -> {channels}} )
        {
        #!dump("Items: ". @{$channel ->{items}} )!
        foreach my $item ( @{$channel ->{items}} )
            {
            #!dump($item->{title})!
            my $json_item = { } ;
            foreach my $key ( qw ( title author pubDate ) )
                {
                $json_item -> {$key} = $item -> {$key} ;
                }
            # mimetype is application/json..
            my $new_bit = $info_bite -> clone ;
            $new_bit -> mime_type ( 'application/json' ) ;
            $new_bit -> data ( JSON -> new -> encode($json_item) ) ;
            $ibites -> add ( $new_bit ) ;
            }        
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
