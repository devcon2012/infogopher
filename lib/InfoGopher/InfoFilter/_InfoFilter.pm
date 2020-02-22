package InfoGopher::InfoFilter::_InfoFilter ;

# role to prevent instantiation of an incomplete InfoFilter ;

use Moose::Role ;
 
requires 'filter' ;

1;

__END__

=head1 NAME

_InfoFilter - Role to prevent instantiation of an incomplete InfoGopher::InfoFilter

=head1 SEE ALSO

InfoGopher::InfoFilter
InfoGopher::InfoRenderer
InfoGopher::InfoTransform

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
