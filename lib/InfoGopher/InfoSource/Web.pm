package InfoGopher::InfoSource::Web ;

#
# InfoGopher - A framework for collecting information
#
#   (c) Klaus Ramstöck klaus@ramstoeck.name 2019
#
# You can use and distribute this software under the same conditions as perl
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;
use Devel::StealthDebug ENABLE => $ENV{dbg_html} ;


use Moose ;
use HTML::TreeBuilder ;
use Try::Tiny ;

use InfoGopher::Essentials ;

extends qw( InfoGopher::HTTPSInfoSource ) ;
with 'InfoGopher::InfoSource::_InfoSource' ;


# -----------------------------------------------------------------------------
# fetch - get fresh copy from the web
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch html $name:" . $self -> uri ) ;

    my $response = $self -> get_https ;

    $self -> info_bites -> clear() ;

    # copy my id to bites so consumer can later track its source
    $self -> info_bites -> source_name ( $self -> name ) ;
    $self -> info_bites -> source_id ( $self -> id ) ;

    my $newbite = $self -> add_info_bite ( 
            $self -> raw, 
            $response -> header ('Content-Type') ,
            time ) ;

    my @headers = $response -> header_field_names ;
    my $meta = $newbite -> meta_infos ;
    foreach (@headers)
        {
        $meta -> {$_} = $response -> header ($_) ;
        }

    }

__PACKAGE__ -> meta -> make_immutable ;

1;
