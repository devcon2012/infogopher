package InfoGopher::InfoSource::RSS ;

# Fetch an RSS feed
# https://en.wikipedia.org/wiki/RSS

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
use namespace::autoclean ;
use Devel::StealthDebug ENABLE => $ENV{dbg_rss} || $ENV{dbg_source} ;
use Data::Dumper ;

use Moose ;
use Try::Tiny ;

use InfoGopher::Essentials ;

use InfoGopher::InfoTransform::RSS2JSON ;

extends 'InfoGopher::InfoSource::HTTPSInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;

sub _build_expected_mimetype
    {
    return 'application/rss+xml' ;
    }

# -----------------------------------------------------------------------------
# fetch - get fresh copy from RSS InfoSource
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch RSS $name:" . $self -> uri ) ;

    $self -> get_https ;

    $self -> info_bites -> clear() ;

    # copy my id to bites so consumer can later track its source
    $self -> info_bites -> source_name ( $self -> name ) ;
    $self -> info_bites -> source_id ( $self -> id ) ;

    my $newbite = $self -> add_info_bite ( 
            $self -> raw, 
            'application/rss+xml',
            time ) ;

    return ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=pod

Minimum example:

<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
 <title>RSS Title</title>
 <description>This is an example of an RSS feed</description>
 <link>http://www.example.com/main.html</link>
 <lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000 </lastBuildDate>
 <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>
 <ttl>1800</ttl>

 <item>
  <title>Example entry</title>
  <description>Here is some text containing an interesting description.</description>
  <link>http://www.example.com/blog/post/1</link>
  <guid isPermaLink="false">7bd204c6-1655-4c27-aeee-53f933c5395f</guid>
  <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>
 </item>

</channel>
</rss>
=cut
