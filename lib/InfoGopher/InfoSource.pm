package InfoGopher::InfoSource ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::InfoDivergence ;
use InfoGopher::InfoTransform::AsIs ;

extends 'InfoGopher::InfoDivergence' ;
with 'InfoGopher::_URI' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'transformation' => (
    documentation   => 'default raw data aggregation on input, if any',
    is              => 'rw',
    isa             => 'Maybe[InfoGopher::InfoTransform]',
    lazy            => 1,
    builder         => '_build_transform'
) ;
sub _build_transform
    {
    return InfoGopher::InfoTransform::AsIs -> new ;
    }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# -----------------------------------------------------------------------------
#
# fetch - virtual method 
#
#   fetching obtains a fresh copy from the URI, applying 
#       defined transformations
#   
#
sub fetch
    {
    my ( $self ) = @_ ;

    die "VIRTUAL fetch in " . __PACKAGE__ . " NOT OVERLOADED IN " . ref $self ;
    
    }

__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoSource - fetch information from a variety of sources

Sources can be anything fetched via network: HTML, web cam pictures, 
imap accounts, ...

Fetching Information yields infobites, which can then be aggregated with an 
InfoTransform object. An InfoTransform accepts only specific type of input.



=head1 USAGE

my $source = InfoGopher::InfoSource::RSS -> new ( uri => "https://...") ;
$source -> name ("xx webfeed") ;
$source -> fetch () ;

=head1 TRANSFORMATIONS

=head2 RSS2JSON

This transformation takes a application/rss+xml infobit and transforms it into
a list of JSO

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
