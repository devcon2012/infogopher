#  test essentails: Logging, Throwing, ...
#
# Note: Throw, dont die - that corrupts the intention stack ...
#
use strict ;
use warnings ;

use Test::More tests => 5 ;

use Try::Tiny ;

BEGIN { use_ok('InfoGopher::Essentials') } ;

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

try 
    {
    ThrowException("XX") ;
    }
catch
    {
    my $e = $_ ;
    note( ref $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e , 'Exception has proper type') ;
    ok ( 'XX' eq $e -> what , 'Exception has proper what' ) ;
    };

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
    note( ref $e ) ;
    note( $e->what ) ;
    ok ( 'InfoGopher::Exception' eq ref $e , 'Exception has proper type') ;
    like ( $e -> what, qr/^Killed by death/, 'Exception has proper what' ) ;
    };



