use strict;
use warnings;

use Test::More tests => 7;

use Try::Tiny ;

BEGIN { use_ok('InfoGopher::Logger') };
BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { unlink "testlogger.log" ; } ;

# make testdb TEST_FILE=t/Logger.t
#########################

my $line = "test log entry" ;

note ("test log creation") ;

    {
    open( my $loghandle, ">", "testlogger.log" ) 
        or fail( "cannot open test.log: $!" ) ;

    InfoGopher::Logger -> handle ( $loghandle ) ;
    ok ( 1, "log set" ) ;

    Logger ( "test log entry " ) ;
    ok ( 1, "logentry written" ) ;

    InfoGopher::Logger -> handle ( undef ) ;
    close ( $loghandle) ;
    ok ( 1, "log closed" ) ;

    ok ( -r "testlogger.log" , "log created ")
    }

note ("test log content") ;
    {
    open( my $loghandle, "<", "testlogger.log" ) 
        or die "no test.log readable: $!" ;
    my $logged = <$loghandle> ;

    ok ( $logged =~ /test log entry/, 'log entry matches' ) ;

    close ( $loghandle ) ;

    }

END { unlink "testlogger.log" ; } ;

exit 0 ;