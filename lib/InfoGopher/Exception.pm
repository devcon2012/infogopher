package InfoGopher::Exception ;

# see below for docu and copyright information
# tests: see Essentials.pm
#       

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;

use Carp qw( longmess ) ;
$Carp::Internal{ (__PACKAGE__) }++;

use Moose;
with 'Throwable';

use InfoGopher::IntentionStack ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

has 'what' => (
    documentation   => 'exception error message',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    lazy            => 1,
    default         => '',
) ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub BUILD
    {
    my ( $self ) = @_ ;

    # prevent intentions being popped from stack undetected:
    InfoGopher::IntentionStack -> freeze ( 1 ) ;

    if ( ! $self -> what )
        {
        $self -> what ( "Exception without what(), stacktrace instead:" . longmess ) ;
        }
    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;
__END__

=head1 NAME

InfoGopher::Exception - InfoGopher exception object, implements Moose Throwable

=head1 SYNOPSIS

    use InfoGopher::Exception ;

    InfoGopher::Exception -> throw( what => 'killed by death' ) ;

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
