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

with 'InfoGopher::_URI' ; 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'info_bites' => (
    documentation   => 'info_bites to be sent',
    is              => 'rw',
    isa             => 'InfoGopher::InfoBites',
    lazy            => 1,
    builder         => '_build_info_bites',
) ;
sub _build_info_bites
    {
    return InfoGopher::InfoBites -> new () ;
    }

has 'info_renderer' => (
    documentation   => 'transform infobites to a type suit for this receiver (defaults to a raw renderer)',
    is              => 'rw',
    isa             => 'InfoGopher::InfoRenderer',
    lazy            => 1,
    builder         => '_build_info_renderer',
) ;
sub _build_info_renderer
    {
    return InfoGopher::InfoRenderer::RawRenderer -> new ;
    }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# -----------------------------------------------------------------------------
#
# filter_input_infobites - weed out infobites not of interest. Takes all, overload if this is not what you want
#   
# in    $infobites

sub filter_input_infobites
    {
    my ( $self, $infobites ) = @_ ;

    $self -> infobites ( $infobites ) ;

    return ;    
    }

# -----------------------------------------------------------------------------
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
* an email account receiving periodic updates

=head1 USAGE

(TODO)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
