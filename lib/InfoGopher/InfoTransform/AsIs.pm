package InfoGopher::InfoTransform::AsIs ;

# see below for docu and copyright information
# tests: - 
#       

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Moose;
use Try::Tiny;

extends 'InfoGopher::InfoTransform' ;
with 'InfoGopher::InfoTransform::_InfoTransform' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# transform
#
# in    $info_bite
#
# ret   $info_bites
#
sub transform
    {
    my ( $self, $info_bite) = @_ ;

    my $info_bites = InfoGopher::InfoBites -> new ;
    $info_bites -> add ( $info_bite ) ;
    return $info_bites ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoTransform::AsIs - trivial transform doing no changes

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
