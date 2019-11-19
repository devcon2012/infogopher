package InfoGopher::InfoSource ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;
use Devel::StealthDebug ENABLE => $ENV{dbg_source} ;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::TextRenderer ;

use constant source_type => 'virtual_base_class' ;

# 
has 'uri' => (
    documentation   => 'Information source, eg. http://xxx.. or ...',
    is              => 'rw',
    isa             => 'Str',
    default         => ''
) ;

# set name to hostname of URI, if not yet set.
around 'uri' => sub 
    {
    my ($orig, $self, $newuri) = @_ ;
    shift; shift ;

    my ($host) =  $newuri =~ /[^:]+:..([^\/]+)/ if ( $newuri );
    #!dump($newuri, $host)!
    $self -> name ( $host ) if ($host) ;

    return $self->$orig(@_);
    };


# 
has 'name' => (
    documentation   => 'Information source name (for display only)',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

# 
has 'id' => (
    documentation   => 'id from InfoGopher',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => -1 
) ;
around 'id' => sub 
    {
    my ($orig, $self, $newid) = @_ ;
    shift; shift ;

    #!dump($newid)!
    $self -> info_bites -> source_id ( $newid ) ;

    return $self->$orig(@_);
    };

has 'raw' => (
    documentation   => 'Raw data obtained',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'last_fetch' => (
    documentation   => 'Timestamp last raw data obtained',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

has 'info_bites' => (
    documentation   => 'info_bites obtained',
    is              => 'rw',
    isa             => 'InfoGopher::InfoBites',
    lazy            => 1,
    builder         => '_build_info_bites',
) ;
sub _build_info_bites
    {
    return InfoGopher::InfoBites -> new () ;
    }

# -----------------------------------------------------------------------------
# add_info_bite - factory method to add a new info bite to the list
#
# in    $data
#       $mime_type
#       $time_stamp
#       $meta
#
# ret   $bite
#
sub add_info_bite
    {
    my $self = shift ;

    return $self -> info_bites -> add_info_bite( @_ ) ;

    }


# -----------------------------------------------------------------------------
# dump_info_bites - dump into bites as text (for debugging)
#
#
sub dump_info_bites
    {
    my ( $self, $msg ) = @_ ;

    my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;

    my $n = $self -> info_bites -> count ;
    print STDERR "$msg ($n)\n";

    my $last =0 ;
    foreach ( $self -> info_bites -> all )
        {
        print STDERR $renderer -> process ($_) . "\n" ;
        my $meta = $_ -> meta_infos ;
        if ( keys %$meta )
            {
            if ( $meta == $last)
                {
                print STDERR "  META: (same)\n" ;
                }
            else
                {
                print STDERR "  META: " . Dumper ( $meta ) ;
                }
            $last = $meta ;
            }
        } 
    }

# -----------------------------------------------------------------------------
# fetch - virtual method 
#
#
sub fetch
    {
    my ( $self, $id ) = @_ ;

    die "VIRTUAL fetch in " . __PACKAGE__ . " NOT OVERLOADED" ;
    
    }

__PACKAGE__ -> meta -> make_immutable ;

1;