
use strict;
use warnings;

use Test::More tests => 7;

use TinyMock::HTTP ;
use Try::Tiny ;
use Data::Dumper ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::InfoSource::Web') };

our ($mock, $port) ; 

BEGIN 
    {
    $mock = TinyMock::HTTP -> new ( ) ; # _verbose => 1 
    $mock -> setup('HTML', 7080) ; 

    open( my $loghandle, ">", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    } ;

# make test TEST_VERBOSE=1 TEST_FILES='t/testSources/RSS.t'
# make testdb TEST_FILE=t/testSources/RSS.t
#########################

use constant SourceName => 'WebSourceTest' ;
use constant SourceId => 7 ;

$port = $mock -> port ;
note ("Mock port " . $port ) ;

my $gopher = InfoGopher -> new ;
my $web = InfoGopher::InfoSource::Web -> new ( 
        uri      => "http://127.0.0.1:$port",
        name     => SourceName,
        id       => SourceId) ;

ok ( SourceName eq $web -> name , 'Name ok' ) ;
ok ( SourceId   eq $web -> id , 'ID ok' ) ;
ok ( "http://127.0.0.1:$port/" eq $web -> uri , 'URI ok' . $web -> uri ) ;

try
    {
    $web -> fetch() ;
    ok(1, "fetch web ok.")
    }
catch
    {
    note (Dumper($_)) ;
    fail ( $_ -> what ) ;
    };

my $ibites = $web -> info_bites ;

ok (1, "End reached") ;

exit 0 ;

END 
    { 
    $mock -> shutdown() ; 
    } ;

