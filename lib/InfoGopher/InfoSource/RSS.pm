package InfoGopher::InfoSource::RSS ;

# same as Web, but forges a 

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
use namespace::autoclean ;
use Devel::StealthDebug ENABLE => $ENV{dbg_rss} || $ENV{dbg_source} ;
use Data::Dumper ;

use Moose ;
use Try::Tiny ;

use InfoGopher::Essentials ;

use InfoGopher::InfoTransform::RSS2JSON ;

extends 'InfoGopher::HTTPSInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;

# -----------------------------------------------------------------------------
# fetch - get fresh copy from RSS InfoSource
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch RSS $name:" . $self -> uri ) ;

    $self -> get_https ;

    $self -> info_bites -> clear() ;

    # copy my id to bites so consumer can later track its source
    $self -> info_bites -> source_name ( $self -> name ) ;
    $self -> info_bites -> source_id ( $self -> id ) ;

    my $newbite = $self -> add_info_bite ( 
            $self -> raw, 
            'application/rss+xml',
            time ) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;
