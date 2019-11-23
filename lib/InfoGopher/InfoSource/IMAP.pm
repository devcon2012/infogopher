package InfoGopher::InfoSource::IMAP ;

# 
# IMAP: See RFC3501 - https://tools.ietf.org/html/rfc3501

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
use Devel::StealthDebug ENABLE => $ENV{dbg_imap} || $ENV{dbg_source} ;
use Data::Dumper ;

use Mail::IMAPClient ; 
use Moose ;
use Try::Tiny ;

use InfoGopher::Essentials ;

extends 'InfoGopher::HTTPSInfoSource' ;
with 'InfoGopher::InfoSource::_InfoSource' ;


has 'imap_client' => (
    documentation   => 'IMAP Client',
    is              => 'rw',
    isa             => 'Mail::IMAPClient',
    lazy            => 1,
    builder         => '_build_imap_client' ,
) ;

sub _build_imap_client
    {
    my $self = shift ;

    # dont set the host - this will autoconnect ...
    my $imap = Mail::IMAPClient -> new(
        User     => $self -> user,
        Password => $self -> pw,
        Port     => $self -> port,
        Ssl      => 1,
        Uid      => 1,
        );
    }

# -----------------------------------------------------------------------------
# fetch - get fresh subjects from imap server
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $name = $self -> name ;
    my $i = NewIntention ( "Fetch imap $name:" . $self -> uri ) ;

    my $imap = $self -> imap_client ;

    Logger("Client created") ;

    my $output ;
    try
        {
        $imap -> Server( $self -> host) ;
        Logger("Server is " . $self -> host ) ;

        $imap -> connect() 
            or die $imap->LastError ;
        Logger("Server connected" ) ;

        $imap -> Uid( 1 ) ;
        $imap -> Peek ( 1 ) ;

        $imap -> select ( 'INBOX' ) 
            or die $imap->LastError ;
        Logger ( "Inbox selected" ) ;

        my @uids = $imap -> search ('ALL')
            or die "Could not search: $@\n";

        Logger ( "Inbox contains " . (scalar @uids) . " message(s)." ) ;

        $output = $imap->fetch( @uids, 'ENVELOPE'  ) 
            or die "Could not fetch: $@\n";

        Logger ( "Fetched Envelopes" ) ;
    
        $imap -> logout() 
            or die $imap->LastError;
        Logger("Server disconnected" ) ;

        }
    catch
        {
        print STDERR Dumper($_) ;
        $imap -> logout() ;
        ThrowException($_) ;
        };

    $self -> info_bites -> clear() ;

    # copy my id to bites so consumer can later track its source
    $self -> info_bites -> source_name ( $self -> name ) ;
    $self -> info_bites -> source_id ( $self -> id ) ;

    foreach my $envelope ( @$output )
        {
        next if ( $envelope !~ /^\*/ ) ;
        $self -> info_bites -> add_info_bite ( $envelope, 'application/imap-envelope', time ) ;
        }

    }

__PACKAGE__ -> meta -> make_immutable ;

1;

=pod
(excerpt from RFC3501)

ENVELOPE
         A parenthesized list that describes the envelope structure of a
         message.  This is computed by the server by parsing the
         [RFC-2822] header into the component parts, defaulting various
         fields as necessary.

         The fields of the envelope structure are in the following
         order: date, subject, from, sender, reply-to, to, cc, bcc,
         in-reply-to, and message-id.  The date, subject, in-reply-to,
         and message-id fields are strings.  The from, sender, reply-to,
         to, cc, and bcc fields are parenthesized lists of address
         structures.

         An address structure is a parenthesized list that describes an
         electronic mail address.  The fields of an address structure
         are in the following order: personal name, [SMTP]
         at-domain-list (source route), mailbox name, and host name.

         [RFC-2822] group syntax is indicated by a special form of
         address structure in which the host name field is NIL.  If the
         mailbox name field is also NIL, this is an end of group marker
         (semi-colon in RFC 822 syntax).  If the mailbox name field is
         non-NIL, this is a start of group marker, and the mailbox name
         field holds the group name phrase.

         If the Date, Subject, In-Reply-To, and Message-ID header lines
         are absent in the [RFC-2822] header, the corresponding member
         of the envelope is NIL; if these header lines are present but
         empty the corresponding member of the envelope is the empty
         string.
=cut