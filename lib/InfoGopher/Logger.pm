package InfoGopher::Logger ;

use strict ;
use warnings ;

use Moose ;
use MooseX::ClassAttribute ;

#use Carp qw( croak longmess ) ;

# 
class_has 'handle' => (
    documentation   => 'logger file handle',
    is              => 'rw',
    isa             => 'Any',
    lazy            => 1,
    builder         => '_build_log_destination' ,
) ;
sub _build_log_destination
    {
    return *STDERR ;
    }

sub log
    {
    my ($self, $msg) = @_  ;

    # print STDERR longmess if ( ! $msg ) ;
    my $fh = $self -> handle ;
    print $fh "$msg\n" ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;