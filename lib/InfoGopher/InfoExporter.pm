package InfoGopher::InfoExporter ;

#
# virtual baseclass for all Exporters. 
#

use strict ;
use warnings ;

use Moose;

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoExporter - virtual baseclass for all InfoExporters

=head1 USAGE

my $exporter = InfoGopher::InfoExporter -> new () ;

my $data = $exporter -> export ( $infobites ) ;
$infogopher -> exporter ($export) ;

An InfoExporter object takes infobites and creates one new data item from it, 
e.g. a JSON Structure.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
