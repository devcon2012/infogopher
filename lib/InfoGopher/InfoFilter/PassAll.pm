package InfoGopher::InfoFilter::PassAll ;

#
# Filter passing all infobites
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;

use Moose;

extends 'InfoGopher::InfoRenderer' ;
with 'InfoGopher::InfoRenderer::_InfoRenderer' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# filter - judge one infobite (and mercifull accept all)
#
# in $bite - one info bite
#
# ret $bite
#
sub filter
    {
    my ($self, $bite) = @_ ;
    return $bite ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoFilter::PassAll - accept any infobite

Filtering takes place as infobites are passed from an InfoSource to an InfoSink

=head1 USAGE

    my $filtered_bite = InfoGopher::InfoFilter::PassAll -> filter ( $bite ) ;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
