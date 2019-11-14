package InfoGopher::InfoSource::RSS ;

#
# InfoGopher - A framework for collection information
#
#   (c) Klaus Ramstöck klaus@ramstoeck.name 2019
#
# You can use and distribute this software under the same conditions as perl
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_rss};

use Moose;
use MooseX::ClassAttribute ;
use Try::Tiny;

use XML::Parser ;

use InfoGopher::Essentials ;

use InfoGopher::InfoTransform::XML_RSS_Style ;

extends 'InfoGopher::HTTPInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;

# RSS XML Example: https://de.wikipedia.org/wiki/RSS_(Web-Feed)
# application/rss+xml
class_has 'xml_parser' => (
    documentation   => 'xml parser for reading RSS',
    is              => 'rw',
    isa             => 'Maybe[XML::Parser]',
    lazy            => 1,
    builder         => '_build_xml_parser' ,
) ;
sub _build_xml_parser
    {
    return XML::Parser -> new( Style => 'InfoGopher::InfoTransform::XML_RSS_Style' ) ;
    }

# -----------------------------------------------------------------------------
# fetch - get fresh copy from RSS InfoSource
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch RSS $name:" . $self -> uri ) ;

    $self -> get_http ;

    my $tree ;
    try
        {
        # this might die ..
        $tree = $self -> xml_parser -> parse ( $self -> raw ) ;
        }
    catch
        {
        # ... so we translate this to an exception
        ThrowException("Invalid XML received: " . $_) ;
        } ;

    #!dump($tree)!
    
    $self -> info_bites -> clear() ;

    $self -> add_info_bite ( 
            $self -> raw, 
            $self -> response -> header('content-type'),
            time ) ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;
