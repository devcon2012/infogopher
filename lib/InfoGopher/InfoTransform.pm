package InfoGopher::InfoTransform ;

# see below for docu and copyright information
# tests: testTransform.t
#
# virtual baseclass for all transformers. 
#

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

# -----------------------------------------------------------------------------
# transform_all
#
# in    $info_bites
#
# ret   $info_bites

sub transform_all
    {
    my ( $self, $info_bites) = @_ ;

    my $n = $info_bites -> count ;
    my $i = NewIntention ( 'Transform all $n input bites' ) ;

    my $transformed_bites = $info_bites -> clone ;
    foreach my $ib ( $info_bites -> all)
        {
        $transformed_bites -> add( $self -> transform ( $ib ) ) ;
        }

    return $transformed_bites ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoTransform - extract, transmogrify or .. info bits (aggregation)

A transformation takes InfoBite(s) input and yields InfoBite(s). The intention is to aggregate
information, change the mime type, summarize, ... A transformation usually takes place as data
enters an InfoDivergence.

A renderer on the other hand takes InfoBites and produces raw data, a perl scalar. Rendering usually 
takes place as data leaves an InfoDivergence.

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
