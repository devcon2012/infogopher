
use strict;
use warnings;

use Test::More tests => 16 ;

use TinyMock::HTTP ;
use Try::Tiny ;
use Data::Dumper ;

BEGIN 
    { 
    use_ok('InfoGopher') ;
    use_ok('InfoGopher::Essentials') ;
    use_ok('InfoGopher::InfoSource::Web') ;
    use_ok('InfoGopher::Factory') ; 
    }

our ($mock, $port) ; 

BEGIN 
    {
    $mock = TinyMock::HTTP -> new ( ) ; # _verbose => 1 
    $mock -> setup('HTML2', 7080) ; 

    open( my $loghandle, ">>", "testInfoGopher.log" ) 
         or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    } ;

# make test TEST_VERBOSE=1 TEST_FILES='t/testSources/XXX.t'
# make testdb TEST_FILE=t/testSources/XXX.t
#########################

use constant SourceName => 'WebSourceTest' ;
use constant SourceId => 7 ;

$port = $mock -> port ;
note ("Mock port " . $port ) ;

my $web = InfoGopher::InfoSource::Web -> new ( 
        uri      => "http://127.0.0.1:$port/HTML",
        name     => SourceName,
        id       => SourceId) ;

ok ( SourceName eq $web -> name , 'Name ok' ) ;
ok ( SourceId   eq $web -> id , 'ID ok' ) ;
ok ( "http://127.0.0.1:$port/HTML" eq $web -> uri , 'URI ok' ) ;



try
    {
    $web -> fetch() ;
    ok(1, "fetch web ok.")
    }
catch
    {
    my $e = NormalizeException($_) ;
    note ( Dumper($_) ) ;
    fail ( $e -> what ) ;
    };

my $ibites = $web -> info_bites ;

    {
    my $ibite = $ibites -> get(0) ;
    ok ($ibite -> is_mime_type( 'text/html' ) , "mime type ok" ) ;
    ok ($ibite -> is_encoding( 'utf-8' ) , "encoding ok" ) ;
    }

my $json = <<"END_JSON";
{
    "logfile" : "testInfoGopher.log",
    "infogopher" :
        {
        "name" : "infoBoard"
        },
    "sources" :
        [
            {
            "name" : "mock Web",
            "module" : "InfoGopher::InfoSource::Web",
            "uri" : "http://127.0.0.1:$port/",
            "update_interval" : 60,
            "transform":
                {
                "name" : "HTML",
                "module" : "InfoGopher::InfoTransform::HTMLExtractor",
                "wanted_tags" : { "h1" : 1 }
                }
            }
        ]
}
END_JSON

my $gopher ;

try
    {
    $gopher = InfoGopher::Factory -> produce ( $json ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    }
catch 
    {
    my $e = NormalizeException( $_ );
    note ( Dumper($e) ) ;
    fail ( $e -> what ) ;
    } ;

isa_ok ( $gopher, 'InfoGopher', 'Is it a gopher?' ) ;

$gopher -> collect ;

my $all_infobites = $gopher -> get_all ;
isa_ok ( $all_infobites, 'ARRAY', 'Is result an ARRAY?' ) ;
ok ( 1 == scalar @$all_infobites, 'one entry?') ;
my $infobites = $all_infobites->[0] ;
isa_ok ( $infobites, 'InfoGopher::InfoBites', 'Is it an InfoBites?' ) ;
note(Dumper($infobites)) ;
my $infobite = $infobites->get(0) ;
isa_ok ( $infobite, 'InfoGopher::InfoBite', 'Is it an InfoBite?' ) ;

ok (1, "End reached") ;

exit 0 ;

END 
    { 
    $mock -> shutdown_mock() ; 
    } ;

