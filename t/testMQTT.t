use strict;
use warnings;

use Test::More tests => 10 ;

#use TinyMock::MQTT ;
use Try::Tiny ;
use Data::Dumper ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# testMQTTSource - test MQTT from Mock server
#  * create a mqtt infosubscriber
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::InfoSubscriber::MQTT') };

our ( $mock, $port ) = (undef, 1883); 
our ( $MQTTName, $MQTTId) = ( 'MQTTTest' . time, int(rand(100)) ) ;
# setup mock MQTT server - TODO

# setup logging
BEGIN 
    {
    require InfoGopher::Logger;

    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
alarm 5 ;

my $intention = NewIntention ( 'testMQTTSource' ) ;

SKIP: {
    eval 
        { 
        # check if mqtt listening on 1883
        open ( my $fh, "-|", "netstat -pnlt 2>&1") 
            or die "cannot netstat: $!" ;
        my @lines = <$fh> ;
        close ($fh) ;
        my $listener = grep (/[0-9]\:$port\s+/, @lines) ;
        die ( "no mqtt listener on port $port" ) if ( ! $listener ) ;
        } ;
 
    skip "MQTT: $@", 7 if $@;

    my $gopher = InfoGopher -> new ;
    my $mqtt = InfoGopher::InfoSubscriber::MQTT -> new ( 
            uri      => "mqtt://127.0.0.1:$port/topic",
            name     => $MQTTName,
            id       => $MQTTId) ;

    #print STDERR Dumper ( $mqtt ) ;

    ok ( $MQTTName eq $mqtt -> name , 'Name ok' ) ;
    ok ( $MQTTId   eq $mqtt -> id , 'ID ok' ) ;
    ok ( "mqtt://127.0.0.1:$port/topic/" eq $mqtt -> uri , 'URI ok' ) ;

    try
        {
        $mqtt -> fetch() ;
        ok(1, "fetch MQTT ok.") ;
        }
    catch
        {
        my $e = NormalizeException( $_ );
        note ( Dumper($e) ) ;
        fail ( $e -> what ) ;
        } ;

    try
        {
        system( "mosquitto_pub -t topic/ -m 'blafasel' ") ;
        ASleep(1) ;
        $mqtt -> fetch() ;
        ok(1, "fetch MQTT ok.") ;
        }
    catch
        {
        my $e = NormalizeException( $_ );
        note ( Dumper($e) ) ;
        fail ( $e -> what ) ;
        } ;

    my $ibites = $mqtt -> info_bites ;

    note ( "iBites:" . $ibites -> count ) ;
    ok ( 1 == $ibites -> count, "got exactly one ibite" ) ;

    ok (1, "End reached") ;

    }

END 
    { 
    $mock -> shutdown_mock() if ( $mock ) ; 
    } ;

