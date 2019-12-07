package InfoGopher::InfoSource::ATOM ;

# Fetch an Atom feed
# https://en.wikipedia.org/wiki/Atom_(Web_standard)
#
# See RFC 4287 - https://tools.ietf.org/html/rfc4287
#
# InfoGopher - A framework for collection information
#
#   (c) Klaus Ramstöck klaus@ramstoeck.name 2019
#
# You can use and distribute this software under the same conditions as perl
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;
use Devel::StealthDebug ENABLE => $ENV{dbg_atom} || $ENV{dbg_source} ;
use Data::Dumper ;

use Moose ;
use Try::Tiny ;

use InfoGopher::Essentials ;

extends 'InfoGopher::HTTPSInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;


# -----------------------------------------------------------------------------
# fetch - get fresh copy from ATOM InfoSource
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch ATOM $name:" . $self -> uri ) ;

    $self -> get_https ;

    $self -> info_bites -> clear() ;

    # copy my id to bites so consumer can later track its source
    $self -> info_bites -> source_name ( $self -> name ) ;
    $self -> info_bites -> source_id ( $self -> id ) ;

    $self -> get_https ;

    my $newbite = $self -> add_info_bite ( 
            $self -> raw, 
            'application/atom+xml',
            time ) ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=pod

Minimum example:

<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <author>
    <name>Autor des Weblogs</name>
  </author>
  <title>Titel des Weblogs</title>
  <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>
  <updated>2003-12-14T10:20:09Z</updated>

  <entry>
    <title>Titel des Weblog-Eintrags</title>
    <link href="http://example.org/2003/12/13/atom-beispiel"/>
    <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
    <updated>2003-12-13T18:30:02Z</updated>
    <summary>Zusammenfassung des Weblog-Eintrags</summary>
    <content>Volltext des Weblog-Eintrags</content>
  </entry>
</feed>
=cut
