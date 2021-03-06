package InfoGopher::Intention ;

# Intentions help make logs readable:
#
# At the beginning of a sub/block/... , create one like so:
#   my $i = NewIntention ( 'Demonstrate InfoGopher use' ) ;
#
# Catch Exceptions where appropriate like so:
#   catch
#       {
#       my $e = $_ ;  UnwindIntentionStack($e -> what) ;
#       }
#
# Do not die! This would remove intentions from the stack that we need
#   for analysis
# 
#
use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Moose ;
use MooseX::ClassAttribute ;

use InfoGopher::IntentionStack ;

#

# 
class_has '_serial_counter' => (
    documentation   => 'Intention serial number',
    is              => 'rw',
    isa             => 'Int',
    default         => sub { 1 },
) ;

# 
has 'serial' => (
    documentation   => 'Intention serial number',
    is              => 'rw',
    isa             => 'Int',
    builder         => '_get_serial'
) ;
sub _get_serial
    {
    my $self = shift ;
    my $serial = $self -> _serial_counter ;
    $self -> _serial_counter($serial + 1) ;
    return $serial ;
    }

has 'what' => (
    documentation   => 'Intention string',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

#

sub BUILD
    {
    my ($self) = @_ ;
    InfoGopher::IntentionStack -> add ( $self ) ;
    return ;
    }

sub DEMOLISH
    {
    my ($self) = @_ ;
    InfoGopher::IntentionStack -> remove ( $self ) ;
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1 ;
