package InfoGopher::InfoTransform::_InfoTransform ;

# role to prevent instantiation of an incomplete InfoTransform ;

use Moose::Role ;
 
requires 'process' ;

1;

__END__

=head1 NAME

_InfoTransform - Role to prevent instantiation of an incomplete InfoTransform 

=head1 METHODS

my $data = process ($bite) - process one InfoGopher::InfoBite and return plain data in 
some format we want.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
