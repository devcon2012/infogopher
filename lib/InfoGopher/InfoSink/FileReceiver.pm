package InfoGopher::InfoSink::FileReceiver ;

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

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::RawRenderer ;

extends 'InfoGopher::InfoSink' ;
#with qw( InfoGopher::_URI InfoGopher::InfoSink::_InfoSink) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'file_name' => (
    documentation   => 'target file name',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    builder         => '_build_file_name' ,
) ;
sub _build_file_name
    {
    my ( $self ) = @_ ;
    return "/tmp/INFOSINK-FILERECEIVER-$$-" . int( rand (100000) )  ;
    }

sub _build_file_handle
    {
    my ( $self ) = @_ ;
    my $fn = $self -> file_name ;
    open ( my $fh, '>', $fn ) 
        or ThrowException( "Cannot open $fn for write: $!" ) ;
    return $fh ;
    }

around 'path' => sub 
    {
    my ($orig, $self, $newid) = @_ ;
    shift; shift ;

    #!dump($newid)!
    $self -> file_name ( "$newid" ) ;

    return $self->$orig(@_) ;
    };

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

    my ($fn, $fh) = ( $self -> file_name, $self -> _build_file_handle ) ;
    my $n = $infobites -> count ;
    my $i = NewIntention ( "Send $n infobites to file $fn" ) ;

    my $renderer = $self -> renderer ;

    my $data = $renderer -> render_all ( $infobites )  ;
    print $fh $data  ;

    close ($fh) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;


=head1 NAME

InfoGopher::InfoSink::FileReceiver - save infobites to file


=head1 USAGE

(TODO)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
