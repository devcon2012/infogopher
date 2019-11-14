package InfoGopher::HTTPSInfoSource ;

# extends http infosource to work with certificates and credentials

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::Essentials ;

extends 'InfoGopher::HTTPInfoSource' ;

use constant source_type => 'virtual_base_class' ;

# overload to require credentials
use constant needs_credentials => undef ;

has 'ca_store' => (
    documentation   => 'https ca store',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ""
) ;

has 'allow_untrusted' => (
    documentation   => 'allow read from untrusted sources',
    is              => 'rw',
    isa             => 'Int',
    default         => 1
) ;

has 'user' => (
    documentation   => 'user name',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'pw' => (
    documentation   => 'password',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

sub login
    {
    my ( $self, $user, $pass ) = @_ ;
    die "VIRTUAL METHOD login in " . __PACKAGE__ . " NOT OVERLOADED" ;
    }

sub get_https
    {
    my ($self) = @_ ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;
