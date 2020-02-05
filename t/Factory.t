
use strict;
use warnings;

use Test::More tests => 6 ;

use TinyMock::HTTP ;
use Try::Tiny ;

use Data::Dumper ;

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

# make test TEST_VERBOSE=1 TEST_FILES='t/Factory.t'
# make testdb TEST_FILE=t/Factory.t
#########################

my $json = <<'END_JSON';
{
    "name":"infoBoard",
    "xlogfile" : "testInfoGopher.log",
    "sources" :
        [
            {
            "name" : "",
            "module" : "InfoGopher::InfoSource::RSS",
            "url" : "https://",
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

ok ( 'InfoGopher' eq ref $gopher, 'Is it a gopher?' ) ;

ok ( 1 == $gopher -> count_info_sources, "got exactly one info source" ) ;
ok ( 1 == $gopher -> count_info_sinks, "got exactly one info sink" ) ;

exit 0 ;

