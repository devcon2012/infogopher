#  test exceptions:
#
# Note: Dont die - that corrupts the intention stack ...
#
use strict;
use warnings;

use Test::More tests => 3;

use Try::Tiny ;
use InfoGopher::Logger;

BEGIN { use_ok('InfoGopherException') };

BEGIN {
    open( my $loghandle, ">", "testInfoGopherException.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger -> handle ( $loghandle ) ;
    }

try 
    {
    InfoGopherException::ThrowInfoGopherException("XX") ;
    }
catch
    {
    my $e = $_ ;
    note( ref $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e ) ;
    ok ( 'XX' eq $e -> what ) ;
    };

#########################



