package InfoGopher::InfoGradient ;

# see below for docu and copyright information
# tests: Factory.t - instantiation
#       

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_source} ;

use InfoGopher::Essentials ;

use Data::Dumper;
use Moose;
use Try::Tiny;


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has '_map' => (
    documentation   => '',
    is              => 'rw',
    isa             => 'ArrayRef',
    lazy            => 1,
    default         => sub { [] } ,
) ;

has '_resolved_map' => (
    documentation   => '',
    is              => 'rw',
    isa             => 'ArrayRef',
    lazy            => 1,
    default         => sub { [] } ,
) ;

has 'source_sink_map' => (
    documentation   => 'json config to connect info sources to info sinks',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    default         => '' ,
    trigger         => \&_build_map ,
) ;
sub _build_map
    {
    my ($self, $json) = @_ ;

    if ( $json )
        {
        $self -> _resolve_names($json) ;
        }
    return ;
    }

has 'name' => (
    documentation   => 'Name of this gradient',
    is              => 'rw',
    isa             => 'Str',
    default         => ''
) ;


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# -----------------------------------------------------------------------------
#
# flow_info -  propagate info from an infosource to all mapped sinks
#
#   
#
sub flow_info
    {
    my ( $self, $source ) = @_ ;

    my $n = $source -> name ;
    my $i = NewIntention ( "Flow information from: $n" ) ;

    my $map = $self -> source_sink_map ;

    foreach my $m ( @$map )
        {
        my ( $from, $to ) = @$m ;

        if ( $from == $source )
            {
            my $i = NewIntention ( "Propagate information from $n to: " . $to -> name ) ;
            my $info_bites = $source -> info_bites;
            $to -> filter_info_bites ( $info_bites ) ;
            $to -> push_infos ;
            }
        }
    return ;
    }


# -----------------------------------------------------------------------------
#
# _resolve_names - 
#
#   
#
sub _resolve_names
    {
    my ( $self, $gopher ) = @_ ;

    my $n = $self -> name ;
    my $i = NewIntention ( "Resolve source/sink names in gradient $n" ) ;

    my $name_map = $self -> _map ;
    my $ref_map  = [] ;

    foreach my $m ( @$name_map )
        {
        my ( $name_from, $name_to ) = @$m ;
        my $from = $gopher -> find_sink_byname ( $name_from ) ; 
        my $to   = $gopher -> find_source_byname ( $name_to ) ;
        push @$ref_map, [ $from, $to ] ;
        }

    $self -> source_sink_map ( $ref_map ) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=head1 NAME

InfoGopher::InfoGradient - connect InfoSources to InfoSinks


=head1 USAGE


=head1 TRANSFORMATIONS

=head2 RSS2JSON

This transformation takes a application/rss+xml infobit and transforms it into
a list of JSO

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
