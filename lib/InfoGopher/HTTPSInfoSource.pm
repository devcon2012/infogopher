package InfoGopher::HTTPSInfoSource ;

# extends http infosource to work with certificates and credentials
# - adds a cookie jar
# - adds ca store

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use HTTP::CookieJar::LWP;
use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::Essentials ;

extends 'InfoGopher::HTTPInfoSource' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# overload _build_needs_credentials to require credentials
has 'needs_credentials' => (
    documentation   => 'predicate determining if this needs user/pw or ..',
    is              => 'ro',
    isa             => 'Bool',
    lazy            => 1,
    builder         => '_build_needs_credentials',
) ;
sub _build_needs_credentials
    {
    return 0;
    }

has 'cookie_jar' => (
    documentation   => 'http request cookie jar',
    is              => 'rw',
    isa             => 'Maybe[HTTP::CookieJar::LWP]',
    lazy            => 1,
    builder         => '_build_cookie_jar',
) ;
sub _build_cookie_jar
{
    my $self = shift ;
    my $jar = HTTP::CookieJar::LWP->new ;

    $self -> user_agent -> cookie_jar ( $jar ) ;

    return $jar;
}

has 'ca_store' => (
    documentation   => 'https ca store (file or path)',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => "/etc/ssl/certs"
) ;

has 'allow_untrusted' => (
    documentation   => 'allow read from untrusted sources',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

# we introduce pw here because pws can thus only be used over 
# encrypted connections ...
has 'pw' => (
    documentation   => 'password for authentication',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'login_url' => (
    documentation   => 'password',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# --------------------------------------------------------------------------------------------------------------------
# login - login to site: send a http request, store token or ... in cookie jar
#       this will force the user agent to only accept https and disallow untrusted sites.
#
# in    $request    http request prepared with credentials (username/pw)
#
# ret   $response   http response object

sub login
    {
    my ( $self, $request ) = @_ ;

    my $ua = $self -> user_agent ;

    # if we need to login:
    #  + we allow no unencrypted connections
    #  + we allow no untrusted sources
    $ua -> protocols_allowed( [ 'https' ] ) ;
    $self -> allow_untrusted ( 0 ) ;

    my $res = $self -> get_https($request) ;

    if ( $res -> is_success )
        {
        $self -> last_fetch(time) ;
        $self -> raw ( $res -> content ) ;
        }
    else
        {
        my $what = "http error: " . $res -> status_line . " msg:" . $res -> code ;
        ThrowException($what) ;
        }

    return $res ;    
    }

# --------------------------------------------------------------------------------------------------------------------
# get_https - configure ca store, perform https request, check result
#
# in    [$req]   http request, defaults to $self -> request
#       [$ua]    user agent, defaults to $self -> user_agent
#
# ret   $response   http response object

sub get_https
    {
    my ($self, $req, $ua) = @_ ;

    $ua  //= $self -> user_agent ;
    $req //= $self -> request ;

    $ua -> ssl_opts( 
         verify_hostname => ! $self -> allow_untrusted,
          );
    my $ca = $self -> ca_store ;

    $ua -> ssl_opts( SSL_ca_path => $ca )
        if ( -d $ca ) ;

    $ua -> ssl_opts( SSL_ca_file => $ca )
        if ( -f $ca ) ;

    if ( ! -r $ca && ! $self -> allow_untrusted )
        {
        my $what = "SSL error: only trusted connections allowed, but no CAs in '$ca'";
        ThrowException($what) ;
        }

    my $res = $ua->request($req) ;
    $self -> response ( $res ) ;

    if ( $res -> is_success )
        {
        $self -> last_fetch(time) ;
        $self -> raw ( $res -> decoded_content ) ;
        }
    else
        {
        my $what = "https error: " . $res -> status_line . " msg:" . $res -> code ;
        ThrowException($what) ;
        }

    my $t = $self -> expected_mimetype ;
    if ( $t )
        {
        my ($t2, $dummy) = split( ';', $res -> header ('Content-Type') );
        Logger("WARN: expected content $t, but got $t2") 
            if ( $t ne $t2 ) ;
        }

    return $res ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;



=head1 NAME

InfoGopher::HTTPSInfoSource - virtual base class for all https based infosources
(based on InfoGopher::HTTPInfoSource)

=head1 USAGE

my $source = InfoGopher::HTTPSInfoSource -> new ( uri => "https://...") ;

class contains a cookie jar + user/pw store to keep track of credentials.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut

