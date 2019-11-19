
use strict;
use warnings;

use Test::More tests => 10;

use TinyMock::HTTP ;
use Try::Tiny ;
use Data::Dumper ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::InfoSource::RSS') };

our $mock ;
our $port ; # firt port tried

BEGIN 
    {
    $mock = TinyMock::HTTP -> new ( ) ; # _verbose => 1 
    $mock -> setup('RSS', 7080) ; 

    open( my $loghandle, ">", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    } ;

# make test TEST_VERBOSE=1 TEST_FILES='t/testSources/RSS.t'
# make testdb TEST_FILE=t/testSources/RSS.t
#########################

use constant RSSName => 'RSSTest' ;
use constant RSSId => 7 ;

note ("Mock port " . $mock -> port ) ;

my $gopher = InfoGopher -> new ;
my $rss = InfoGopher::InfoSource::RSS -> new ( 
        uri      => "http://127.0.0.1:" . $mock -> port,
        name     => RSSName,
        id       => RSSId) ;

ok ( RSSName eq $rss -> name , 'Name ok' ) ;
ok ( RSSId   eq $rss -> id , 'ID ok' ) ;
ok ( "http://127.0.0.1:" . $mock -> port eq $rss -> uri , 'URI ok' ) ;

try
    {
    $rss -> fetch() ;
    ok(1, "fetch RSS ok.")
    }
catch
    {
    note (Dumper($_)) ;
    fail ( $_ -> what ) ;
    };

my $ibites = $rss -> info_bites ;

note ( "iBites:" . $ibites -> count) ;
ok ( 3 == $ibites -> count, "got exactly one ibite" ) ;
ok ( 'RSSTest' eq $ibites -> source_name, "name matches" ) ;
ok ( 7 == $ibites -> source_id, "id matches" ) ;

ok (1, "End reached") ;

exit 0 ;

END 
    { 
    $mock -> shutdown() ; 
    } ;

