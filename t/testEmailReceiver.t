use strict;
use warnings;

use Test::More tests => 3;

use Try::Tiny ;
use Data::Dumper ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# testEmailReceiver - test MQTT from Mock server
#  * create a mqtt infosubscriber
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BEGIN { $ENV{DEBUG_INFOGOPHER} = 1} ;
BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::InfoSink::EmailReceiver') };

our ( $mock, $port ) ; 

# setup mock MQTT server - TODO

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $intention = NewIntention ( 'test EmailReceiver' ) ;

exit 0 ;

