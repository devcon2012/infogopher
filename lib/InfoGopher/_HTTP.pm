package InfoGopher::_HTTP ;

#
#
#

use strict ;
use warnings ;

use Moose::Role ; 
 
has 'user_agent' => (
    documentation   => 'http request user agent',
    is              => 'rw',
    isa             => 'Maybe[LWP::UserAgent]',
    lazy            => 1,
    builder         => '_build_user_agent',
) ;
sub _build_user_agent
{
    my $self = shift ;
    my $ua = LWP::UserAgent -> new ;
    $ua -> agent ( "InfoGopher" ) ;
    return $ua;
}

has 'request' => (
    documentation   => 'http request',
    is              => 'rw',
    isa             => 'Maybe[HTTP::Request]',
    lazy            => 1,
    builder         => '_build_request',
) ;
sub _build_request
{
    my $self = shift ;
    my $r = HTTP::Request -> new ( GET => $self -> uri ) ;
    return $r ;
}

has 'response' => (
    documentation   => 'http response',
    is              => 'rw',
    isa             => 'Maybe[HTTP::Response]',
    default         => undef ,
) ;


1;

__END__

=head1 NAME

InfoGopher::_HTTP - What is needed to speak HTTP

=head1 SYNOPSIS

with 'InfoGopher::_HTTP' ;


=head2 EXPORTS

Creates the Moose accessors for user_agent, request and response. 
This is a role because its used in InfoSources and InfoSinks.

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
