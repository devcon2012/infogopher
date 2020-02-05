package InfoGopher::InfoSource::Zimbra ;

# Fetch updates from Zimbra API

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
use Devel::StealthDebug ENABLE => $ENV{dbg_zimbra} || $ENV{dbg_source} ;
use Data::Dumper ;

use URL::Encode qw ( url_encode ) ;

use Moose ;
use Try::Tiny ;

use InfoGopher::Essentials ;


extends 'InfoGopher::HTTPSInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'auth_token' => (
    documentation   => 'zimbra auth token',
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
    my $i = NewIntention ( "Fetch Zimbra $name:" . $self -> uri ) ;

    my $jar = $self -> cookie_jar ;

    my $version = 0 ;
    my $key = "ZM_AUTH_TOKEN" ;
    my $val = $self -> auth_token ;
    my $path = "/" ;
    my $domain = $self -> host ;
    my $port = $self -> port ;
    my $path_spec = 1 ;
    my $secure = 1 ;
    my $maxage = 3600 ;
    my $discard = 0 ;
    my %rest ;
    $jar->set_cookie( $version, $key, $val, $path, $domain, $port, $path_spec, $secure, $maxage, $discard, \%rest ) ;
    # The set_cookie() method updates the state of the $cookie_jar. The $key, $val, $domain, $port and $path arguments 
    # are strings. The $path_spec, $secure, $discard arguments are boolean values. The $maxage value is a number 
    # indicating number of seconds that this cookie will live. A value of $maxage <= 0 will delete this cookie. 
    # The $version argument sets the version of the cookie; the default value is 0 ( original Netscape spec ). 
    # Setting $version to another value indicates the RFC to which the cookie conforms (e.g. version 1 for RFC 2109). 
    # %rest defines various other attributes like "Comment" and "CommentURL".


    $self -> get_https ( ) ;

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
