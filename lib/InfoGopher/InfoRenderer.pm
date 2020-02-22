package InfoGopher::InfoRenderer ;

# see below for docu and copyright information
# tests: testRenderer.t
#
# virtual baseclass for all renderers. 
#

use strict ;
use warnings ;

use Moose;
use InfoGopher::Essentials ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# render - render one bite of info
#
# in $bite - one info bite
#
# ret $info - rendered info bite
#
sub render
    {
    my ($self, $bite) = @_ ;

    die "VIRTUAL render in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;

    }

# -----------------------------------------------------------------------------
# render_all - render info bites
#
# in    $info_bites 
#
# ret   $info - rendered info bites
#
sub render_all
    {
    my ( $self, $info_bites ) = @_ ;

    my $n = $info_bites -> count ;
    my $i = NewIntention ( 'Render all $n input bites' ) ;

    my $data = '' ;
    foreach my $ib ( $info_bites -> all)
        {
        $data .= $self -> render ( $ib ) ;
        }

    return $data ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoRenderer - virtual baseclass for all InfoRenderers

=head1 USAGE

An InfoRenderer object takes one InfoBite and transforms it into some other format. 

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
