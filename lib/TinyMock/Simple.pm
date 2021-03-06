package TinyMock::Simple ;

# Tiny Mock Baseclass - listens on a socket, reads + responds with arbitrary data
# forks on listen ; child shuts down on signal USR1

use strict ;
use warnings ;
use Moose ;

use IO::Handle ;
use IO::File ;
use IO::Socket::INET;

use FindBin ;

use Data::Dumper ;

use Symbol 'gensym' ;
use Getopt::Long ;

use MooseX::ClassAttribute ;

# 
class_has 'mock_pid' => (
    documentation   => 'mock child pid (if any)',
    is              => 'rw',
    isa             => 'Maybe[Int]',
    default         => undef,
) ;

# 
class_has 'root' => (
    documentation   => 'mock child pid (if any)',
    is              => 'ro',
    isa             => 'Str',
    lazy            => 1,
    builder         => '_build_root',
) ;
sub _build_root
    {
    my $root = $ENV{MOCK_HOME};
    my $fb = "$FindBin::Bin/../TinyMock" ;
    $fb = "$FindBin::Bin/TinyMock" if ( ! -d $fb ) ;
    $root //= $fb ;
    $root //= "/tmp" ;
    return $root ;
    }
# 
class_has '_verbose' => (
    documentation   => 'set to 1 otherwise there is no output at all.',
    is              => 'rw',
    isa             => 'Str',
    default         => sub { 0 },
) ;

# 
has 'timeout' => (
    documentation   => 'mock listen timeout',
    is              => 'rw',
    isa             => 'Int',
    builder         => '_build_timeout',
) ;
sub _build_timeout { return 5; }

# 
has 'port' => (
    documentation   => 'mock listen port',
    is              => 'rw',
    isa             => 'Int',
    builder         => '_build_default_port',
) ;
sub _build_default_port { return 7773; }

has 'response' => (
    documentation   => 'mock response control file',
    is              => 'rw',
    isa             => 'Str',
    default         => 'response',
) ;
has 'data_received' => (
    documentation   => 'data from client',
    is              => 'rw',
    isa             => 'Str',
    default         => '',
) ;

our $shutdown ;
BEGIN { $SIG{USR1} = sub { $shutdown = 1; } }

# -----------------------------------------------------------------------------
# responsefile - filename where mock reads how to respond 
#
#
sub responsefile
    {
    my ($self, $response) = @_ ;
    $response //= $self -> response ;
    return $response ;
    }

# -----------------------------------------------------------------------------
# set_responsefile_content - copy response to responsefile
#
# in    $content_fn - filename with response content
#       [$response_file]
#
sub set_responsefile_content
    {
    my ($self, $content_fn, $response_file) = @_ ;

    $response_file //= $self -> responsefile () ;
    my $root = $self -> root ;

    my $content ;
        {
        open ( my $fh, "<", "$root/content/$content_fn" ) 
            or die "cannot open $root/content/$content_fn: $!" ;

        local $/ = undef;
        $content = <$fh> ;
        close $fh ;
        }

    open ( my $fh, ">", "$root/$response_file" ) 
        or die "cannot open $root/$response_file: $!" ;
    print $fh $content;
    close $fh ;
    return ;
    }

# -----------------------------------------------------------------------------
# get_responsefile_content 
#
# in    [$response_file]
#
sub get_responsefile_content
    {
    my ($self, $response_file) = @_ ;

    $response_file //= $self -> responsefile () ;
    my $root = $self -> root ;

    my $content ;
        {
        open ( my $fh, "<",  "$root/$response_file") 
            or die "cannot open $response_file: $!" ;

        local $/ = undef;
        $content = <$fh> ;
        close $fh ;
        }

    return $content ;
    }

# -----------------------------------------------------------------------------
# setup module 
#
# in    $content_fn
#       [$port]
#       [$response] 
#
sub setup
    {
    my ($self, $content_fn, $port, $response ) = @_ ;

    $response   //= $self -> response ;
    $port       //= $self -> port ;
    
    $self -> port ( $port ) ;
    $self -> response ( $response ) ;
    $self -> _verbose ( $ENV{MOCK_VERBOSE} || 0 ) ;

    my  ( $socket, $listen_message ) = $self -> build_server_socket() ;

    if ( my $pid = fork() )
        {
        undef $socket ;

        print STDERR "Forked $pid\n" 
            if ($self -> _verbose ) ;

        $self -> mock_pid ( $pid ) ;
        sleep 1 ;
        } 
    else
        {
        $self -> set_responsefile_content($content_fn) ;
        $self -> run( $socket, $listen_message ) ;
        }

    return $self -> port ;
    }

# -----------------------------------------------------------------------------
# shutdown_mock - shutdown mock child
#
# ret   undef - no child
#       child pid

sub shutdown_mock
    {
    my ($self) = @_ ;

    my $pid = $self -> mock_pid ;
    if ( $pid )
        {
        kill 'USR1', $pid ;
        waitpid $pid, 0 ;
        $self -> mock_pid( undef ) ;
        }

    return $pid ;
    }

sub build_server_socket
    {
    my ( $self ) = @_;

    my $port = $self -> port ;

    while ( $port )
        {
        my $socket =  IO::Socket::INET -> new (
                LocalHost => '127.0.0.1',
                LocalPort => $port,
                Proto => 'tcp',
                Listen => 5,
                Timeout => $self -> timeout ,
                Reuse => 1
            ) or print "INFO: failed to listen on 127.0.0.1:$port: $! - try next\n" ;

        return ( $socket, "Listening 127.0.0.1:$port\n") 
            if ( $socket );

        $port ++ ;
        $self -> port ($port) ;
        }
    return ;
    }

sub accept_fail_msg 
    {
    return "Failed to accept on " . shift -> port ;
    }

# - main ----------------------------------------------------------------------

sub run
    {
    my ($self, $s_socket, $listen_message ) = @_ ;
    
    while ( 1 )
        {
        print STDERR $listen_message if ($self -> _verbose ) ;
        my $server_socket = $s_socket->accept() 
            or die $self -> accept_fail_msg ;
    
        if ( $shutdown )
            {
            $server_socket -> close ;
            $s_socket = undef ;
            exit 0 ;
            }

        my $client_address  = $server_socket->peerhost();
        my $client_port     = $server_socket->peerport();
        print STDERR "connection from $client_address:$client_port\n"
            if ($self -> _verbose ) ;

        my $data ;
        my $stat = sysread($server_socket, $data, 1024) ;
        #print STDERR "Client sent: $data\n" ;

        $self -> data_received ($data) ;

        my $response = $self -> get_responsefile_content ;

        # print STDERR "Reply $content\n" ;
        syswrite( $server_socket, $response ) ;
        $server_socket -> close() ;
        }
    
    exit 0 ;
    }

sub DEMOLISH
    {
    shift -> shutdown_mock ;
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1 ;