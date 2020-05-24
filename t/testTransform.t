
use strict;
use warnings;

use Test::More tests => 5 ;

use Try::Tiny ;
use Data::Dumper ;

BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::InfoTransform::XML2JSON') };
BEGIN { use_ok('InfoGopher::InfoTransform::HTMLExtractor::TagTransformer') };

# setup logging
BEGIN 
    {
    open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;
    InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
    Logger('Test ' . __PACKAGE__ ) ;
    } ;

    {
    my $t = InfoGopher::InfoTransform::HTMLExtractor::TagTransformer -> new ;
    my $style = $t -> style ;
    ok ( $style =~ /^[a-z,]+$/, 'Style OK');
    
    }

    {
    my $t = InfoGopher::InfoTransform::XML2JSON -> new ;
    my $style = $t -> style ;
    ok ( $style =~ /^[a-z,]*$/, 'Style OK');
    }

exit 0 ;