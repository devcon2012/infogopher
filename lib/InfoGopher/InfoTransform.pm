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
use InfoGopher::InfoRenderer::RawRenderer ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# options - mostly flags finetuning transform behaviour 
#
#   split - split into many tiny bits, a rss feed to items, an imap to single mails...
# 
has 'options' => (
    documentation   => 'Transformation options getter/setter',
    is              => 'rw',
    lazy            => 1 ,
    isa             => 'HashRef[Any]',
    traits          => ['Hash'],
    builder         => '_default_transform_options',
    handles         => {
        _set_option      => 'set',
        delete_option    => 'delete',
        get_option       => 'get',
        has_option       => 'exists',
        clear_options    => 'clear'
        },
    ) ;
sub _default_transform_options
    {
    return { split => 1 };
    }
sub set_option
    {
    my ( $self, $option, $val ) = @_ ;
    $val //= 1;
    return $self -> _set_option ($option, $val);
    }

has 'renderer' => (
    documentation   => 'infobit renderer',
    is              => 'rw',
    lazy            => 1 ,
    isa             => 'InfoGopher::InfoRenderer',
    builder         => '_default_renderer',
    ) ;
sub _default_renderer
    {
    my ($self) = @_ ;
    return InfoGopher::InfoRenderer::RawRenderer -> new ;
    }


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

InfoGopher::InfoTransform - extract, transmogrify or .. info bits (aggregation)

=head1 USAGE

my $transformation = InfoGopher::InfoTransform -> new () ;

my $infobits = $transformation -> transform ($infobit) 


$infobits -> transform ( $transformer ) ;

=head1 TRANSFORMATIONS

Transformations accept only specific mime-types.

=head2 RSS2JSON

This transformation takes an application/rss+xml infobit and transforms it into
JSON, either one JSON for all the feed items or on ibite per item

=head2 ATOM2JSON

This transformation takes an application/atom+xml infobit and transforms it into
JSON, either one JSON for all the feed entries or on ibite per item

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
