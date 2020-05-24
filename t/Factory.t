#
# test factory: creating an InfoGopher from JSON cfg
#

use strict;
use warnings;

use Test::More tests => 9 ;

use TinyMock::HTTP ;
use Try::Tiny ;

use Data::Dumper ;

# make test TEST_VERBOSE=1 TEST_FILES='t/Factory.t'

BEGIN 
    {
    use_ok('InfoGopher::Essentials'); 
    use_ok('InfoGopher::Logger'); 
    use_ok('InfoGopher::Factory'); 
    } ;

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;


my $json = <<'END_JSON';
{
    "logfile" : "testInfoGopher.log",
    "infogopher" :
        {
        "name" : "infoBoard"
        },
    "infogradient" :
        {
        "name" : "infoGradient"
        },
    "sources" :
        [
            {
            "name" : "mock news rss feed",
            "module" : "InfoGopher::InfoSource::RSS",
            "uri" : "https://mocknews.org/rss_feed",
            "update_interval" : 60
            }
        ],
    "sinks" :
        [
            {
            "name" : "FileReceiver",
            "module" : "InfoGopher::InfoSink::FileReceiver",
            "update_interval" : 60
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
#diag ( Dumper($gopher) ) ;

isa_ok ( $gopher, 'InfoGopher', 'Is it a gopher?' ) ;

ok ( $gopher -> name eq 'infoBoard', 'gopher name ok' ) ;
ok ( 1 == $gopher -> count_info_sources, "got exactly one info source" ) ;
my $source = $gopher -> get_info_source(0) ;
isa_ok ( $source, 'InfoGopher::InfoSource::RSS', 'Is it an RSS InfoSource?' ) ;

ok ( 1 == $gopher -> count_info_sinks, "got exactly one info sink" ) ;

my $sink = $gopher -> get_info_sink(0) ;
isa_ok ( $sink, 'InfoGopher::InfoSink::FileReceiver', 'Is it an FileReceiver InfoSink?' ) ;
