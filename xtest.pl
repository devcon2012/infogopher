#!/usr/bin/perl
#
# demonstrate basic infogopher usage and concepts
# 

use strict ;
use warnings ;

use FindBin;
use lib "$FindBin::Bin/blib/lib";

use Try::Tiny ;
use Data::Dumper ;

use InfoGopher ;
use InfoGopher::Essentials ;
use InfoGopher::InfoSubscriber::MQTT ;

use TinyMock::HTTP ;

our ($mock, $port) ;

BEGIN 
    { 
    # $mock = TinyMock::HTTP -> new ();
    # $mock -> setup('HTML', 7080) ;
    } ;

BEGIN 
    {
    # this would redirect log from sterr to a file
    # open( my $loghandle, ">", "demoGopher.log" ) 
    #    or die "cannot open log: $!" ;
    # InfoGopher::Logger -> handle ( $loghandle ) ;
    } ;



# -----------------------------------------------------------------------------
#
# error_handler
#
#
sub error_handler
    {
    my ($fatal, $message) = @_ ;
    #!dump($fatal, $message)!
    ThrowException($message) ;
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
    my ($topic, $message) = @_;
    #!dump($topic, $message)!

    print STDERR "$topic: $message\n" ;
    return ;
    }


if ( 0 )
    {
    my $host = "localhost" ;
    my $port = 1883  ;

    my %par = 
        (
        host        => $host,
        port        => $port,
        timeout     => 10,
        on_error    => \&mqtt_error_handler,
        ) ;

    #!dump(\%par)!
    my $mqtt = AnyEvent::MQTT -> new( %par ) ;

    my $cv = $mqtt-> subscribe( 
                        topic => "bla", 
                        callback => \&subscriber_callback
                            ) ;
    die "subscribe failed" if ( ! $cv ) ;
    my $qos = $cv -> recv ;
    print STDERR "QoS: $qos\n" ;

    while ( 1 )
        {
        my $quit = AnyEvent::CondVar -> new ;
        $quit -> recv ;
        }

    }

my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;

    {

    my ( $gopher, $src, $t ) ;

    try 
        {
        $src = InfoGopher::InfoSubscriber::MQTT -> new( uri => "mqtt://127.0.0.1/bla/fasel" ) ;
        }
    catch
        {
        my $e = NormalizeException($_) ;
        UnwindIntentionStack($e -> what) ;

        exit 1 ;
        } ;

    try 
        {
        while ( 1 )
            {
            ASleep ( 1 ) ;
            $src -> fetch ;
            $src -> dump_info_bites( "initial" ) ;
            my $bites = $src -> info_bites ;
            last if ( $bites -> count > 2 ) ;
            system("mosquitto_pub -t bla/fasel/ -m 'haha' ") 
                if ( 10 > int ( rand (300) ) ) ;
            }
        }
    catch
        {
        my $e = NormalizeException( $_ ) ;
        UnwindIntentionStack ( $e -> what ) ;
        exit 1 ;
        } ;
    
    try
        {
        my $i = NewIntention ( 'Cleanup InfoGopher' ) ;
        #$src -> unsubscribe ;
        undef $src ;
        }
    catch
        {
        my $e = NormalizeException( $_ ) ;
        UnwindIntentionStack ( $e -> what ) ;
        exit 1 ;
        } ;

    }

exit 0 ;

__END__ 

my $t = InfoGopher::InfoTransform::HTMLExtractor -> new ;

# filter tags/classes
$t -> wanted_tags  ( {'div' => 1} ) ;
$t -> wanted_ids ( {'ticker-content' => 1} ) ;

# what to do?
$t -> tag2ibite->style('text') ;
#$t -> tag2ibite->style('href,resolve') ;

try
    {
    $web -> info_bites -> transform ( $t ) ;
    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;
    } ;

$web -> dump_info_bites("transformed") ;


__END__
try
    {
    my $i = NewIntention ( 'Construct an InfoGopher' ) ;

    $gopher = InfoGopher -> new ;
    $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7080") ;
    $rss -> name ('Politik') ;
    $gopher -> add_info_source($rss) ;

    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;
    exit 1 ;
    };

try
    {
        {
        my $i = NewIntention( 'collect info bits' ) ;
        $gopher -> collect() ;
        }

    $gopher -> dump_text() ;

    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;

    exit 1 ;
    };

undef $i ;

Logger ( "Thats it!" ) ;


END 
    { 
    $mock -> shutdown_mock() ; 
    } ;
