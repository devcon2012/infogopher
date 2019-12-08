package InfoGopher::HTTPInfoSource ;

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

use constant source_type => 'virtual_base_class' ;

has 'user_agent' => (
    documentation   => 'http request user agent',
    is              => 'rw',
    isa             => 'Maybe[LWP::UserAgent]',
    lazy            => 1,
    builder         => '_build_user_agent',
) ;
sub _build_user_agent
{
    my $self = shift ;
    my $ua = LWP::UserAgent -> new ;
    $ua -> agent ( "InfoGopher" ) ;
    return $ua;
}
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

has 'request' => (
    documentation   => 'http request',
    is              => 'rw',
    isa             => 'Maybe[HTTP::Request]',
    lazy            => 1,
    builder         => '_build_request',
) ;
sub _build_request
{
    my $self = shift ;
    my $r = HTTP::Request -> new ( GET => $self -> uri ) ;
    return $r ;
}

has 'response' => (
    documentation   => 'http response',
    is              => 'rw',
    isa             => 'Maybe[HTTP::Response]',
    default         => undef ,
) ;

sub get_http
    {
    my ($self, $req, $ua) = @_ ;

    $ua  //= $self -> user_agent ;
    $req //= $self -> request ;

    my $res = $ua->request($req) ;
    $self -> response ( $res ) ;

    if ( $res -> is_success )
        {
        $self -> last_fetch(time) ;
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