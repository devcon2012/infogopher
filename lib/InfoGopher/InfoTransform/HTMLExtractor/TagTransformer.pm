package InfoGopher::InfoTransform::HTMLExtractor::TagTransformer ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use HTML::TreeBuilder ;
use Try::Tiny;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;


has 'style' => (
    documentation   => 'string of transform styles',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    builder         => '_build_style',
) ;
sub _build_style
    {
    return 'href,resolve' ;
    }

 sub _text_content
    {
    my ($c) = @_ ;
    my $text = '' ;
    my @content = $c->content_list ;

    foreach ( @content )
        {
        $text .= $_ if ( ! ref $_ ) ;
        }
    return $text ;
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
    my ( $self, $c, $bite) = @_ ;

    my $bites ; 

    my $style = $self -> style ;
    my %styles = map { ( (lc $_) , 1) } split (',', $style) ;
 
    #!dump(\%styles)!
    
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
    elsif ( $styles{text} )
        {
        # $data, $mime_type, $time_stamp, $meta)
        $bites = InfoGopher::InfoBites -> new ;
        $bites -> add_info_bite 
            (
            _text_content($c)  ,
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

__PACKAGE__ -> meta -> make_immutable ;

1 ;


=head1 NAME

InfoGopher::InfoTransform::HTMLExtractor::TagTransformer - extract bits from HTML

=head1 USAGE

my $source = InfoGopher::InfoSource::InfoSource -> new ( uri => "https://...") ;
my $t = InfoGopher::InfoTransform::HTMLExtractor::TagTransformer -> new ( ) ;
$source -> transormation ( $t ) ;
$source -> name ("News page") ;
$source -> fetch () ;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
