package InfoGopher::InfoSink::_InfoSink ;

# role to prevent instantiation of an incomplete InfoSink ;

use Moose::Role ;
 
requires 'push_info' ;

1;

__END__

=head1 NAME

_InfoSink - Role to prevent instantiation of an incomplete InfoGopher::InfoSink

=head1 METHODS


=head1 SEE ALSO

InfoGopher::InfoRenderer

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
