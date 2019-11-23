package InfoGopher::InfoTransform::IMAPEnvelopeParser ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::Essentials ;
use InfoGopher::InfoBites ;

# -----------------------------------------------------------------------------
# transform
#
# in    $info_bite
#
# ret   $info_bites
#
sub transform
    {
    my ( $self, $info_bite) = @_ ;

    my $mime = $info_bite -> mime_type ;

    ThrowException("wrong mime type") 
        if ( $mime !~ 'imap' ) ;

    my $ibites = InfoGopher::InfoBites -> new () ;

    # lots of todos ..
 
    return $ibites ;
    }


1 ;
=head1 USAGE

my $json = InfoGopher::InfoTransform::IMAPEnvelopeParser -> new ( ) ;

transform a IMAP Envelope into a json string with Subject, Date, Sender ...

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
