package InfoGopher::Logger ;

use strict ;
use warnings ;

use Moose ;
use MooseX::ClassAttribute ;

use Carp qw( croak longmess ) ;

# 
# use like InfoGopher::Logger::handle ( 'InfoGopher::Logger', $handle ) ;   
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

# -----------------------------------------------------------------------------
#
# Log - log what we have to say
#   
# in    $msg            log message, will end in $class -> handle
#       [$intention]    context of this message

sub Log
    {
    my ($self, $msg, $intention) = @_  ;

    # print STDERR longmess if ( ! $msg ) ;
    my $fh = $self -> handle ;
    print $fh "$msg\n" ;
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;