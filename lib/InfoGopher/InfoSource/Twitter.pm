package InfoGopher::InfoSource::Twitter ;

# Fetch updates from Twitter API

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
use Devel::StealthDebug ENABLE => $ENV{dbg_twitter} || $ENV{dbg_source} ;
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

has 'user_token' => (
    documentation   => 'twitter user token',
    is              => 'rw',
    isa             => 'Maybe[Str]',
) ;

has 'user_secret' => (
    documentation   => 'twitter user secret',
    is              => 'rw',
    isa             => 'Maybe[Str]',
) ;

has 'app_token' => (
    documentation   => 'twitter app token',
    is              => 'rw',
    isa             => 'Maybe[Str]',
) ;

has 'app_secret' => (
    documentation   => 'twitter app secret',
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
    my $i = NewIntention ( "Fetch Twitter $name:" . $self -> uri ) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=pod

=cut
