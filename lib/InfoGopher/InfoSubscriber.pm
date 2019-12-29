package InfoGopher::InfoSubscriber ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

with 'InfoGopher::_URI' ;

use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::TextRenderer ;

extends 'InfoGopher::InfoSource' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
#
# fetch - NOP for a subscriber
#   
#
sub fetch
    {
    my ( $self) = @_ ;

    return ;
    }


# -----------------------------------------------------------------------------
#
# subscribe - virtual method 
#   
#
sub subscribe
    {
    my ( $self) = @_ ;

    die "VIRTUAL subscribe in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;
    }


# -----------------------------------------------------------------------------
#
# unsubscribe - virtual method 
#   
#
sub unsubscribe
    {
    my ( $self) = @_ ;

    die "VIRTUAL unsubscribe in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;
    }


__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoSubscriber - InfoSource variant "listening" for updates
instead of fetching.
Uses AnyEvent / Coro and thus requires use of condition variables etc.

=head1 USAGE

my $source = InfoGopher::InfoSubscriber::MQTT -> new ( uri => "mqtt://...") ;
$source -> name ("mosquitto") ;
$cv -> recv ; # AnyEvent condition variable 

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
