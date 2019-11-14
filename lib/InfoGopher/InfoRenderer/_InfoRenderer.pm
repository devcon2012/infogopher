package InfoGopher::InfoRenderer::_InfoRenderer ;

# role to prevent instantiation of an incomplete InfoRenderer ;

use Moose::Role ;
 
requires 'process' ;

1;

__END__

=head1 NAME

_InfoRenderer - Role to p

=head1 METHODS

process ($bite) - process one InfoGopher::InfoBite and return whatever we want

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
