package InfoGopher::InfoTransform::XML_ATOM_Style ;

# Helper-Style for the ATOM XML Parser
# transforms the XML to a perl data structure which can be json'ed


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
use namespace::autoclean;

use Devel::StealthDebug ENABLE => $ENV{dbg_transform} || $ENV{dbg_source} ;

use Data::Dumper;
use Try::Tiny;

use InfoGopher::Essentials ;

sub Init 
    {
    my $expat = shift;

    $expat->{Lists} = [] ;
    $expat->{TagStack} = [] ;
    $expat->{Curlist} = $expat->{Tree} = {} ; 
    return ;
    }
 
sub Start 
    {
    my $expat   = shift;
    my $tag     = shift;

    #!dump("Open $tag")!

    my $tagx = $expat->{TagStack} ;
    my $super = $tagx->[-1] ;
    my ($super_tag, $super_list) ;
    if (ref $super)
        {
        ($super_tag, $super_list) = ($super->[0], $super->[1]); 
        }

    my ($newlist, $curlist, $target );

    if ( $tag eq 'feed' )
        {
        $expat->{Tree} = $newlist = { entries => [] } ;
        push @$tagx, [ $tag, $newlist ] ;
        $expat->{Curlist} = $newlist -> {entries} ;
        push @{$expat->{Lists}}, $expat->{Curlist} ;
        }
    elsif ( $tag eq 'author' )
        {
        $newlist = { } ;
        push @$tagx, [ $tag, $newlist ] ;
        $super_list->{author_info} = $newlist ; 
        $expat -> {Curlist} = $newlist ;
        push @{$expat->{Lists}}, $expat->{Curlist} ;
        }
    elsif ( $tag eq 'entry' )
        {
        $newlist = { } ;
        push @$tagx, [ $tag, $newlist ] ;
        push @{$super_list->{entries}}, $newlist ; 
        $expat ->{Curlist} = $newlist ;
        push @{$expat->{Lists}}, $expat->{Curlist} ;
        }
    else
        {
        push @$tagx, [ $tag, undef ] ;
        push @{$expat->{Lists}}, undef ;
        }

    if ( 0 )
        {
        my $super = $tagx->[-1] ;
        my ($super_tag, $super_list) ;
        if (ref $super)
            {
            ($super_tag, $super_list) = ($super->[0], $super->[1]); 
            }

        print STDERR "open $tag - $super_tag:\n" ;
        }
    return ;
    }
 
sub End 
    {
    my $expat = shift;
    my $tag   = shift;

    #!dump("Close $tag")!

    my $tagx = $expat->{TagStack} ;

    my $super = $tagx->[-1] ;
    my ($super_tag, $super_list) ;
    if (ref $super)
        {
        ($super_tag, $super_list) = ($super->[0], $super->[1]); 
        }

    # print STDERR "close $tag - $super_tag:" ;

    pop @$tagx; 
    $expat->{Curlist} = pop @{ $expat->{Lists} };
    #--  dump($expat->{Curlist})!

    return ;
    }
 
sub Char 
    {
    my $expat = shift;
    my $text  = shift;

    my $tagx = $expat->{TagStack} ;
    my $super = $tagx->[-1] ;
    my ($super_tag, $super_list) ;
    if (ref $super)
        {
        ($super_tag, $super_list) = ($super->[0], $super->[1]); 
        }

    return     
        if ( $super_tag eq 'feed' ) ;
    return     
        if ( $super_tag eq 'author' ) ;
    return     
        if ( $super_tag eq 'entry' ) ;

    my $tag = $super_tag ;

    #!dump("Add $text to $tag")!

    $super = $tagx->[-2] ;
    if (ref $super)
        {
        ($super_tag, $super_list) = ($super->[0], $super->[1]); 
        }
    $super_list->{$tag} //= '' ;
    $super_list->{$tag} .= $text ;

    return ;
    }
 
sub Final 
    {
    my $expat = shift;

    delete $expat->{TagStack} ;
    delete $expat->{Curlist};
    delete $expat->{Lists};
    #!dump($expat->{Tree})!
    return $expat->{Tree};
    }
 
1;

__END__

=head1 NAME

XML_ATOM_Style - Helper for XML::Parser to read atom feeds

=head1 SYNOPSIS

    my $parser = XML::Parser -> new ( Style => 'InfoGopher::InfoTransform::XML_ATOM_Style' ) ;

=head1 DESCRIPTION


=head2 EXPORT

None by default.


=head1 SEE ALSO

XML::Parser

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@ramstoeck.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
