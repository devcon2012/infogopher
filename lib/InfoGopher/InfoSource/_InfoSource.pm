package InfoGopher::InfoSource::_InfoSource ;

# role to prevent instantiation of incomplete InfoSources 
# and auto apply transforms

use strict ;
use warnings ;

use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Moose::Role ;
 
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
    
    if ( $t )
        {
        #!dump( ref $t )!
        $self -> info_bites -> transform ( $t ) ;
        }


    return $ret ;

    };


1;

 