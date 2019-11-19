
use strict;
use warnings;

use Test::More tests => 3;

use Try::Tiny ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::InfoBites') };

BEGIN 
    { 
    open( my $loghandle, ">", "testInfoBites.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    } ;

# make test TEST_VERBOSE=1 TEST_FILES='t/testInfoBites.t'
# make testdb TEST_FILE=t/testInfoBites.t
#########################

my $bites = InfoGopher::InfoBites -> new ( ) ;

ok ( 'InfoBites created' ) ;

exit 0 ;

