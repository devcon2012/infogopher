package InfoGopher::InfoSource ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

with 'InfoGopher::_URI' ;

use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::TextRenderer ;

# 
has 'name' => (
    documentation   => 'Information source name (for display only)',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

# 
has 'id' => (
    documentation   => 'id from InfoGopher',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => -1 
) ;
around 'id' => sub 
    {
    my ($orig, $self, $newid) = @_ ;
    shift; shift ;

    #!dump($newid)!
    $self -> info_bites -> source_id ( $newid ) ;

    return $self->$orig(@_);
    };

has 'raw' => (
    documentation   => 'Raw data obtained',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'last_fetch' => (
    documentation   => 'Timestamp last raw data obtained',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

has 'info_bites' => (
    documentation   => 'info_bites obtained',
    is              => 'rw',
    isa             => 'InfoGopher::InfoBites',
    lazy            => 1,
    builder         => '_build_info_bites',
) ;
sub _build_info_bites
    {
    return InfoGopher::InfoBites -> new () ;
    }

has 'transformation' => (
    documentation   => 'default raw data aggregation, if any',
    is              => 'rw',
    isa             => 'Maybe[InfoGopher::InfoTransform]',
) ;

sub BUILD 
    {
    my $self = shift ;

    my $uri = $self -> uri ;
    if ( '/' eq substr($uri, -1) )
        {
        $self -> uri ("$uri") ;
        }
    else
        {
        $self -> uri ("$uri/") ;
        }
    return;
    }


# -----------------------------------------------------------------------------
# add_info_bite - factory method to add a new info bite to the list
#
# in    $data
#       $mime_type
#       $time_stamp
#       $meta
#
# ret   $bite
#
sub add_info_bite
    {
    my ($self) = @_ ;
    shift ;

    return $self -> info_bites -> add_info_bite( @_ ) ;

    }


# -----------------------------------------------------------------------------
# dump_info_bites - dump into bites as text (for debugging)
#
#
sub dump_info_bites
    {
    my ( $self, $msg ) = @_ ;

    my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;

    my $n = $self -> info_bites -> count ;
    print STDERR "$msg ($n)\n";

    my $last =0 ;
    foreach ( $self -> info_bites -> all )
        {
        print STDERR $renderer -> process ($_) . "\n" ;
        my $meta = $_ -> meta_infos ;
        if ( keys %$meta )
            {
            if ( $meta == $last)
                {
                print STDERR "  META: (same)\n" ;
                }
            else
                {
                print STDERR "  META: " . Dumper ( $meta ) ;
                }
            $last = $meta ;
            }
        }
    return ;
    }

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
    my ( $self) = @_ ;

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
