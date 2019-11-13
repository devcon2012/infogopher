use strict;
use warnings;

use Test::More tests => 6;

use Try::Tiny ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Logger') };

# make testdb TEST_FILE=t/Logger.t
#########################

my $line = "test log entry" ;

    {
    open( my $loghandle, ">", "testlogger.log" ) 
        or fail( "cannot open test.log: $!" ) ;

    InfoGopher::Logger -> handle ( $loghandle ) ;
    ok ( "log set", "log set" ) ;

    InfoGopher::Logger -> log ( "test log entry " ) ;
    ok ( "logentry written", "logentry written" ) ;

    InfoGopher::Logger -> handle ( undef ) ;
    close ( $loghandle) ;

    ok ( "log closed", "log closed" ) ;
    }

    {
    open( my $loghandle, "<", "testlogger.log" ) 
        or die "no test.log readable: $!" ;
    my $logged = <$loghandle> ;

    ok ( $logged =~ /test log entry/, 'log entry matches' ) ;

    close ( $loghandle ) ;

    }

exit 0 ;