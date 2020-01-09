#!/usr/bin/perl
#
# demonstrate rocketchat infogopher usage
# 

use strict ;
use warnings ;

use FindBin;
use lib "$FindBin::Bin/blib/lib";

use Try::Tiny ;
use Data::Dumper ;
use JSON::MaybeXS ;

use InfoGopher ;
use InfoGopher::Essentials ;
use InfoGopher::InfoSource::RocketChat ;

BEGIN 
    {
    # this would redirect log from sterr to a file
    # open( my $loghandle, ">", "demoGopher.log" ) 
    #    or die "cannot open log: $!" ;
    # InfoGopher::Logger -> handle ( $loghandle ) ;
    } ;

our $shutdown = 0 ;

our $ROCKET_HOST = $ENV{ROCKET_HOST} ;

# user/key is created under your account settings
our $ROCKET_USER = $ENV{ROCKET_USER} ;
our $ROCKET_KEY  = $ENV{ROCKET_KEY} ;

$SIG{'INT'} = sub { $shutdown = 1 ; };

my $i = NewIntention ( 'Demonstrate InfoGopher use with RocketChat' ) ;

    {
    my ( $gopher, $src, $t ) ;

    try 
        {
        $src = InfoGopher::InfoSource::RocketChat -> new( uri => "https://$ROCKET_HOST/api/v1/directory" ) ;
        $src -> auth_token( $ROCKET_KEY ) ;
        $src -> auth_user( $ROCKET_USER ) ;
        $src -> allow_untrusted ( 1 ) ;
        }
    catch
        {
        my $e = NormalizeException($_) ;
        UnwindIntentionStack($e -> what) ;

        exit 1 ;
        } ;

    try 
        {
        while ( ! $shutdown )
            {
            $src -> fetch ;
            $src -> dump_info_bites( "initial" ) ;
            sleep ( 10 ) ;
            }
        }
    catch
        {
        my $e = NormalizeException( $_ ) ;
        UnwindIntentionStack ( $e -> what ) ;
        exit 1 ;
        } ;
    
    my $ibite = $src -> info_bites -> get ( 0 ) ;
    my $json = $ibite -> data ;

    print STDERR Dumper( JSON -> new -> decode ( $json ) ) ;

    try
        {
        my $i = NewIntention ( 'Cleanup InfoGopher' ) ;
        #$src -> unsubscribe ;
        undef $src ;
        }
    catch
        {
        my $e = NormalizeException( $_ ) ;
        UnwindIntentionStack ( $e -> what ) ;
        exit 1 ;
        } ;

    }

exit 0 ;

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
