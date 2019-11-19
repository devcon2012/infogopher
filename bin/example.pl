#!/usr/bin/perl
#
# demonstrate basic infogopher usage and concepts
# 

use strict ;
use warnings ;

use FindBin;
use lib "$FindBin::Bin/../blib/lib";

use Try::Tiny ;

use InfoGopher ;
use InfoGopher::Essentials ;
use InfoGopher::InfoSource::RSS ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;

my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;

my ( $gopher, $rss, $rss2 ) ;

try
    {
    my $i = NewIntention ( 'Construct an InfoGopher' ) ;

    $gopher = InfoGopher -> new ;
    $rss = InfoGopher::InfoSource::RSS -> new ( uri => "https://krebsonsecurity.com/feed/") ;
    $rss -> name ('Brian') ;
    $gopher -> add_info_source($rss) ;

    $rss2 = InfoGopher::InfoSource::RSS -> new ( uri => "http://www.tagesschau.de/xml/rss2") ;
    $rss2 -> name ('Nachrichten') ;
    $gopher -> add_info_source($rss2) ;

    ThrowException("DEMO- no such file 'bla.txt' $!") ;
    }
catch
    {
    my $e = $_ ;
    UnwindIntentionStack($e -> what) ;
    exit 1 
        if ( $e -> what !~ /DEMO/ ) ;
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

