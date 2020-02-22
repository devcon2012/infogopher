#
#  test Essentials: Logging, Throwing, ...
#
#
use strict ;
use warnings ;

use Test::More tests => 11 ;

use Try::Tiny ;
use Data::Dumper ;

# make test TEST_VERBOSE=1 TEST_FILES='t/Essentials.t'

BEGIN { use_ok('InfoGopher::Essentials') } ;

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

my $i = NewIntention("Test Intentions") ;
isa_ok( $i, 'InfoGopher::Intention', 'Good intention' ) ;

try 
    {
    ThrowException() ;
    fail( "Throw did not throw!" ) ;
    }
catch
    {
    my $e = $_ ;
    # print STDERR Dumper ( $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e , 'Exception has proper type') ;
    like ( $e -> what, qr/stacktrace/i, 'Exception has proper what' ) ;
    };

try 
    {
    ThrowException("XX") ;
    fail( "Throw did not throw!" ) ;
    }
catch
    {
    my $e = $_ ;
    # print STDERR Dumper ( $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e , 'Exception has proper type') ;
    ok ( 'XX' eq $e -> what , 'Exception has proper what' ) ;
    };

    {
    # Exception Normalization
    eval 
        {
        die('Killed by death') ;
        } ;
    if ( $@ )
        {
        my $e = NormalizeException( $@ ) ;
        isa_ok ( $e, 'InfoGopher::Exception' , 'Exception has proper type') ;
        like ( $e -> what, qr/^Killed by death/, 'Exception has proper what' ) ;
        }
    }

try 
    {
    # proper handling of calls that might die:
    eval 
        {
        die("Killed by death") ;
        } ;
    if ( $@ )
        {
        # ThrowException will normalize $@
        ThrowException( $@ ) ;
        }
    }
catch
    {
    my $e = $_ ;
    # print STDERR Dumper ( $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e , 'Exception has proper type') ;
    like ( $e -> what, qr/^Killed by death/, 'Exception has proper what' ) ;
    };

    {
    # Test ASleep
    my $start = time ;
    ASleep(2.1) ;
    my $end = time ;
    ok ( ( 2 == $end - $start) || ( 3 == $end - $start) , 'asleep ok') ;
    }

