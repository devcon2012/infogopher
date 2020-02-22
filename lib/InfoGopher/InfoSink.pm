package InfoGopher::InfoSink ;

# InfoGopher::InfoSink describes a receiver of infobites
# see pod at the end of this file.

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
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_sink} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::Factory ;

extends 'InfoGopher::InfoDivergence' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'info_filter' => (
    documentation   => 'filter infobites entered',
    is              => 'rw',
    isa             => 'InfoGopher::InfoFilter',
    lazy            => 1,
    builder         => '_build_info_filter',
) ;
sub _build_info_filter
    {
    return InfoGopher::InfoFilter::PassAll -> new () ;
    }

has 'filter_specs' => (
    documentation   => 'infobites filter specifications',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    trigger         => \&_update_info_filter,
    default         => '',
) ;
sub _update_info_filter
    {
    my ($self, $json, $old) = @_ ;
    if ( $json )
        {
        my $filter = InfoGopher::Factory -> build_filter ( $json ) ;
        $self -> info_filter ( $filter ) ;
        }
    return ;
    }

has 'renderer' => (
    documentation   => 'default data processing on output, if any',
    is              => 'rw',
    isa             => 'Maybe[InfoGopher::InfoRenderer]',
    lazy            => 1,
    builder         => '_build_renderer'
) ;
sub _build_renderer
    {
    return InfoGopher::InfoRenderer::RawRenderer -> new ;
    }

has 'renderer_specs' => (
    documentation   => 'infobites renderer specifications',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    trigger         => \&_update_renderer,
    default         => '' ,
) ;
sub _update_renderer
    {
    my ($self, $json, $old) = @_ ;
    if ( $json )
        {
        my $renderer = InfoGopher::Factory -> build_renderer ( $json ) ;
        $self -> renderer ( $renderer ) ;
        }
    return ;
    }


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# --------------------------------------------------------------------------------------------------------------------
#
# filter_infobites - set the infobites for this sink, but filter first
#   
# in    $infobites    infobites filtered and used  
#
sub filter_infobites
    {
    my ( $self, $infobites ) = @_ ;

    my $filtered_infobites = $self -> filter -> filter_all ( $infobites ) ;
    $self -> info_bites ( $filtered_infobites ) ;
    
    return ;
    }

# --------------------------------------------------------------------------------------------------------------------
#
# push_infos - virtual method to send infobites to a receiver
#   
# in    [$infobites]    defaults to member infobites  
#
sub push_infos
    {
    my ( $self, $infobites ) = @_ ;

    $infobites //= $self -> info_bites ;

    die "VIRTUAL push_info in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;
    
    }


__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoSink - virtual base class for receivers of aggregated information

could be:
    * a ref to a perl scalar used by some other part of a larger program
    * a file handle
    * an email account receiving periodic updates
    * a REST Interface
    * an MQTT server
    * ...

=head1 USAGE

my $filereceiver = InfoGopher::InfoSink::FileReceiver -> new () ;

$filereceiver -> push_info ( $infobites ) ;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
