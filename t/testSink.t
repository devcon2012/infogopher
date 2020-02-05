use strict;
use warnings;

use Test::More tests => 11;

use TinyMock::HTTP ;
use Try::Tiny ;
use Data::Dumper ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# testSink - test InfoSinks
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

use constant target_filename => 'FileReceiverData.tmp' ;

BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::InfoBite') };
BEGIN { use_ok('InfoGopher::InfoBites') };
BEGIN { use_ok('InfoGopher::InfoSink::PerlReceiver') };
BEGIN { use_ok('InfoGopher::InfoSink::FileReceiver') };

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

#
# make test TEST_VERBOSE=1 TEST_FILES='t/testSink.t'
# make testdb TEST_FILE=t/testSink.t

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $intention = NewIntention ( 'test InfoSinks' ) ;
my $target = '' ;

my $perl_sink = InfoGopher::InfoSink::PerlReceiver -> new ( target_variable => \$target ) ;
ok ( 1, 'PerlReceiver created' ) ;

unlink target_filename ;

my $file_sink = InfoGopher::InfoSink::FileReceiver -> new ( file_name => target_filename ) ;
ok ( 1, 'FileReceiver created' ) ;

my $bite  = InfoGopher::InfoBite -> new (mime_type => 'text', data => 'Hello Sink!' ) ;
my $bites = InfoGopher::InfoBites -> new ;
$bites -> add ($bite) ;

$perl_sink -> push_info ( $bites ) ;
note ("target is now $target") ;
ok ( $target eq 'Hello Sink!', 'Perlreceiver worked' ) ;

$file_sink -> info_bites ( $bites ) ;
ok ( 1 == $file_sink -> info_bites -> count , 'filereceiver received bites' ) ;
$file_sink -> push_info ( ) ;
ok ( -r target_filename, 'filereceiver created file' ) ;

    {
    open ( my $fh, '<', target_filename ) 
        or die 'Cannot open target' . target_filename ;
    local $\ = undef ;
    my $data = <$fh> ;
    close ( $fh ) ;
    note ( "Data: $data" ) ;
    ok ( $data eq 'Hello Sink!', 'Filereceiver worked' ) ;
    }

unlink target_filename ;
exit 0 ;
