package InfoGopher::InfoDivergence ;

# see below for docu and copyright information
# tests: abstract class - tested implicitly
#       
use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_source} ;

use Moose;
use Try::Tiny;

with 'InfoGopher::_URI' ;

use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::TextRenderer ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 
has 'name' => (
    documentation   => 'Information source name (for display only)',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

# 
has 'module_name' => (
    documentation   => 'just to allow this when we produce from json',
    is              => 'rw',
    isa             => 'Maybe[Str]',
) ;

# 
has 'update_interval' => (
    documentation   => 'recommended update interval for InfoGopher',
    is              => 'rw',
    isa             => 'Int',
    default         => 60,
) ;

# 
has 'id' => (
    documentation   => 'id from InfoGopher',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    trigger         => \&_update_infobites_id,
    default         => '-1' 
) ;
sub _update_infobites_id
    {
    my ($self, $id, $old_id) = @_ ;

    $id         //= '' ;
    $old_id     //= '' ;
    
    #!dump($newid)!
    $self -> info_bites -> source_id ( $id ) 
        if ( $id ne $old_id  );
    return ;
    };

has 'raw' => (
    documentation   => 'Raw data obtained/sent',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'last_network_activity' => (
    documentation   => 'Timestamp last raw data obtained/sent',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

has 'info_bites' => (
    documentation   => 'info_bites obtained',
    is              => 'rw',
    isa             => 'InfoGopher::InfoBites',
    lazy            => 1,
    builder         => '_build_info_bites',
) ;
sub _build_info_bites
    {
    return InfoGopher::InfoBites -> new () ;
    }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub BUILD 
    {
    my $self = shift ;

    return;
    }

# -----------------------------------------------------------------------------
# add_info_bite - add a new info bite to the list
#
# in    $data
#       $mime_type
#       $time_stamp
#       $meta
#
# ret   $bite
#
sub add_info_bite
    {
    my ($self) = @_ ;
    shift ;

    return $self -> info_bites -> add_info_bite( @_ ) ;

    }

# -----------------------------------------------------------------------------
# dump_info_bites - dump into bites as text (for debugging)
#
#
sub dump_info_bites
    {
    my ( $self, $msg ) = @_ ;

    my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;

    my $n = $self -> info_bites -> count ;
    print STDERR "$msg ($n)\n";

    my $last =0 ;
    foreach ( $self -> info_bites -> all )
        {
        print STDERR $renderer -> process ($_) . "\n" ;
        my $meta = $_ -> meta_infos ;
        if ( keys %$meta )
            {
            if ( $meta == $last)
                {
                print STDERR "  META: (same)\n" ;
                }
            else
                {
                print STDERR "  META: " . Dumper ( $meta ) ;
                }
            $last = $meta ;
            }
        }
    return ;
    }


__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoDivergence - abstract base for InfoSource / InfoSinks

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
