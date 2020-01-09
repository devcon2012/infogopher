package InfoGopher::InfoSource::MQTT ;

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
use Devel::StealthDebug ENABLE => $ENV{dbg_mqtt} || $ENV{dbg_source} ;
use Data::Dumper ;

use Moose ;
use MooseX::ClassAttribute ;
use Coro ;

use Try::Tiny ;

use InfoGopher::Essentials ;

use AnyEvent::MQTT ;

extends 'InfoGopher::InfoSubscriber' ;
with 'InfoGopher::InfoSource::_InfoSource' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 
class_has '_throwme' => (
    documentation   => 'exception stack',
    is              => 'rw',
    isa             => 'ArrayRef',
    default         => sub { [] } ,
    lazy            => 1,
) ;

class_has 'topic2self' => (
    documentation   => 'mqtt topic subscribed',
    is              => 'rw',
    isa             => 'HashRef',
    default         => sub {{}} ,
    traits          => ['Hash'],
    handles         => {
        set_topic_self      => 'set',
        clear_topic_self    => 'delete',
        get_topic_self      => 'get',
        },
) ;

# 
has 'topic' => (
    documentation   => 'mqtt topic subscribed',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => '' 
) ;
around 'path' => sub 
    {
    my ($orig, $self, $newid) = @_ ;
    shift; shift ;

    #!dump($newid)!
    $self -> topic ( "$newid" ) ;

    return $self->$orig(@_) ;
    };

has 'default_mimetype' => (
    documentation   => 'mimetype infobites return',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    lazy            => 1,
    builder         => '_build_default_mimetype',
) ;
sub _build_default_mimetype
    {
    return 'text/json' ;
    }

has 'listener' => (
    documentation   => 'mqtt topic subscribed',
    is              => 'rw',
    isa             => 'AnyEvent::MQTT',
    lazy            => '1' ,
    builder         => '_build_listener'
) ;
sub _build_listener
    {
    my $self = shift ;

    my $host = $self -> host or ThrowException('MQTT URI missing host') ;
    my $user = $self -> user ;
    my $port = ( $self -> port > 0 ?  $self -> port : 1883 ) ;

    my %par = 
        (
        host        => $host,
        port        => $port,
        timeout     => 10,
        on_error    => sub 
                        {
                        $self -> error_handler ( @_ ) ;
                        }
        ) ;

    #!dump(\%par)!
    return AnyEvent::MQTT -> new( %par ) ;
    }

has 'cond_var' => (
    documentation   => 'AnyEvent Condition var',
    is              => 'rw',
    isa             => 'AnyEvent::CondVar',
) ;

has 'qos' => (
    documentation   => 'MQTT Quality of service',
    is              => 'rw',
    isa             => 'Int',
) ;

has 'subscribed' => (
    documentation   => 'are we subscribed?',
    is              => 'rw',
    isa             => 'Bool',
    lazy            => '1' ,
    default         => 0,
) ;

has 'coro_listener' => (
    documentation   => 'coro',
    is              => 'rw',
    isa             => 'Any',
) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
#
# BUILD - register ourselves as the handler for that topic
#
#

sub BUILD
    {
    my ($self) = @_;
    #!dump(" + $self")!
    $self -> subscribe ;
    return ;
    }

# -----------------------------------------------------------------------------
#
# DEMOLISH - unregister ourselves as the handler for that topic
#
#

sub DEMOLISH
    {
    my ($self) = @_;
    #!dump(" - $self")!

    my $t = $self->topic ;
    my $i = NewIntention ( "Demolish mqtt $t" ) ;

    $self -> unsubscribe if ( $self -> subscribed ) ;
    #$self -> listener(undef);
    return ;
    }


# -----------------------------------------------------------------------------
#
# error_handler: We cannot throw here because the event loop would catch that...
#
#
sub error_handler
    {
    my ($self, $fatal, $message) = @_ ;
    #!dump("$self", $fatal, $message)!

    if ( $fatal )
        {
        my $stack = __PACKAGE__ -> _throwme ;
        push @$stack, NormalizeException($message) ;
        }
    else
        {
        Logger( __PACKAGE__ . ": $message" ) ;
        }
    return ;
    }

# -----------------------------------------------------------------------------
#
# class method subscriber_callback - receive messages
#
# in    $topic
#       $message
#
# throws if topic cannot be mapped to an object
#
sub subscriber_callback
    {
    my ($self, $topic, $message) = @_;
    #!dump("$self", $topic, $message)!

    my $i = NewIntention ( "Received for mqtt $topic" ) ;

    my $newbite = $self -> add_info_bite ( 
            $message, 
            $self -> default_mimetype,
            time ) ;

    return ;
    }

# -----------------------------------------------------------------------------
#
# subscribe - subscribe to a topic on a mqtt server
#
#
sub subscribe
    {
    my ($self) = @_ ;

    my $topic = $self -> topic ;

    my $i = NewIntention ( "Subscribe MQTT: $topic" ) ;

    ThrowException("Missing topic") 
        if ( ! $topic ) ;

    my $cv ;

    try 
        {
        $cv = $self -> listener -> subscribe( 
                                topic => $topic, 
                                callback => sub 
                                    {
                                    $self -> subscriber_callback( @_ ) ;
                                    }
                                    ) ;
        die "subscribe failed" if ( ! $cv ) ;
        my $qos = $cv -> recv ;
        $self -> qos ( $qos ) ;
        $cv = AnyEvent::CondVar -> new ;
        $self -> cond_var( $cv );
        $self -> subscribed ( 1 ) ;
        }
    catch
        {
        ThrowException($_) ;
        } ;

    my $listen_coro = new Coro sub  
        {
        $cv -> recv ;
        Logger ("InfoGopher::InfoSource::MQTT: $topic done.") ;
        } ;

    $listen_coro -> ready ;

    $self -> coro_listener ( $listen_coro ) ;

    cede ;

    return ;
    }

# -----------------------------------------------------------------------------
#
# unsubscribe - "fork" coro to listen for new infobites
#
#
sub unsubscribe
    {
    my ($self) = @_ ;

    my $i = NewIntention ( "Unsubscribe MQTT: " . $self -> uri ) ;

    $self -> subscribed ( 0 ) ;
    $self -> listener -> unsubscribe(topic => $self -> topic );
    my $cv = $self -> cond_var ;
    $cv -> send ;

    my $listen_coro = $self -> coro_listener ;

    cede ; cede ;
    my $ret = $listen_coro -> join ;

    return ;
    }

# -----------------------------------------------------------------------------
#
# fetch - dont do anything
#   
#
sub fetch
    {
    my ( $self ) = @_ ;

    my $stack = __PACKAGE__ -> _throwme ;

    die pop @$stack if ( @$stack ) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=pod

=cut
