
use strict;
use warnings;

use Test::More tests => 18 ;
use Try::Tiny ;
use Data::Dumper ;


BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Essentials') };
BEGIN { use_ok('InfoGopher::Logger') };
BEGIN { use_ok('InfoGopher::Intention') };
BEGIN { use_ok('InfoGopher::IntentionStack') };


BEGIN 
    { 
    require InfoGopher::Logger;

     open( my $loghandle, ">>", "testInfoGopher.log" ) 
        or die "cannot open log: $!" ;

    InfoGopher::Logger::handle ('InfoGopher::Logger', $loghandle ) ;

    } ;

#########################

my $intention = NewIntention ( 'test1' ) ;
    {
    my $i = NewIntention ( 'test2' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted , 'Intention stack ok') ;
    undef $i ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted, 'undef top did not corrupt' ) ;
    }
undef $intention ;
ok ( ! InfoGopher::IntentionStack -> is_corrupted , 'undef all did not corrupt') ;

$intention = NewIntention ( 'test1b' ) ;
    {
    my $i = NewIntention ( 'test2b' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted , 'Intention stack ok lvl2' ) ;
        {
        my $i = NewIntention ( 'test3b' ) ;
        ok ( ! InfoGopher::IntentionStack -> is_corrupted, 'Intention stack ok lvl3' ) ;
        }
    }
ok ( ! InfoGopher::IntentionStack -> is_corrupted, 'Intention stack ok lvl0' ) ;
    {
    my $i1 = NewIntention ( 'test3b' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted, 'Intention stack ok lvl2b') ;

    my $i2 = NewIntention ( 'test4b' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted, 'Intention stack ok lvl3b' ) ;
    undef ( $i1 ) ;

    ok ( InfoGopher::IntentionStack -> is_corrupted, 'force undef against stack order corrupts' ) ;
    }

undef $intention ;
InfoGopher::IntentionStack -> reset_intention_stack ;
ok ( ! InfoGopher::IntentionStack -> is_corrupted, 'Intention stack ok after reset' ) ;

$intention = NewIntention ( 'test1c' ) ;

my $stack = UnwindIntentionStack ("bla") ;
#print STDERR Dumper($stack) ;

ok ( 1 == scalar @$stack, 'Intention stack count ok' ) ;

my $intention2 = NewIntention ( 'test1d' ) ;
$stack = UnwindIntentionStack ("bla") ;
ok ( 2 == scalar @$stack, 'Intention stack count ok 2' ) ;

SKIP:
    {
    skip "KNOWN PROBLEM", 1 ;
    try
        {
        my $intention = NewIntention ( 'killed by death' ) ;
        die "dont do that" ;
        }
    catch 
        {
        my $stack = UnwindIntentionStack ("bla") ;
        ok ( 3 == scalar @$stack , 'die does not freeze intention stack (TODO)') ;
        } ;
    }

try 
    {
    my $intention = NewIntention ( "test unwind in array context" ) ;
    ThrowException ( 'demo' ) ;
    }
catch
    {
    my ( $intentions, $stack ) = UnwindIntentionStack ( "" ) ;
    #diag ($stack) ;
    } ;

note ( "END" ) ;

