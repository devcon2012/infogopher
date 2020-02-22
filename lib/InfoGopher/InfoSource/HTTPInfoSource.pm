package InfoGopher::InfoSource::HTTPInfoSource ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Devel::StealthDebug ENABLE => $ENV{dbg_infosource} ;

use Moose;
use Try::Tiny;

use LWP::UserAgent ;
use HTTP::Request ;

use InfoGopher::Essentials ;

extends 'InfoGopher::InfoSource' ;
with 'InfoGopher::_HTTP' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


has 'expected_mimetype' => (
    documentation   => '(undef if any mimetype ok)',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    lazy            => 1,
    builder         => '_build_expected_mimetype',
) ;
sub _build_expected_mimetype
    {
    return ;
    }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# --------------------------------------------------------------------------------------------------------------------
# get_http - perform http request, check result
#
# in    [$req]   http request, defaults to $self -> request
#       [$ua]    user agent, defaults to $self -> user_agent
#
# ret   $response   http response object

sub get_http
    {
    my ($self, $req, $ua) = @_ ;

    $req //= $self -> request ;
    $ua  //= $self -> user_agent ;

    my $res = $ua->request($req) ;
    $self -> response ( $res ) ;

    if ( $res -> is_success )
        {
        $self -> last_network_activity(time) ;
        $self -> raw ( $res -> decoded_content ) ;
        }
    else
        {
        my $what = "http error: " . $res -> status_line . " msg:" . $res -> code ;
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

InfoGopher::InfoSource::HTTPInfoSource - virtual base class for all http based infosources

=head1 USAGE

my $source = InfoGopher::InfoSource::HTTPInfoSource -> new ( uri => "http://...") ;
$source -> name ("xx webfeed") ;
$source -> fetch () ;

A HTTP Infosource intentionaly contains no authentication method to discourage
unencrypted submission of credentials.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut

