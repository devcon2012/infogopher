package TinyMock::HTTP ;

use strict ;
use warnings ;

#use POSIX ":sys_wait_h"; # needed for WNOHANG
use HTTP::Daemon;
use HTTP::Status;

use Moose ;

extends 'TinyMock::Simple' ;

use Data::Dumper ;

our $shutdown ;
$SIG{USR1} = sub { $shutdown = 1; } ;

sub _build_default_port { return 7080; }

sub build_server_socket
    {
    my ( $self ) = @_ ;

    my $port = $self -> port ;

    while ( $port )
        { 
        my $server = HTTP::Daemon->new 
                (
                LocalAddr => '127.0.0.1',
                LocalPort => $self -> port,
                ) or print "failed to HTTP listen on $port: $! - try next\n" ;

        return ($server, "HTTP Listening 127.0.0.1:$port\n") 
            if (ref $server) ;
        $port ++ ;
        $self -> port ($port) ;
        #warn "port changed to $port" ;
        } 

    }

sub accept_fail_msg 
    {
    return "Failed to accept on " . shift -> port ;
    }

sub run
    {
    my ( $self, $server, $listen_message ) = @_ ;
    
    my ( $connection, $sockaddr) ;
    while ( 1 )
        {
        print STDERR "$$: $listen_message" 
            if ($self -> _verbose ) ;

        ( $connection, $sockaddr ) = $server -> accept ;

        last if ( $shutdown ) ;

        die $self -> accept_fail_msg 
            if ( ! $connection ) ;

        my ($client_port, $client_address) = sockaddr_in $sockaddr ;
        print STDERR "connection from $client_address:$client_port\n"
            if ($self -> _verbose ) ;;

        last if ( ! $self -> handle_connect( $connection ) ) ;
        undef $connection ;
        }
    
    $connection ? $connection -> close : 0 ;
    undef $connection ;
    undef $server ;
    
    print STDERR "End HTTP Server\n" 
        if ($self -> _verbose ) ;
        
    exit 0 ;
    }

sub get_response
    {
    my $self = shift ;
    my $content = $self -> get_responsefile_content ;

    my $r = HTTP::Response->parse( $content ) ;
    #print STDERR $r -> as_string ;

    return $r ;
    }

sub handle_request
    {
    my ($self, $connection, $request) = @_ ;

    my $response = $self -> get_response() ;

    if ( $response )
        {
        $connection -> send_response ( $response ) ;
        }
    else
        {
        return 0 ;
        }

    return 1 ;
    }

sub handle_connect
    {
    my ($self, $connection) = @_ ;

    my $status ;
    while (my $request = $connection  -> get_request ) 
        {
        $status = $self -> handle_request ( $connection, $request ) ;
        last if ( ! $status ) ;
        }
    
    $connection -> close() ;
    undef $connection;
    return $status ;
    }

1 ;