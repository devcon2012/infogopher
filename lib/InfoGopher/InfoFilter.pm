package InfoGopher::InfoFilter ;

# see below for docu and copyright information
# tests: testFilter.t
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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# filter
#
# in    $info_bite
#
# ret   $info_bite or undef
sub filter
    {
    my ( $self, $info_bite) = @_ ;

    die "VIRTUAL filter in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;

    }

# -----------------------------------------------------------------------------
# filter_all
#
# in    $info_bites
#
# ret   $infobites

sub filter_all
    {
    my ( $self, $info_bites) = @_ ;

    my $filtered_bites = $info_bites -> clone ;

    foreach my $ib ( $info_bites -> all)
        {
        my $passed = $self -> filter ( $ib ) ;
        $filtered_bites -> add ( $passed ) 
            if ( $passed ) ;
        }

    return $filtered_bites ;
    }


__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoFilter - predicate to identify relevant infobites

Filtering takes place as infobites are passed from an InfoSource to an InfoSink

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
