package InfoGopher::InfoBite ;

#
# Class to hold a information a InfoSource obtained  
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

# 
has 'data' => (
    documentation   => 'Information data',
    is              => 'rw',
    isa             => 'Maybe[Str]',
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

#

sub clone 
    {
    my ($self) = @_ ;

    my $clone = InfoGopher::InfoBite -> new ;
    $clone -> time_stamp ( $self -> time_stamp ) ;
    $clone -> mime_type ( $self -> mime_type ) ;

    return $clone ;
    }


__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoBite - store snippets of info together with meta data

=head1 USAGE

An InfoBite is a small piece of information an InfoSource extracted.

For the RSS Example, this would be one headline.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
