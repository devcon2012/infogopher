#!/usr/bin/perl
#
# demonstrate basic infogopher usage and concepts
# 

use strict ;
use warnings ;

use FindBin;
use lib "$FindBin::Bin/../blib/lib";

use Try::Tiny ;
use JSON::MaybeXS ;

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
    my $rss2json = InfoGopher::InfoTransform::RSS2JSON -> new () ;
    $rss -> transformation ( $rss2json ) ;
    $gopher -> add_info_source($rss) ;

    $rss2 = InfoGopher::InfoSource::RSS -> new ( uri => "http://www.tagesschau.de/xml/rss2" ) ;
    $rss2 -> name ('Nachrichten') ;
    $rss2 -> transformation ( $rss2json ) ;
    $gopher -> add_info_source( $rss2 ) ;

        {
        my $i = NewIntention ( 'Demonstrate intention stack unwind' ) ;
        ThrowException("DEMO- no such file 'bla.txt' $!") ;
        }
    }
catch
    {
    my $e = NormalizeException( $_ ) ;
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

    $gopher -> dump_text () ;

    }
catch
    {
    my $e = NormalizeException($_) ;
    UnwindIntentionStack($e -> what) ;

    exit 1 ;
    };

try
    {
    my $i = NewIntention ( 'Show results' ) ;

    my $bites_list = $gopher -> get_all ;
    foreach my $infobites ( @$bites_list )
        {
        print STDERR "Results from " . $infobites -> source_name . "\n";
        foreach my $infobite ( $infobites -> all )
            {
            print "  Infobite type " . $infobite -> mime_type . "\n" ;
            print "  Infobite from " . localtime ($infobite -> time_stamp ) . "\n" ;
            print "  Infobite size " . (length $infobite -> data ) . " chars\n" ;
#            my $data = JSON -> new -> utf8 -> decode ($infobite -> data) ; Houston, we have a problem
            my $data = JSON -> new -> decode ($infobite -> data) ;
            print "  RSS Title: " . $data -> {title} . "\n\n" ;
            } 
        }
    }
catch
    {
    my $e = NormalizeException($_) ;
    UnwindIntentionStack($e -> what) ;

    exit 1 ;

    };

undef $i ;

Logger ( "Thats it!" ) ;

