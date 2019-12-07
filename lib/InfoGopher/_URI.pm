package InfoGopher::_URI ;

#
#
#

use strict ;
use warnings ;

use Moose::Role ; 
 
# 
has 'uri' => (
    documentation   => 'Information source, eg. http://xxx.. or ...',
    is              => 'rw',
    isa             => 'Str',
    default         => ''
) ;

# 
has 'host' => (
    documentation   => 'host name extracted from uri',
    is              => 'rw',
    isa             => 'Str',
    default         => 'localhost'
) ;

# 
has 'user' => (
    documentation   => 'user name, possibly for authentication',
    is              => 'rw',
    isa             => 'Str',
    default         => ''
) ;

has 'port' => (
    documentation   => 'port number extracted from uri',
    is              => 'rw',
    isa             => 'Int',
    default         => '-1'
) ;

has 'path' => (
    documentation   => 'ppath extracted from uri',
    is              => 'rw',
    isa             => 'Str',
    default         => ''
) ;

has 'proto' => (
    documentation   => 'protocol (http, https, imap, ...)',
    is              => 'rw',
    isa             => 'Str',
    default         => 'http'
) ;

# set name to hostname of URI, if not yet set.
around 'uri' => sub 
    {
    my $orig = shift ;
    my $self = shift ;
 
    if ( @_ )
        {
        my $newuri = shift ;
        # imap://user@host:port/
        # user:pw@host syntax not supported for good reason!
        if ( $newuri =~ /([^:]+):\/\/(([^\@]+)\@){0,1}([^:\/]+):{0,1}([^\/]*)\/(.*)/  )
            {    
            my ($proto, $user, $host, $port, $path) = ($1, $3, $4, $5, $6) ;
            $self -> proto ( $proto ) if ($proto) ;
            $self -> user  ( $user  ) if ($user) ;
            $self -> host  ( $host  ) if ($host) ;
            $self -> port  ( $port  ) if ($port) ;
            $self -> path  ( $path  ) if ($path) ;
            }
        return $self -> $orig( $newuri );
        }
    else
        {
        return $self -> $orig();
        }
    } ;

1;
