#!/usr/bin/perl
#
# demonstrate basic infogopher usage and concepts
# 

use strict ;
use warnings ;

use FindBin;
use lib "$FindBin::Bin/blib/lib";

use Try::Tiny ;

use InfoGopher ;
use InfoGopher::Essentials ;
use InfoGopher::InfoSource::RSS ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;
use InfoGopher::InfoRenderer::TextRenderer ;

use TinyMock::HTTP ;

our ($mock) ;

BEGIN 
    { 
    $ENV{MOCK_HOME} = "$FindBin::Bin/TinyMock" ;
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('INVALID_RSS', 7080) ; # fork mock serving mock 'RSS' on 127.0.0.1:7080 
    } ;

BEGIN 
    {
    # this would redirect log from sterr to a file
    # open( my $loghandle, ">", "demoGopher.log" ) 
    #    or die "cannot open log: $!" ;
    # InfoGopher::Logger -> handle ( $loghandle ) ;
    } ;

my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;

my ( $gopher, $rss ) ;

try
    {
    my $i = NewIntention ( 'Construct an InfoGopher' ) ;

    $gopher = InfoGopher -> new ;
    $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7080") ;
    $rss -> name ('Politik') ;
    $gopher -> add_info_source($rss) ;

    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;
    exit 1 ;
    };

try
    {
        {
        my $i = NewIntention( 'collect info bits' ) ;
        $gopher -> collect() ;
        }

    $gopher -> dump() ;

    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;

    exit 1 ;
    };

undef $i ;

Logger ( "Thats it!" ) ;


END 
    { 
    $mock -> shutdown() ; 
    } ;
