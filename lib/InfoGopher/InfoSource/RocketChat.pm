package InfoGopher::InfoSource::RocketChat ;

# Fetch updates from Rocketchat API
# https://rocket.chat/docs/developer-guides/

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
use Devel::StealthDebug ENABLE => $ENV{dbg_rc} || $ENV{dbg_source} ;
use Data::Dumper ;

use URL::Encode qw ( url_encode ) ;

use Moose ;
use Try::Tiny ;

use InfoGopher::Essentials ;


extends 'InfoGopher::InfoSource::HTTPSInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'auth_token' => (
    documentation   => 'rocketchat auth token',
    is              => 'rw',
    isa             => 'Maybe[Str]',
) ;

has 'auth_user' => (
    documentation   => 'rocketchat auth token user',
    is              => 'rw',
    isa             => 'Maybe[Str]',
) ;

sub _build_expected_mimetype
    {
    return 'application/json' ;
    }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# fetch - get fresh copy from RSS InfoSource
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch RocketChat $name:" . $self -> uri ) ;

    my $req = $self -> request ;
    $req -> header ( 'X-Auth-Token' => $self -> auth_token ) ;
    $req -> header ( 'X-User-Id' => $self -> auth_user ) ;
    $req -> header ( 'Content-type' => 'application/json' ) ;

    my $query = 'query={"text": "rocket", "type": "users", "workspace": "local"}' ;
    $req -> uri ( $self -> uri . "?" . url_encode($query) ) ;

    my $ua  = $self -> user_agent ;

    $self -> get_https ( $req, $ua ) ;

    $self -> info_bites -> clear () ;

    # copy my id to bites so consumer can later track its source
    $self -> info_bites -> source_name ( $self -> name ) ;
    $self -> info_bites -> source_id ( $self -> id ) ;

    my $newbite = $self -> add_info_bite ( 
            $self -> raw, 
            'application/json',
            time ) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=pod

=cut
