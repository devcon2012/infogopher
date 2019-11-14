package InfoGopher::InfoBites ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::InfoBites ;

has 'bites' => (
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

__PACKAGE__ -> meta -> make_immutable ;

1;

__END__

=head1 NAME

InfoGopher::InfoBites - a collection of information fetched by an InfoSource

=head1 USAGE

InfoBites hold all the info an InfoSource collects in one successful fetch.

For the RSS Example, this would be a list of all headlines.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
