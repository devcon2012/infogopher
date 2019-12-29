package InfoGopher::InfoSink::EmailReceiver ;

# InfoGopher::InfoSink describes a receiver of infobites
# see pod at the end of this file.

#
# InfoGopher - A framework for collecting information
#
#   (c) Klaus Ramstöck klaus@ramstoeck.name 2019
#
# You can use and distribute this software under the same conditions as perl
#


use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_sink} ;

use Data::Dumper;
use Moose;
use Try::Tiny;
use Mail::Mailer ;
# not used directly, but by Mail::Mailer
use Authen::SASL ;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::RawRenderer ;

extends 'InfoGopher::InfoSink' ;
with 'InfoGopher::_URI' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
has 'email_sender' => (
    documentation   => 'SMTP server used',
    is              => 'rw',
    isa             => 'Str',
    default         => 'infogopher@localhost'
) ;
has 'smtp_server' => (
    documentation   => 'SMTP server used',
    is              => 'rw',
    isa             => 'Str',
) ;
has 'smtp_user' => (
    documentation   => 'SMTP credentials: user',
    is              => 'rw',
    isa             => 'Str',
) ;
has 'smtp_pw' => (
    documentation   => 'SMTP credentials: pw',
    is              => 'rw',
    isa             => 'Str',
) ;

has 'mailer' => (
    documentation   => 'mail sender',
    is              => 'rw',
    isa             => 'Mail::Mailer',
    lazy            => 1,
    builder         => '_build_info_bites',
) ;
sub _build_mailer
    {
    my ($self) = @_ ;

    my $server = $self -> smtp_server or ThrowException(__PACKAGE__ . ' is missing smtp_server');
    my $auth   = [ $self -> smtp_user, $self -> smtp_pw ] ;
    my $method = $ENV{DEBUG_INFOGOPHER} ? 'testfile' : 'smtp' ;

    return Mail::Mailer -> new ( $method, StartTLS => 1, Server => $server, Auth => $auth ) ;
    }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
#
# push_info - virtual method to send infobites to receiver
#   
# in    [$infobites]    defaults to member infobites  
#
sub push_info
    {
    my ( $self, $infobites ) = @_ ;

    $infobites //= $self -> info_bites ;

    my ($receiver) = ( $self -> uri =~ /mailto:(.+)/ ) ; 

    my $n = $infobites -> count ;
    my $i = NewIntention ( "Send infobites $n to $receiver" ) ;

    my $mailer  = $self -> mailer ;
    my $headers =
        {
            From    => $self -> email_sender,
            To      => $receiver,
            Subject => $self -> subject,
        } ;

    $mailer -> open($headers) ;

    my $renderer = InfoGopher::InfoRenderer::RawRenderer -> new ;

    foreach ( $infobites -> all )
        { 
        print $mailer $renderer -> process( $_)  ;
        }

    $mailer -> close () ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoSink::EmailReceiver - send infobites via email


=head1 USAGE

(TODO)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
