
use strict;
use warnings;

use Test::More tests => 6;

use TinyMock::HTTP ;
use Try::Tiny ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::InfoSource::RSS') };
BEGIN { use_ok('InfoGopher::InfoRenderer::TextRenderer') };

our $mock ;

BEGIN 
    { 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('four_o_four', 7081) ; 

    open( my $loghandle, ">", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger -> handle ( $loghandle ) ;

    } ;

# make testdb TEST_FILE=t/InfoGopher.t
#########################

my $gopher = InfoGopher -> new ;
my $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7081") ;

$gopher -> add_info_source($rss) ;
try
    {
    $gopher -> collect() ;
    }
catch
    {
    note ( $_ -> what ) ;
    ok ('Failed due to 404', 'Failed due to 404') ;
    };

InfoGopher::IntentionStack -> reset ;

$mock -> set_responsefile_content('RSS') ;     

try
    {
    $gopher -> collect() ;
    ok ( 'gopher collected', 'gopher collected' ) ;
    }
catch
    {
    fail ( "gopher choked" ) ;
    } ;

my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;
ok ('got a renderer', 'got a renderer' ) ;

my @result = $gopher -> render( $renderer ) ;
ok ( 1 == scalar @result, "exactly one result" ) ;

note ( $result[0] ) ;

exit 0 ;

END 
    { 
    $mock -> shutdown() ; 
    } ;

