package InfoGopher::Essentials ;

# see below for docu and copyright information

use 5.018001;
use strict;
use warnings;

# These packages must not use Essentials ...
use InfoGopher::Exception ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;
use InfoGopher::Logger ;

use AnyEvent ;

use Exporter 'import';
our @EXPORT = qw( ThrowException NewIntention Logger UnwindIntentionStack NormalizeException ASleep) ;

use Data::Dumper ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
#
# NewIntention - push new intention on stack
#   
# in    $what   intention message for user
#

sub NewIntention
    {
    my $what = shift ;
    return InfoGopher::Intention -> new( what => $what ) ;
    }


# -----------------------------------------------------------------------------
#
# ThrowException - shortcut to create and throw an exception
#   
# in    $what  string or exception object
#

sub ThrowException
    {
    my $what = shift ;

    die NormalizeException($what) ;

    }


# -----------------------------------------------------------------------------
#
# NormalizeException - transform into an InfoGopher::Exception if not yet one
#   
# in    $what  
#

sub NormalizeException
    {
    my $what = shift ;

    return $what 
        if ( ref $what =~ /InfoGopher::Exception/ ) ;

    return InfoGopher::Exception -> new ( what => $what )
        if ( ! ref $what ) ;

    return InfoGopher::Exception -> new ( what => Dumper($what) ) ;
    }


# -----------------------------------------------------------------------------
#
# Logger - 
#   
# in    $what  logged text
#

sub Logger
    {
    return InfoGopher::Logger -> Log ( @_ ) ;
    }


# -----------------------------------------------------------------------------
#
# UnwindIntentionStack - dump intention stack in catch {}
#   
# in    $msg    info msg for dumping
#

sub UnwindIntentionStack
    {
    return InfoGopher::IntentionStack -> unwind( @_ ) ;
    }

# -----------------------------------------------------------------------------
#
# ASleep - asyncron sleep
#
#

sub ASleep
    {
    my ( $timeout ) = @_ ;
    my $s = AnyEvent -> condvar ;
    my $w = AnyEvent -> timer (after => $timeout, cb => sub { $s -> send } ) ;
    $s -> recv ;
    return ;
    }

1;


__END__

=head1 NAME

InfoGopher::Essentials - Intentions, Exceptions and Logging

=head1 SYNOPSIS

    use InfoGopher::Essentials ;

    my $intention = NewIntention ( "save the whales" ) ;
    try
        {
        Logger ("Checking fuel") ;
        ThrowException("out of diesel") ;
        }
    catch
        {
        my $e = $_ ; 
        UnwindIntentionStack($e -> what) ;
        } ;

=head2 EXPORTS

sub NewIntention ( $explaining_text ) ;

sub Logger ( $text ) ;

sub ThrowException( $what ) ;

sub UnwindIntentionStack( $what ) ;


=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
