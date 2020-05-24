package InfoGopher::InfoBite ;

# Class to hold information obtained from an InfoSource  
# see below for docu and copyright information
# tests: testBites.t - covers members, copy, clone, touch ...
#       

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'data' => (
    documentation   => 'Raw information data',
    is              => 'rw',
    isa             => 'Any',
    default         => ''
) ;

has 'mime_type' => (
    documentation   => 'info mime type',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    lazy            => 1,
    default         => ''
) ;

has 'meta_infos' => (
    documentation   => 'meta info- filenames eg.',
    is              => 'rw',
    isa             => 'HashRef[Any]',
    lazy            => 1,
    default         => sub { {} },
) ;

has 'time_stamp' => (
    documentation   => 'Timestamp obtained',
    is              => 'rw',
    isa             => 'Int',
    default         => sub { time ;}
) ;

has 'cloned' => (
    documentation   => 'Timestamp this was cloned, zero for original bits',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
#
# is_mime_type - predicate to check if mime type matches
#
# in    $type, eg 'text/html'
#
# ret   true / false
#

sub is_mime_type 
    {
    my ($self, $type) = @_ ;

    my @my_type = split ';', $self -> mime_type ; 
    return $type eq $my_type[0];
    }

# -----------------------------------------------------------------------------
#
# is_encoding - predicate to check if encoding matches
#   This is the encoding the server used in the *response*, the ibite is always 
#   encoded using perls encoding.
#
# in    $encoding, eg 'utf-8'
#
# ret   true / false
#

sub is_encoding
    {
    my ($self, $encoding) = @_ ;

    my @my_type = split ';', $self -> mime_type ; 
    return $my_type[1] =~ /\Q$encoding\E/ ;
    }

# -----------------------------------------------------------------------------
#
# touch - update infobite timestamp
#
# ret   $info_bite
#

sub touch 
    {
    my ($self) = @_ ;

    $self -> time_stamp ( time ) ;
    return $self -> time_stamp ;
    }
# -----------------------------------------------------------------------------
#
# clone - create new InfoBite with same mime_type and time_stamp, but new/empty data
#
# in    [$data]     possibly new data
#
# ret   $info_bite
#

sub clone 
    {
    my ($self, $data) = @_ ;

    my $clone = $self -> copy ( ) ;
    $clone -> cloned ( time ) ; 
    $clone -> data ( $data || '' ) ; 

    return $clone ;
    }

# -----------------------------------------------------------------------------
#
# copy - create new InfoBite with same mime_type, time_stamp and data
#
# in    [$data]     possibly new data
#
# ret   $info_bite
#

sub copy 
    {
    my ($self, $data) = @_ ;

    my $copy = InfoGopher::InfoBite -> new (
        time_stamp  => $self -> time_stamp,
        mime_type   => $self -> mime_type,
        data        => $data ? $data : $self -> data  
    ) ;

    return $copy ;
    }


__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoBite - store snippets of info together with meta data

=head1 USAGE

An InfoBite is a small piece of information an InfoSource extracted from some source. It consists of
the raw data itself, a mime type, a time stamp and possibly meta information. The InfoGopher has
functionality to fetch such bites from a wide variaty of sources, transform, filter and later render 
them in whatever form is fit.

=head2 IMAP Example

Fetching InfoBites from an IMAP Server will yield one InfoBite per EMail which will contain the subject.

=head2 RSS Example

For an RSS Example, the 

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
