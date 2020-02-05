package InfoGopher ;

# see below for docu and copyright information

use 5.018001;
use strict;
use warnings;
use Moose ;

# ABSTRACT: a high-level framework for collecting information, aggregating it and delivering the result elsewhere

our $VERSION = '0.05';

use InfoGopher::Essentials ;

use Try::Tiny ;
use Data::Dumper ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Just so I dont forget:
# https://metacpan.org/pod/Moose::Meta::Attribute::Native::Trait::Array
# https://metacpan.org/pod/Moose::Meta::Attribute::Native::Trait::Hash
#
has 'info_sources' => (
    documentation   => 'Array of info sources',
    is              => 'rw',
    isa             => 'ArrayRef[InfoGopher::InfoSource]',
    traits          => ['Array'],
    default         => sub { [] },
    handles => 
        {
        all_info_sources    => 'elements',
        add_info_source     => 'push',
        get_info_source     => 'get',
        count_info_sources  => 'count',
        has_info_sources    => 'count',
        has_no_info_sources => 'is_empty',
        clear_info_sources  => 'clear',
        },
    ) ;
our $id_serial = 0 ;
around 'add_info_source' => sub 
    {
    my ($orig, $self, $source) = @_ ;
    shift; shift ;

    if ( $source )
        {
        $source -> id ( $id_serial++ ) ;
        }
        
    return $self->$orig(@_);
    };

has 'info_sinks' => (
    documentation   => 'Array of info sinks',
    is              => 'rw',
    isa             => 'ArrayRef[InfoGopher::InfoSink]',
    traits          => ['Array'],
    default         => sub { [] },
    handles => 
        {
        all_info_sinks    => 'elements',
        add_info_sink     => 'push',
        get_info_sink     => 'get',
        count_info_sinks  => 'count',
        has_info_sinks    => 'count',
        has_no_info_sinks => 'is_empty',
        clear_info_sinks  => 'clear',
        },
    ) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# collect - trigger fetch for all info sources
#
#
#
sub collect
    {
    my ($self) = @_ ;

    my $n = $self->count_info_sources ;
    my $i = NewIntention ( "Collecting bits from $n sources" ) ;

    for ( my $i=0; $i < $self->count_info_sources; $i++)
        {
        my $source = $self -> get_info_source( $i ) ;

        try
            {
            $source -> fetch () ;
            }
        catch
            {
            my $e = $_ ;
            UnwindIntentionStack ( $e -> what, $i ) ;
            }
        }

    return ;
    }

# -----------------------------------------------------------------------------
# push_infos - push infobites collected to sinks
#
#
#
sub push_infos
    {
    my ($self) = @_ ;

    my $n = $self->count_info_sinks ;
    my $i = NewIntention ( "Pushing bits to $n sinks" ) ;

    my $infos = $self -> get_all ;

    for ( my $i=0; $i < $self->count_info_sinks; $i++)
        {
        my $sink = $self -> get_info_sink( $i ) ;

        $sink -> filter_input_infobites( $infos ) ;

        try
            {
            $sink -> push_infos () ;
            }
        catch
            {
            my $e = $_ ;
            UnwindIntentionStack ( $e -> what, $i ) ;
            }
        }

    return ;
    }

# -----------------------------------------------------------------------------
#
# get_all - assemble list of all InfoBites
#
# ret @bites
#
sub get_all
    {
    my ($self) = @_ ;

    my $n = $self->count_info_sources ;
    my $i = NewIntention ( "Assembling results from $n sources" ) ;

    my @results ;
    foreach my $source ( $self->all_info_sources )
        {
        push @results, $source -> info_bites ;
        }

    my $count = scalar @results ;

    Logger( "We have $count infobites in total", $i ) ;
    return \@results ;
    }

# -----------------------------------------------------------------------------
# dump_text - show what we got ( intended for debugging)
#
#
#
sub dump_text
    {
    my ($self) = @_ ;

    my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;

    my @result ;
    foreach my $source ( $self->all_info_sources )
        {
        my $intro = "InfoBites from " . $source -> name . " (" . $source -> uri . ")" ;
        $source -> dump_info_bites( $intro ) ;
        }
    return \@result ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;


__END__

=head1 NAME

InfoGopher - Perl Moose Class to collect info bits from a variety of sources.

=head1 SYNOPSIS

  use InfoGopher;

  my $gopher = InfoGopher -> new ;
  my $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7773") ;

  $gopher -> add_info_source($rss) ;
  $gopher -> collect() ;
  $gopher -> dump_text() ;

=head1 DESCRIPTION

An InfoGopher uses InfoSources (RSS Feeds, ...). It can update these over the net,
extract relevant pieces of information (an InfoBite) and provide these to other modules. 

=head2 METHODS

sub collect()
    Refresh all registered InfoSources

sub dump()
    print out what we got (intended for debugging)

sub all_info_sources
sub add_info_source
sub get_info_source
sub count_info_sources
sub has_info_sources
sub clear_info_sources
    Manage the internal list of InfoSources

=head2 EXPORTS

sub NewIntention ( $what )
    declare a new Intention for this context.

sub ThrowException ( $what )
    Throw an exception

=head1 SEE ALSO


=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
