package InfoGopher::InfoTransform::XML2JSON ;

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
use XML::XML2JSON ;

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
    my $xml  = $info_bite -> data ;
    my $json = XML::XML2JSON -> new() -> convert( $xml ) ;
    my $json_info_bite = $info_bite -> clone ;

    $json_info_bite -> mime_type ('application/json') ;
    $json_info_bite -> data ( $json ) ;

    $info_bites -> add ( $json_info_bite ) ;
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
