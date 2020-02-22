
use strict;
use warnings;

use Test::More tests => 19 ;

use Try::Tiny ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::InfoBite') };
BEGIN { use_ok('InfoGopher::InfoBites') };

# make test TEST_VERBOSE=1 TEST_FILES='t/testBites.t'
# make testdb TEST_FILE=t/testInfoBites.t
#########################

my $bites = InfoGopher::InfoBites -> new ( source_name => 'testbites', source_id => 4711 ) ;
ok ( 1, 'InfoBites created' ) ;
ok ( $bites -> source_name eq 'testbites', 'list of bites name ok' ) ;
ok ( $bites -> source_id == 4711, 'list of bites id ok' ) ;

my $timestamp = time ;
my $bite = InfoGopher::InfoBite -> new (
            meta_infos  => { filename => 'test.txt' },
            mime_type   => 'text',
            data        => 'Hello InfoGopher!' ) ;

ok ( 1, 'InfoBite created' ) ;
ok ( $bite -> meta_infos -> {filename} eq 'test.txt', 'ibite meta ok' ) ;
ok ( $bite -> mime_type eq 'text', 'ibite mimetype ok' ) ;
ok ( $bite -> data eq 'Hello InfoGopher!', 'ibite data ok' ) ;
ok ( $bite -> time_stamp - $timestamp <=1, 'ibite timestamp ok' ) ;

sleep 2 ;
my $bite2 = $bite -> clone ;
ok ( ! defined $bite2 -> meta_infos -> {filename} , 'ibite2 meta ok' ) ;
ok ( $bite2 -> mime_type eq 'text', 'ibite2 mimetype ok' ) ;
ok ( $bite2 -> cloned, 'ibite2 cloned ok' ) ;

ok ( $bite2 -> data eq '', 'ibite2 data ok' ) ;
ok ( $bite2 -> time_stamp == $bite -> time_stamp, 'ibite2 timestamp ok' ) ;
ok ( $bite2 -> cloned >= $bite -> time_stamp + 2, 'ibite2 clone timestamp ok' ) ;

$bites -> add ( $bite ) ;
ok ( 1, 'Bite added to list of bites' ) ;
ok ( $bites -> count == 1, 'list of bites has correct size 1' ) ;

exit 0 ;

