package InfoGopher::_HTTPS ;

# see below for docu and copyright information
# tests: implicit with tests for HTTPS InfoSources
#

use strict ;
use warnings ;

use Moose::Role ; 


# overload _build_needs_credentials to require credentials
has 'needs_credentials' => (
    documentation   => 'predicate determining if this needs user/pw or ..',
    is              => 'ro',
    isa             => 'Bool',
    lazy            => 1,
    builder         => '_build_needs_credentials',
) ;
sub _build_needs_credentials
    {
    return 0;
    }

has 'cookie_jar' => (
    documentation   => 'http request cookie jar',
    is              => 'rw',
    isa             => 'Maybe[HTTP::CookieJar::LWP]',
    lazy            => 1,
    builder         => '_build_cookie_jar',
) ;
sub _build_cookie_jar
{
    my $self = shift ;
    my $jar = HTTP::CookieJar::LWP->new ;

    $self -> user_agent -> cookie_jar ( $jar ) ;

    return $jar;
}

has 'ca_store' => (
    documentation   => 'https ca store (file or path)',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => "/etc/ssl/certs"
) ;

has 'allow_untrusted' => (
    documentation   => 'allow read from untrusted sources',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

has 'login_pw' => (
    documentation   => 'password for authentication',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'login_url' => (
    documentation   => 'a url where we present credentials and receive cookies in response',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

1;


__END__

=head1 NAME

InfoGopher::_HTTPS - What is needed to extend HTTP to HTTPS

=head1 SYNOPSIS

with 'InfoGopher::_HTTP' ;
with 'InfoGopher::_HTTPS' ;

Add certificate stores and credential management used for HTTPS connections.

=head2 EXPORTS

Creates the Moose accessors for cookie_jar, ca_store, allow_untrusted and login_url 

This is a role because its used in InfoSources and InfoSinks.

Credentials are introduced here, not in _HTTP because we want to discourage 
sending credentials over unencrypted/untrusted connections.

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut

