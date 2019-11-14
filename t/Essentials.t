#  test exceptions:
#
# Note: Dont die - that corrupts the intention stack ...
#
use strict;
use warnings;

use Test::More tests => 3;

use Try::Tiny ;

BEGIN { use_ok('InfoGopher::Essentials') };

BEGIN {
    open( my $loghandle, ">", "testEssentials.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger -> handle ( $loghandle ) ;
    }

try 
    {
    ThrowException("XX") ;
    }
catch
    {
    my $e = $_ ;
    note( ref $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e ) ;
    ok ( 'XX' eq $e -> what ) ;
    };



