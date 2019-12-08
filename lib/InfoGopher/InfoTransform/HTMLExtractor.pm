package InfoGopher::InfoTransform::HTMLExtractor ;

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
use InfoGopher::InfoTransform::HTMLExtractor::TagTransformer ;

has 'html_parser' => (
    documentation   => 'html parser',
    is              => 'rw',
    isa             => 'Maybe[HTML::TreeBuilder]',
    lazy            => 1,
    builder         => '_build_html_parser' ,
) ;
sub _build_html_parser 
    {
    return HTML::TreeBuilder -> new( ) ;
    }

has 'wanted_tags' => (
    documentation   => 'hashref of wanted tags in lower caps',
    is              => 'rw',
    isa             => 'HashRef[Str]',
    lazy            => 1,
    builder         => '_build_wanted_tags',
) ;
sub _build_wanted_tags
    {
    return { a => 1, img => 1, h1 => 1, h2 => 1} ;
    }

has 'wanted_class' => (
    documentation   => 'hashref of wanted classes in lower caps',
    is              => 'rw',
    isa             => 'HashRef[Str]',
    lazy            => 1,
    builder         => '_build_wanted_classes',
) ;
sub _build_wanted_classes
    {
    return { 'title' => 1} ;
    }

has 'wanted_ids' => (
    documentation   => 'hashref of wanted items',
    is              => 'rw',
    isa             => 'HashRef[Str]',
    lazy            => 1,
    builder         => '_build_wanted_ids',
) ;
sub _build_wanted_ids
    {
    return { } ;
    }

has 'tag2ibite' => (
    documentation   => 'callback transforming filtered tags to an infobite',
    is              => 'rw',
    isa             => 'InfoGopher::InfoTransform::HTMLExtractor::TagTransformer',
    lazy            => 1,
    builder         => '_build_tag2ibite',
) ;
sub _build_tag2ibite
    {
    return InfoGopher::InfoTransform::HTMLExtractor::TagTransformer->new ( ) ;
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
        if ( $mime !~ 'html' ) ;

    my $ibites = InfoGopher::InfoBites -> new () ;

    try 
        {
        $self -> html_parser -> parse_content ( $info_bite -> data ) ;
        }
    catch
        {
        ThrowException($_) ;
        } ;

    $self -> _add_infobite_maybe( $ibites,  $self -> html_parser, $info_bite) ;
 
    return $ibites ;
    }

# -----------------------------------------------------------------------------
# _add_infobite_maybe
#
sub _add_infobite_maybe
    {
    my ($self, $ibites, $n, $bite) = @_ ;

    foreach my $c ( $n -> content_list )
        {
        next if ! ref $c ; 
        my $tag = $c -> tag ;
        my $class = $c -> attr('class') || '';
        my $id = $c -> attr('id') || '';
        if  ( 
                defined $self -> wanted_tags -> {$tag} 
             && defined $self -> wanted_class -> {$class} 
             || defined $self -> wanted_ids -> {$id} 
            )
            {
            my $add = $self -> tag2ibite -> process($c, $bite) ;
            $ibites -> merge ($add) if ($add) ;
            }
        $self -> _add_infobite_maybe ($ibites, $c, $bite) if ( ref $c ) ;
        }
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1 ;

=head1 USAGE

my $linkextractor = InfoGopher::InfoTransform::HTMLExtractor -> new ( ) ;

my $links = $linkextractor -> transform ($html_page) ; 

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
