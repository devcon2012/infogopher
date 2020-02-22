package InfoGopher::Factory ;

# see below for docu and copyright information
# tests: Factory.t - covers produce, and implicitly also all other parts of this module
#       

use 5.018001;
use strict;
use warnings;

use InfoGopher ;
use InfoGopher::InfoGradient ;
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
# _json2hashref - decode json
#
# in    $json - json infogopher config
#
# ret   %data
#
sub _json2hashref
    {
    my ($class, $json) = @_ ;

    my $data ;

    try
        {
        $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;
        }
    catch
        {
        ThrowException( $_ ) ;
        } ;

    return $data if ( 'HASH' eq ref $data ) ;

    ThrowException( 'Not a valid json config' ) ;

    }

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

    my $data = $class -> _json2hashref ( $json ) ;

    my ($gopher, $gradient) ;
    $gopher   = $class -> produce_gopher ( $data -> {infogopher} ) ;
    $gradient = $class -> produce_gradient ( $data -> {infogradient} ) 
            if ( $data -> {infogradient} ) ;

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

    if ( $gradient )
        {
        #$gradient -> resolve_names ( $gopher ) ;
        $gopher -> set_gradient ( $gradient ) ;
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

    my $gopher ;
    my $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;

    if ( $data )
        {
        $gopher = InfoGopher -> new ( %$data ) ;
        my $logfn = $data -> {logfile} ;
        if ( $logfn )
            {
            open( my $loghandle, '>>', $logfn  ) 
                or ThrowException( "cannot open log $logfn: $!") ;
            InfoGopher::Logger::handle ( 'InfoGopher::Logger', $loghandle ) ;
            } 
        }

    return $gopher ;
    }

# -----------------------------------------------------------------------------
# produce_gradient - produce an info gradient
#
# in    $json_or_hashref - (json) infogopher config
#
# ret   $gopher{}
#
sub produce_gradient
    {
    my ($class, $json) = @_ ;

    my $i = NewIntention ( 'Produce a new InfoGradient object' ) ;

    my $gradient ;
    my $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;

    if ( $data )
        {
        $gradient = InfoGopher::InfoGradient -> new ( %$data ) ;
        }

    return $gradient ;
    }

# -----------------------------------------------------------------------------
# _produce_diverse - produce a renderer/transform/filter object
#
# in    $json_or_hashref - (json) infogopher config
#
# ret   <$renderer>
#
sub _produce_diverse
    {
    my ($class, $json, $type ) = @_ ;

    my $data = ( ref $json ? $json : JSON -> new -> decode( $json ) ) ;
    my $module_name = $data -> {module} ;

    my $i = NewIntention ( "Produce a new $type $module_name" ) ;

    if ( $data )
        {
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

    return ;

    }

# -----------------------------------------------------------------------------
# produce_transform - produce a transform object
#
# in    $json_or_hashref - (json) infogopher config
#
# ret   <$transform>
#
sub produce_transform
    {
    my ($class, $json) = @_ ;

    return $class -> _produce_diverse ( $json, 'transform' ) ;
    }

# -----------------------------------------------------------------------------
# produce_renderer - produce a renderer object
#
# in    $json_or_hashref - (json) infogopher config
#
# ret   <$renderer>
#
sub produce_renderer
    {
    my ($class, $json) = @_ ;

    return $class -> _produce_diverse ( $json, 'renderer' ) ;
    }

# -----------------------------------------------------------------------------
# produce_filter - produce a filter object
#
# in    $json_or_hashref - (json) infogopher config
#
# ret   <$filter>
#
sub produce_filter
    {
    my ($class, $json) = @_ ;

    return $class -> _produce_diverse ( $json, 'filter' ) ;
    }

# -----------------------------------------------------------------------------
# _produce_source_sink - produce a single source/sink object
#
# in    $json_or_hashref - json infogopher config
#
# ret   $gopher
#
sub _produce_source_sink
    {
    my ($class, $json, $type) = @_ ;
    $type //= '????' ;

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
# produce_source - produce a single infosource object
#
# in    $json - json infogopher config
#
# ret   $gopher
#
sub produce_source
    {
    return _produce_source_sink ( @_ , 'source') ;
    }

# -----------------------------------------------------------------------------
# produce_sink - produce a single infosink object 
#
# in    $json - json infogopher config
#
# ret   $gopher
#
sub produce_sink
    {
    return _produce_source_sink ( @_ , 'sink') ;
    }
1;


__END__

=head1 NAME

InfoGopher::Factory - create an InfoGopher from json configuration

=head1 SYNOPSIS

    use InfoGopher::Factory ;

    Produce a complete InfoGopher - Sources, Sinks, Gradients, Transforms and Renderer
    my $gradient = InfoGopher::Factory -> produce ( $json_or_hashref ) ;

    Produce parts :
    my $sink        = InfoGopher::Factory -> produce ( $json_or_hashref ) ;
    my $source      = InfoGopher::Factory -> produce ( $json_or_hashref ) ;
    my $transform   = InfoGopher::Factory -> produce ( $json_or_hashref ) ;
    my $renderer    = InfoGopher::Factory -> produce ( $json_or_hashref ) ;
    my $filter      = InfoGopher::Factory -> produce ( $json_or_hashref ) ;

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
