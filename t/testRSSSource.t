use strict;
use warnings;

use Test::More tests => 16;

use TinyMock::HTTP ;
use Try::Tiny ;
use Data::Dumper ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# testRSSSource - test RSS from Mock server
#  * create a rss infosource
#  * fetch mock rss, test mime type, etc.
#  * create RSS2JSON Transform
#  * fetch again, test transformed results
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::InfoSource::RSS') };

our $mock ;
our $port ; 

# setup mock http server
BEGIN 
    {
    $mock = TinyMock::HTTP -> new ( ) ; # _verbose => 1 
    $mock -> setup('RSS', 7080) ; 

    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    } ;

#
# make test TEST_VERBOSE=1 TEST_FILES='t/testRSSSource.t'
# make testdb TEST_FILE=t/testRSSSource.t

use constant RSSName => 'RSSTest' . time ;
use constant RSSId => int(rand(100)) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $intention = NewIntention ( 'testRSSSource' ) ;

$port = $mock -> port ;

note ("Mock port " . $port ) ;

my $gopher = InfoGopher -> new ;
my $rss = InfoGopher::InfoSource::RSS -> new ( 
        uri      => "http://127.0.0.1:" . $port,
        name     => RSSName,
        id       => RSSId) ;

ok ( RSSName eq $rss -> name , 'Name ok' ) ;
ok ( RSSId   eq $rss -> id , 'ID ok' ) ;
ok ( "http://127.0.0.1:$port" eq $rss -> uri , 'URI ok' ) ;

try
    {
    $rss -> fetch() ;
    ok(1, "fetch RSS ok.")
    }
catch
    {
    my $e = NormalizeException( $_ );
    note ( Dumper($e) ) ;
    fail ( $e -> what ) ;
    } ;

my $ibites = $rss -> info_bites ;

note ( "iBites:" . $ibites -> count) ;
ok ( 1 == $ibites -> count, "got exactly one ibite" ) ;

    {
    my $ibite = $ibites -> get(0) ;
    ok ( 'application/rss+xml' eq $ibite ->mime_type , "mime type ok" ) ;
    }

ok ( 1 == $ibites -> count, "got exactly one ibite" ) ;
ok ( RSSName eq $ibites -> source_name, "name matches" ) ;
ok ( RSSId == $ibites -> source_id, "id matches" ) ;

my $t = InfoGopher::InfoTransform::RSS2JSON -> new () ;
$rss -> transformation ( $t ) ;

try
    {
    $rss -> fetch() ;
    ok(1, "fetch RSS ok again.");
    }
catch
    {
    my $e = NormalizeException( $_ );
    note ( Dumper($e) ) ;
    fail ( $e -> what ) ;
    } ;

$ibites = $rss -> info_bites ;
note ( "iBites:" . $ibites -> count) ;
ok ( 3 == $ibites -> count, "got exactly three ibites" ) ;

    {
    my $ibite = $ibites -> get(0) ;
    ok ( 'application/json' eq $ibite -> mime_type , "mime type ok" ) ;
    }

ok (1, "End reached") ;

exit 0 ;

END 
    { 
    $mock -> shutdown_mock() ; 
    } ;

