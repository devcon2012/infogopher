package InfoGopher::InfoRenderer ;

#
# virtual baseclass for all renderers. 
#

use strict ;
use warnings ;

use Moose;


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
