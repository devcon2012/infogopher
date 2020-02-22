
use strict;
use warnings;

use Test::More tests => 8;

use TinyMock::HTTP ;
use Try::Tiny ;

BEGIN { use_ok('InfoGopher') } ;
BEGIN { use_ok('InfoGopher::InfoSource::RSS') } ;
BEGIN { use_ok('InfoGopher::InfoRenderer::TextRenderer') } ;
BEGIN { use_ok('InfoGopher::Essentials') } ;

our $mock ;

BEGIN 
    { 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('four_o_four', 7081) ; 
    } ;

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

# make test TEST_VERBOSE=1 TEST_FILES='t/InfoGopher.t'
# make testdb TEST_FILE=t/InfoGopher.t
#########################

my $gopher = InfoGopher -> new ;
my $rss = InfoGopher::InfoSource::RSS -> new ( 
            name => 'RSS', 
            uri => "http://127.0.0.1:7081") ;

$gopher -> add_info_source($rss) ;
isa_ok( $gopher -> find_source_byname('RSS'), 'InfoGopher::InfoSource::RSS', "Found source by name" ) ;

try
    {
    $gopher -> collect() ;
    }
catch
    {
    note ( $_ -> what ) ;
    ok (1, 'Failed due to 404') ;
    };

InfoGopher::IntentionStack -> reset_intention_stack ;

$mock -> set_responsefile_content('RSS') ;     

try
    {
    $gopher -> collect() ;
    ok ( 1, 'gopher collected' ) ;
    }
catch
    {
    diag ($_) ;
    fail ( "gopher choked" ) ;
    } ;

my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;
isa_ok ($renderer, 'InfoGopher::InfoRenderer::TextRenderer' , 'got a renderer' ) ;

my @result = $gopher -> get_all( $renderer ) ;
ok ( 1 == scalar @result, "exactly one result" ) ;

note ( $result[0] ) ;

exit 0 ;

END 
    { 
    $mock -> shutdown_mock() ; 
    } ;

