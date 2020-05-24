package InfoGopher::InfoSource::_InfoSource ;

# role to prevent instantiation of incomplete InfoSources 
# and auto apply transforms

use strict ;
use warnings ;

use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Moose::Role ;

use InfoGopher::Essentials ;
 
requires 'fetch' ;

around 'fetch' => sub 
    {
    my $orig = shift ;
    my $self = shift ;

    #!dump( "around fetch" )!

    my $ret ; 
    if ( @_ )
        {
        my $id = shift ;
        $ret = $self -> $orig ( $id ) ;
        }
    else
        {
        $ret = $self -> $orig ( ) ;
        }


    my $t = $self -> transformation () ;

    my $name = $self -> name ;
    my $n = $self -> info_bites -> count ;
    my $i = NewIntention ( "Transform $n ibites from $name with " . ref $t ) ;
    
    if ( $t )
        {
        #!dump( ref $t )!
        $self -> info_bites -> transform ( $t ) ;
        }

    $n = $self -> info_bites -> count ;
    Logger ("Transform yields $n ibites", $i) ;


    return $ret ;

    };


1;

 