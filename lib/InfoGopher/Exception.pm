package InfoGopher::Exception ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;

use Moose;

use InfoGopher::IntentionStack ;

has 'what' => (
    documentation   => 'exception error message',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    default         => '???',
) ;

sub BUILD
    {
    InfoGopher::IntentionStack -> freeze ( 1 ) ;
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;