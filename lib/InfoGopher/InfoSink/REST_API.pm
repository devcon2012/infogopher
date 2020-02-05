package InfoGopher::InfoSink::REST_API ;

# Generic Class for REST API where you can post stuff.

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
use namespace::autoclean ;
use Devel::StealthDebug ENABLE => $ENV{dbg_sink} | $ENV{dbg_rest} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;

extends 'InfoGopher::InfoSink' ;
with 'InfoGopher::_URI' ;
with 'InfoGopher::_HTTP' ;
with 'InfoGopher::_HTTPS' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub _build_info_renderer
    {
    return InfoGopher::InfoRenderer::JsonRenderer -> new ;
    }

# -----------------------------------------------------------------------------
#
# push_info - virtual method to send infobites to receiver
#   
# in    [$infobites]    defaults to member infobites  
#
sub push_info
    {
    my ( $self, $infobites ) = @_ ;

    $infobites //= $self -> info_bites ;

    my $n = $infobites -> count ;
    my $url = $self -> url ;
    my $i = NewIntention ( "Send $n infobites to $url" ) ;

    my $renderer = $self -> renderer ;

    my $r = HTTP::Request -> new ( GET => $self -> uri ) ;
    $self -> request ( $r ) ;

    foreach ( $infobites -> all )
        { 
        my $data = $renderer -> process ( $_ ) ;
        $r -> 
        }

    return ;
    }


# --------------------------------------------------------------------------------------------------------------------
# post_https - configure ca store, perform https request, check result
#
# in    [$req]   http request, defaults to $self -> request
#       [$ua]    user agent, defaults to $self -> user_agent
#
# ret   $response   http response object

sub post_https
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

    return $res ;
    }    

__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoSink::EmailReceiver - send infobites via email


=head1 USAGE

(TODO)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
