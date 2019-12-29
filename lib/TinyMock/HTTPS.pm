package TinyMock::HTTPS ;

use strict ;
use warnings ;

#use POSIX ":sys_wait_h"; # needed for WNOHANG
use HTTP::Daemon::SSL;
use IO::Socket::SSL ;

use Moose ;

extends 'TinyMock::HTTP' ;

use Data::Dumper ;

sub _build_default_port { return 7443; }

has 'crypto' => (
    documentation   => 'crypto file name base',
    is              => 'rw',
    isa             => 'Str',
    default         => '',
) ;

# -----------------------------------------------------------------------------
# setup module 
#
# in    $content_fn
#       [$response
#       [$port 
#
sub setup
    {
    my ($self, $crypto, $content_fn, $port, $response, ) = @_ ;

    $self -> crypto ( $crypto ) ;

    return $self -> SUPER::setup( $content_fn, $port, $response ) ;
    }

sub setup_server
    {
    my ( $self ) = @_ ;

    my $port   = $self -> port ;
    my $crypto = $self -> crypto ;
    my $crt    = $self -> crypto . ".crt" ;
    my $key    = $self -> crypto . ".key" ;

    while ( $port )
        {
        my $server = HTTP::Daemon::SSL->new 
                (
                LocalAddr => '127.0.0.1',
                LocalPort => $port,
                #SSL_verify_mode => SSL_VERIFY_PEER,
                SSL_hostname => 'localhost',
                SSL_cert_file => $crt,
                SSL_key_file  => $key,
                ) or print "INFO: failed to HTTPS listen on $port: $! - try next\n" ;

        return ($server, "HTTPS ($crypto) Listening on 127.0.0.1:$port\n") 
            if ( $server );
        
        $port ++ ;
        $self -> port ( $port ) ;

        }
    return ;
    }

sub accept_fail_msg 
    {
    return "Failed to SSL accept on " . shift -> port . "($SSL_ERROR)" ;
    }


1 ;