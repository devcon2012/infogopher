package InfoGopher::InfoTransform::HTMLExtractor::TagTransformer ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_transform2} || $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use HTML::TreeBuilder ;
use Try::Tiny;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;


has 'style' => (
    documentation   => 'hashref of transform style',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    builder         => '_build_style',
) ;
sub _build_style
    {
    return 'href,resolve' ;
    }

# -----------------------------------------------------------------------------
# process - process one prefiltered tag
#
# in    $c      HTML::Element
#       $bite   original info bite
#
# ret   $info_bites
#
sub process
    {
    my ( $self, $c, $bite)  = @_ ;

    my $bites ; 

    my $style = $self -> style ;
    my %styles = map { ucfirst $_ , 1} split (',', $style) ;

    if ( $styles{href} )
        {
        my $href = $c -> attr('href') || $c -> attr('src') ;
        #!dump($href)!
        if ($href)
            {
            $bites = InfoGopher::InfoBites -> new ;
            $bites -> add_info_bite 
                (
                $href ,
                ( $c -> attr('href') ? 'text/link' : 'image/link' ),
                $bite -> time_stamp,
                $bite -> meta_infos
                ) ;
            }
        }
    elsif ( $styles{'text'} )
        {
        # $data, $mime_type, $time_stamp, $meta)
        $bites = InfoGopher::InfoBites -> new ;
        $bites -> add_info_bite 
            (
            $c -> dump ,
            'text/ascii',
            $bite -> time_stamp,
            $bite -> meta_infos
            ) ;
        }
    else
        {
        ThrowException("No such style in " . __PACKAGE__ . ": $style") ;
        }

    return $bites ;
    }

1 ;

__PACKAGE__ -> meta -> make_immutable ;
