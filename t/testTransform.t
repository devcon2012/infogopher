
use strict;
use warnings;

use Test::More tests => 2;

use Try::Tiny ;
use Data::Dumper ;

BEGIN { use_ok('InfoGopher::InfoTransform::HTMLExtractor::TagTransformer') };

# make test TEST_VERBOSE=1 TEST_FILES='t/testTransform.t'
# make testdb TEST_FILE=t/testTransform.t
#########################

my $t = InfoGopher::InfoTransform::HTMLExtractor::TagTransformer -> new ;
my $style = $t -> style ;
ok ( $style =~ /^[a-z,]+$/, 'Style OK');
exit 0 ;