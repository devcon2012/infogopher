package InfoGopher::InfoTransform::Grep ;

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
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'regex' => (
    documentation   => 'regex filtering input',
    is              => 'rw',
    isa             => 'Str',
) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# transform
#
# in    $info_bite - data with 
#
# ret   $info_bites
#
sub transform
    {
    my ( $self, $info_bite) = @_ ;

    my $type = $info_bite -> mime_type ;
    if ( $type !~ /text/ )
        {
        ThrowException(__PACKAGE__ . ' requires a text mime type, not ' . $type ) ;
        }
    
    my $info_bites = InfoGopher::InfoBites -> new ;

    my $text = $info_bite -> data ;
    my $re   = $self -> regex ;
    my @hits = $text =~ /$re/s ; 

    foreach ( @hits )
        {
        my $new_bite = $info_bite -> copy ($_) ;
        $info_bites -> add ( $new_bite ) ;
        }

    return $info_bites ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoTransform::Grep - appy re to input string ;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
