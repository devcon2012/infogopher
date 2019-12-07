package InfoGopher::InfoTransform ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;

use constant source_type => 'virtual_base_class' ;


has 'options' => (
    documentation   => 'Transformation options getter/setter',
    is              => 'rw',
    isa             => 'HashRef[Str]',
    traits          => ['Hash'],
    default         => sub { {} },
    handles         => {
        set_option      => 'set',
        get_option      => 'get',
        delete_option   => 'delete',
        delete_options  => 'clear'
        },
    ) ;

# -----------------------------------------------------------------------------
# transform
#
# in    $info_bite
#
# ret   $info_bites
sub transform
    {
    my ( $self, $info_bite) = @_ ;

    die "VIRTUAL transform in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;

    }


__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoTransform - extract, resize, transmogrify info bits (aggregation)




=head1 USAGE

my $transformation = InfoGopher::InfoTransform -> new () ;

my $infobits = $transformation -> transform ($infobit) 

$infobits -> transform ( $transformer ) ;

=head1 TRANSFORMATIONS

Transformations accept only specific mime-types.

=head2 RSS2JSON

This transformation takes an application/rss+xml infobit and transforms it into
JSON.

=head2 HTMLExtractor

Takes a html infobit, parses it and returns configurable items, eg all headlines,
all links or ...

=head2 IMAPEnvelopeParser

Take an IMAP envelope and extract sender, subject, date.


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
