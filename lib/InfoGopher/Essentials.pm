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

use Exporter 'import';
our @EXPORT = qw( ThrowException NewIntention Logger UnwindIntentionStack ) ;

sub NewIntention
    {
    my $what = shift ;
    return InfoGopher::Intention -> new( what => $what ) ;
    }

sub ThrowException
    {
    my $what = shift ;
    my $e = InfoGopher::Exception -> new ( what => $what ) ;
    die $e ;
    }

sub Logger
    {
    InfoGopher::Logger -> log ( @_ ) ;
    }

sub UnwindIntentionStack
    {
    InfoGopher::IntentionStack -> unwind( @_ ) ;
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
