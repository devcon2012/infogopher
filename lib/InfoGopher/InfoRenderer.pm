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

An InfoRenderer object takes an InfoBite and transforms it into whatever we need to
present it to the user. 

A RSS-Feed is a XML-File. The InfoSource reading that transforms this into a perl
data structure holding only those parts of the XML that interest us.
A HTML InfoRenderer could transform this to HTML for a browser, a JSON InfoRenderer could
be used in response to an AJAX Query, ...


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
