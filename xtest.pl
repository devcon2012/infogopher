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
use InfoGopher::InfoSource::RSS ;
use InfoGopher::InfoSource::Web ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;
use InfoGopher::InfoRenderer::TextRenderer ;
use InfoGopher::InfoTransform::HTMLExtractor ;

use TinyMock::HTTP ;

our ($mock, $port) ;

BEGIN 
    { 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('RSS', 7080) ; # fork mock serving mock 'RSS' on 127.0.0.1:7080 
    } ;

BEGIN 
    {
    # this would redirect log from sterr to a file
    # open( my $loghandle, ">", "demoGopher.log" ) 
    #    or die "cannot open log: $!" ;
    # InfoGopher::Logger -> handle ( $loghandle ) ;
    } ;

my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;

my ( $gopher, $web ) ;

$port = $mock -> port ;

#$web = InfoGopher::InfoSource::Web -> new( uri => 'https://www.ecos.de' ) ;

$web = InfoGopher::InfoSource::RSS -> new( uri => "http://127.0.0.1:$port" ) ;
$web -> fetch ;
$web -> dump_info_bites("initial") ;

exit (0) ;
my $t = InfoGopher::InfoTransform::HTMLExtractor -> new ;

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
