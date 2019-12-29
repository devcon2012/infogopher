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
use InfoGopher::InfoTransform::RSS2JSON ;
use InfoGopher::InfoSource::ATOM ;
use InfoGopher::InfoTransform::ATOM2JSON ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;

my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;

my ( $gopher, $atom, $rss2, $mqtt ) ;

try
    {
    my $i = NewIntention ( 'Construct an InfoGopher' ) ;

    $gopher = InfoGopher -> new ;

    $mqtt = InfoGopher::InfoSource::MQTT -> new ( uri => 'mqtt://localhost/gopher' ) ;
    $mqtt -> name ('MQTT Gopher') ;
    $gopher -> add_info_source($mqtt) ;

    $atom = InfoGopher::InfoSource::ATOM -> new ( uri => 'http://blogzinet.free.fr/atom.php' ) ;
    $atom -> name ('blogzinet') ;
    my $atom2json = InfoGopher::InfoTransform::ATOM2JSON -> new () ;
    $atom2json -> set_option('split');
    $atom -> transformation ( $atom2json ) ;
    $gopher -> add_info_source($atom) ;

    $rss2 = InfoGopher::InfoSource::RSS -> new ( uri => 'http://www.tagesschau.de/xml/rss2' ) ;
    $rss2 -> name ('Nachrichten') ;
    my $rss2json = InfoGopher::InfoTransform::RSS2JSON -> new () ;
    $rss2json -> set_option('split');
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

    $gopher -> dump_text () ; # for debugging 

    }
catch
    {
    my $e = NormalizeException($_) ;
    UnwindIntentionStack($e -> what) ;

    exit 1 ;
    };

while ( 1 )
    {
    try
        {
        my $i = NewIntention ( 'Show results' ) ;

        my $bites_list = $gopher -> get_all ;
        foreach my $infobites ( @$bites_list )
            {
            print "Results from " . $infobites -> source_name . "\n";
            my $count = 0 ;
            foreach my $infobite ( $infobites -> all )
                {
                # my $data = JSON -> new -> utf8 -> decode ($infobite -> data) ; Houston, we have a problem
                my $data = JSON -> new -> decode ($infobite -> data) ;
                my $t = $data -> {title} ;
                next if ( ! $t ) ;
                print "  Title: $t\n" ;
                last if (++$count == 3 ) ;
                } 
            print "\n\n" ;
            }
        }
    catch
        {
        my $e = NormalizeException($_) ;
        UnwindIntentionStack($e -> what) ;

        exit 1 ;

        };
    print "Enter to update, X to exit\n" ;
    my $l = <> ;
    last if ( $l =~ /X/i ) ;

        {
        my $i = NewIntention( 'collect info bits' ) ;
        $gopher -> collect() ;
        }
    
    }
undef $i ;

Logger ( "Thats it!" ) ;

