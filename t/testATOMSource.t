use strict;
use warnings;

use Test::More tests => 39;

use TinyMock::HTTP ;
use Try::Tiny ;
use Data::Dumper ;
use JSON::MaybeXS ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# testATOMSource - test ATOM from Mock server
#  * create a ATOM infosource
#  * fetch mock atom, test mime type, etc.
#  * create ATOM2JSON Transform
#  * fetch again, test transformed results
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::InfoSource::ATOM') };
BEGIN { use_ok('InfoGopher::InfoTransform::ATOM2JSON') };

our $mock ;
our $port ; 

# setup mock http server
BEGIN 
    {
    $mock = TinyMock::HTTP -> new ( ) ; # _verbose => 1 
    $mock -> setup('ATOM', 7080) ; 
    } ;

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

use constant ATOMName => 'ATOMTest' . time  ;
use constant ATOMId => int(rand(100)) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $intention = NewIntention ( 'testATOMSource' ) ;

$port = $mock -> port ;

note ("Mock port " . $port ) ;

my $gopher = InfoGopher -> new ;
my $ATOM = InfoGopher::InfoSource::ATOM -> new ( 
        uri      => "http://127.0.0.1:" . $port,
        name     => ATOMName,
        id       => ATOMId) ;

ok ( ATOMName eq $ATOM -> name , 'Name ok' ) ;
ok ( ATOMId   eq $ATOM -> id , 'ID ok' ) ;
ok ( "http://127.0.0.1:$port/" eq $ATOM -> uri , 'URI ok' ) ;

try
    {
    $ATOM -> fetch() ;
    ok(1, "fetch ATOM ok.")
    }
catch
    {
    my $e = NormalizeException( $_ );
    note ( Dumper($e) ) ;
    fail ( $e -> what ) ;
    } ;

my $ibites = $ATOM -> info_bites ;

note ( "iBites:" . $ibites -> count) ;
ok ( 1 == $ibites -> count, "got exactly one ibite" ) ;

    {
    my $ibite = $ibites -> get(0) ;
    ok ( 'application/atom+xml' eq $ibite ->mime_type , "mime type ok" ) ;
    }

ok ( ATOMName eq $ibites -> source_name, "name matches" ) ;
ok ( ATOMId == $ibites -> source_id, "id matches" ) ;

my $t = InfoGopher::InfoTransform::ATOM2JSON -> new () ;
$ATOM -> transformation ( $t ) ;

try
    {
    $ATOM -> fetch() ;
    ok(1, "fetch ATOM ok again.");
    }
catch
    {
    my $e = NormalizeException( $_ );
    note ( Dumper($e) ) ;
    fail ( $e -> what ) ;
    } ;

$ibites = $ATOM -> info_bites ;
note ( "iBites:" . $ibites -> count) ;
ok ( 3 == $ibites -> count, "got exactly three ibite" ) ;

    {
    my $ibite = $ibites -> get(0) ;
    ok ( 'application/json' eq $ibite -> mime_type , "mime type ok" ) ;
    my $n = 1;
    foreach $ibite ( $ibites -> all )
        { 
        my $json = $ibite -> data ;
        my $tree =  JSON -> new -> decode($ibite -> data) ;
        # note ( Dumper ($tree) ) ;
        my $title = $tree -> {title} ;
        ok ( "Titel des Weblog-Eintrags $n" eq $title , "title ok" ) ;
        my $content = $tree -> {content} ;
        ok ( "Volltext des Weblog-Eintrags $n" eq $content , "content ok" ) ;
        my $summary = $tree -> {summary} ;
        ok ( "Zusammenfassung des Weblog-Eintrags $n" eq $summary , "summary ok" ) ;
        my $id = $tree -> {id} ;
        ok ( "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6$n" eq $id , "id ok" ) ;
        my $updated = $tree -> {updated} ;
        ok ( "2003-12-13T18:30:0${n}Z" eq $updated , "updated ok" ) ;

        $n++ ;
        }
    }

$t -> set_option('split', 0) ;

try
    {
    $ATOM -> fetch() ;
    ok(1, "fetch ATOM ok yet again.");
    }
catch
    {
    my $e = NormalizeException( $_ );
    note ( Dumper($e) ) ;
    fail ( $e -> what ) ;
    } ;

$ibites = $ATOM -> info_bites ;
note ( "iBites:" . $ibites -> count) ;
ok ( 1 == $ibites -> count, "got exactly one ibite" ) ;

    {
    my $ibite = $ibites -> get(0) ;
    ok ( 'application/json' eq $ibite -> mime_type , "mime type ok" ) ;
    my $json = $ibite -> data ;
    my $tree =  JSON -> new -> decode($ibite -> data ) ;
    ok ( $tree -> {id} eq 'urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6' , 'ID ok ') ;
    ok ( $tree -> {title} eq 'Titel des Weblogs' , 'title ok ') ;
    ok ( $tree -> {updated} eq '2003-12-14T10:20:09Z' , 'updated ok ') ;
    ok ( $tree -> {author_info}{name} eq 'Autor des Weblogs' , 'author name ok ') ;
    ok ( 3 == scalar @{$tree -> {entries}}, 'three entries' ) ;
    }


ok (1, "End reached") ;

exit 0 ;

END 
    { 
    $mock -> shutdown_mock() ; 
    } ;

