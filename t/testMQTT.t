use strict;
use warnings;

use Test::More tests => 8 ;

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
BEGIN { use_ok('InfoGopher::InfoSource::MQTT') };

our ( $mock, $port ) = (undef, 0); 
our ( $MQTTName, $MQTTId) = ( 'MQTTTest' . time, int(rand(100)) ) ;
# setup mock MQTT server - TODO

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    #InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $intention = NewIntention ( 'testMQTTSource' ) ;

my $gopher = InfoGopher -> new ;
my $mqtt = InfoGopher::InfoSource::MQTT -> new ( 
        uri      => "mqtt://127.0.0.1:$port",
        name     => $MQTTName,
        id       => $MQTTId) ;

ok ( $MQTTName eq $mqtt -> name , 'Name ok' ) ;
ok ( $MQTTId   eq $mqtt -> id , 'ID ok' ) ;
ok ( "mqtt://127.0.0.1:$port/" eq $mqtt -> uri , 'URI ok' ) ;

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

my $ibites = $mqtt -> info_bites ;

note ( "iBites:" . $ibites -> count ) ;
#ok ( 1 == $ibites -> count, "got exactly one ibite" ) ;

ok (1, "End reached") ;

exit 0 ;

END 
    { 
    $mock -> shutdown_mock() if ( $mock ) ; 
    } ;

