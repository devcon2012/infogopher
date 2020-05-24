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
use InfoGopher::Factory ;

my $cfg = 'InfoGopherConfig.json' ;

my $i = NewIntention ( 'Start InfoGopher server' ) ;
my $gopher ;

try
    {
    my $i = NewIntention ( 'Read Configuration' ) ;
    open( my $fh, '<', $cfg ) or die "Cannot open for read $cfg: $!";
    local $/ = undef ;    
    my $json = <$fh> ;
    close ($fh) ;
    $gopher = InfoGopher::Factory -> produce ($json) ;
    }
catch
    {
    my $e = NormalizeException( $_ ) ;
    UnwindIntentionStack($e -> what) ;
    exit 1 ;
    };

try
    {
    $gopher -> run ;
    }
catch
    {
    my $e = NormalizeException($_) ;
    UnwindIntentionStack($e -> what) ;
    exit 1 ;
    };


Logger ( 'InfoGopher server ends normally' ) ;

exit 0 ;
