package InfoGopher::InfoBites ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Devel::StealthDebug ENABLE => $ENV{dbg_bites} || $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use Try::Tiny;
use Carp qw( longmess ) ;
use InfoGopher::InfoBites ;

has '_bites' => (
    documentation   => 'Array of info bites',
    is              => 'rw',
    isa             => 'ArrayRef[InfoGopher::InfoBite]',
    traits          => ['Array'],
    default         => sub {[]},
    handles => {
        all         => 'elements',
        add         => 'push',
        get         => 'get',
        count       => 'count',
        has_info    => 'count',
        has_no_info => 'is_empty',
        clear       => 'clear',
    },
) ;

has 'source_name' => (
    documentation   => 'InfoSource name',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => sub { '' },
) ;

has 'source_id' => (
    documentation   => 'InfoSource id in InfoGopher',
    is              => 'rw',
    isa             => 'Maybe[Int]',
    default         => sub { -1 },
) ;

# -----------------------------------------------------------------------------
# add_info_bite - factory method to add a new info bite to the list
#
# in    $data
#       $mime_type
#       $time_stamp
#
sub add_info_bite
    {
    my ( $self, $data, $mime_type, $time_stamp, $meta) = @_ ;
    #!dump($mime_type, $time_stamp)!

    $meta //= {} ;
    if ( 'HASH' ne ref $meta )
        {
        print STDERR "add_info_bite" . longmess;
        #print STDERR Dumper($data);
        #print STDERR Dumper($mime_type);
        #print STDERR Dumper($time_stamp);
        #$meta = {} ;
        exit 0 ;
        }

    my $bite = InfoGopher::InfoBite -> new ( 
            data        => $data,
            mime_type   => $mime_type,
            time_stamp  => $time_stamp,
            meta_infos  => $meta
            ) ;

    $self -> add ( $bite ) ;
    return $bite ;
    }


# create similar infobites, but without the data
sub clone
    {
    my ( $self ) = @_ ;
    #!dump($self->source_name)!

    my $new_bites = InfoGopher::InfoBites -> new
            (
            source_name => $self -> source_name ,
            source_id => $self -> source_id ,
            );

    return $new_bites ;

    }

# transform each infobite in this collection  
sub transform
    {
    my ( $self, $transformer ) = @_ ;
    #!dump($self->source_name)!
    #!dump($self->count)!
    my $transformed_bites  = $self -> clone () ;
    foreach my $ibite ( $self -> all )
        {
        my $new_bites = $transformer -> transform ($ibite) ;
        #!dump($new_bites->count)!
        $transformed_bites -> merge ( $new_bites ) ;
        }

    $self -> _bites ( $transformed_bites->_bites ) ;

    #!dump($self->count)!
    return ;
    }

# merge other infobites to this one  
sub merge
    {
    my ( $self, $infobites ) = @_ ;
    #!dump($self->source_name)!

    my $mine = $self      -> _bites ;
    my $new  = $infobites -> _bites ;

    push @$mine, @$new ;
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoBites - a collection of information fetched by an InfoSource

=head1 USAGE

InfoBites hold all the info an InfoSource collects in one successful fetch.
A transformer can then extract the bits we are interested in.

For the RSS example, the infosource gets one XML Document which a RSS2JSON
transformer can split into a list of headlines.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
