package InfoGopher::Factory ;

# see below for docu and copyright information

use 5.018001;
use strict;
use warnings;

use InfoGopher ;
use InfoGopher::Essentials ;
use Data::Dumper ;

use Moose ;
use MooseX::ClassAttribute ; 

use JSON::MaybeXS ;

use Try::Tiny ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Members 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# produce - produce a whole infogopher from json
#
# in    $json - json infogopher config
#
# ret   $gopher
#
sub produce
    {
    my ($class, $json) = @_ ;

    my $i = NewIntention ( 'Produce a new InfoGopher from json' ) ;

    my $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;

    my $gopher = $class -> produce_gopher ( $data ) ;

    my $sources = $data -> {sources} || [] ;
    foreach my $source ( @$sources )
        {
        my $s = $class -> produce_source ( $source ) ;
        $gopher -> add_info_source( $s ) ;
        }

    my $sinks = $data -> {sinks} || [] ;
    foreach my $sink ( @$sinks )
        {
        my $s = $class -> produce_sink ( $sink ) ;
        $gopher -> add_info_sink( $s ) ;
        }

    return $gopher ;
    }

# -----------------------------------------------------------------------------
# produce_gopher - produce a single gopher object
#
# in    $json_or_hashref - (json) infogopher config
#
# ret   $gopher{}
#
sub produce_gopher
    {
    my ($class, $json) = @_ ;

    my $i = NewIntention ( 'Produce a new InfoGopher object' ) ;

    my $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;

    my $gopher = InfoGopher -> new ;
    my $logfn = $data -> {logfile} ;
    if ( $logfn )
        {
        open( my $loghandle, '>>', $logfn  ) 
            or ThrowException( "cannot open log $logfn: $!") ;
        InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
        } 

    return $gopher ;
    }

# -----------------------------------------------------------------------------
# produce_source - produce a single infosource object
#
# in    $json_or_hashref - json infogopher config
#
# ret   $gopher
#
sub produce_source
    {
    my ($class, $json, $type) = @_ ;
    $type //= 'source' ;

    my $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;

    my $name = $data -> {name} || '(name MISSING)' ;
    my $url  = $data -> {url} || '(url MISSING)' ;
    my $i = NewIntention ( "Produce a new $type $name ($url)" ) ;

    my $module_name = $data -> {module} ;
    my $module = eval 
        {
        eval "require $module_name" ;
        return $module_name -> new ( %$data ) ;
        } ;

    if ( $@ )
        {
        ThrowException ( $@ ) ;
        }

    return $module ;
    }

# -----------------------------------------------------------------------------
# produce_sink - produce a single infosink object (same as produce_source for now)
#
# in    $json - json infogopher config
#
# ret   $gopher
#
sub produce_sink
    {
    produce_source ( @_ , 'sink') ;
    }
1;


__END__

=head1 NAME

InfoGopher::Factory

=head1 SYNOPSIS

    use InfoGopher::Factory ;

    my $gopher = InfoGopher::Factory -> produce ( $json ) ;

=head2 EXPORTS

sub produce ( $json ) ;

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
