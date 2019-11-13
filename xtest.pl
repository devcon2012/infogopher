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
use InfoGopher::InfoSource::RSS ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;

use TinyMock::HTTP ;

our ($mock, $mock2) ;

BEGIN 
    { 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('RSS', 7080) ; # fork mock serving mock 'RSS' on 127.0.0.1:7080 
    $mock2 = TinyMock::HTTP -> new ();
    $mock2 -> setup('RSS2', 7081, 'response2') ;
    } ;

BEGIN 
    {
    # this would redirect log from sterr to a file
    # open( my $loghandle, ">", "demoGopher.log" ) 
    #    or die "cannot open log: $!" ;
    # InfoGopher::Logger -> handle ( $loghandle ) ;
    } ;

my $i = InfoGopher::NewIntention ( 'Demonstrate InfoGopher use' ) ;

my ( $gopher, $rss, $rss2 ) ;

try
    {
    my $i = InfoGopher::NewIntention ( 'Construct an InfoGopher' ) ;

    $gopher = InfoGopher -> new ;
    $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7080") ;
    $rss -> name ('Politik') ;
    $gopher -> add_info_source($rss) ;

    $rss2 = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7081") ;
    $rss2 -> name ('Wirtschaft') ;
    $gopher -> add_info_source($rss2) ;

    InfoGopherException::ThrowInfoGopherException("DEMO- no such file 'bla.txt' $!") ;
    }
catch
    {
    my $e = $_ ;
    InfoGopher::IntentionStack -> unwind($e -> what) ;
    exit 1 
        if ( $e -> what !~ /DEMO/ ) ;
    };

try
    {
        {
        my $i = InfoGopher::NewIntention( 'collect info bits' ) ;
        $gopher -> collect() ;
        }

    $gopher -> dump() ;

        {
        my $i = InfoGopher::NewIntention( 'collect info bits again' ) ;
        $gopher -> collect() ;
        }

    $gopher -> dump() ;

    $mock2 -> set_responsefile_content('four_o_four') ; 

        {
        my $i = InfoGopher::NewIntention( 'collect info bits yet again' ) ;
        $gopher -> collect() ;
        }

    $gopher -> dump() ;

    }
catch
    {
    my $e = $_ ;
    InfoGopher::IntentionStack -> unwind($e -> what) ;

    exit 1 ;
    };

undef $i ;

InfoGopher::Logger -> log ( "Thats it!" ) ;


END 
    { 
    $mock -> shutdown() ; 
    } ;
