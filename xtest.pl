#!/usr/bin/perl
#
# demonstrate basic infogopher usage and concepts
# 

use strict ;
use warnings ;

use FindBin;
use lib "$FindBin::Bin/blib/lib";

use Try::Tiny ;
use Data::Dumper ;

use InfoGopher ;
use InfoGopher::Essentials ;
use InfoGopher::InfoSource::ATOM ;
use InfoGopher::InfoSource::Web ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;
use InfoGopher::InfoRenderer::TextRenderer ;
use InfoGopher::InfoTransform::HTMLExtractor ;
use InfoGopher::InfoTransform::ATOM2JSON ;

use TinyMock::HTTP ;

our ($mock, $port) ;

BEGIN 
    { 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('HTML', 7080) ;
    } ;

BEGIN 
    {
    # this would redirect log from sterr to a file
    # open( my $loghandle, ">", "demoGopher.log" ) 
    #    or die "cannot open log: $!" ;
    # InfoGopher::Logger -> handle ( $loghandle ) ;
    } ;

my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;

my ( $gopher, $src, $t ) ;

$port = $mock -> port ;

$src = InfoGopher::InfoSource::ATOM -> new( uri => "https://krebsonsecurity.com/feed/atom/" ) ;
$t = InfoGopher::InfoTransform::ATOM2JSON -> new ;
$src -> transformation ( $t ) ;

$src -> fetch ;
$src -> dump_info_bites("initial") ;

__END__ 

my $t = InfoGopher::InfoTransform::HTMLExtractor -> new ;

# filter tags/classes
$t -> wanted_tags  ( {'div' => 1} ) ;
$t -> wanted_ids ( {'ticker-content' => 1} ) ;

# what to do?
$t -> tag2ibite->style('text') ;
#$t -> tag2ibite->style('href,resolve') ;

try
    {
    $web -> info_bites -> transform ( $t ) ;
    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;
    } ;

$web -> dump_info_bites("transformed") ;


__END__
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

    $gopher -> dump_text() ;

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
    $mock -> shutdown_mock() ; 
    } ;
