package InfoGopher::InfoTransform::XML_RSS_Style ;

# Helper-Style for the RSS XML Parser
# transforms the XML to a perl data structure which can be json'ed
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
use namespace::autoclean;

use Devel::StealthDebug ENABLE => $ENV{dbg_xmlrss};

use Data::Dumper;
use Try::Tiny;

use InfoGopher ;

sub Init {
    my $expat = shift;

    $expat->{Lists} = [];
    $expat->{Curlist} = $expat->{Tree} = [];
}
 
sub Start {
    my $expat   = shift;
    my $tag     = shift;
    my $newlist = [ {@_} ];
    push @{ $expat->{Lists} }, $expat->{Curlist};
    push @{ $expat->{Curlist} }, $tag => $newlist;
    $expat->{Curlist} = $newlist;
}
 
sub End {
    my $expat = shift;
    my $tag   = shift;
    $expat->{Curlist} = pop @{ $expat->{Lists} };
}
 
sub Char {
    my $expat = shift;
    my $text  = shift;
    my $clist = $expat->{Curlist};
    my $pos   = $#$clist;
 
    if ( $pos > 0 and $clist->[ $pos - 1 ] eq '0' ) {
        $clist->[$pos] .= $text;
    }
    else {
        push @$clist, 0 => $text;
    }
}
 
sub Final {
    my $expat = shift;
    delete $expat->{Curlist};
    delete $expat->{Lists};
    $expat->{Tree};
}
 
1;

__END__

=head1 NAME

XML_RSS_Style - Helper for XML::Parser to read rss feeds

=head1 SYNOPSIS

    my $parser = XML::Parser -> new ( Style => 'InfoGopher::InfoTransform::XML_RSS_Style' ) ;

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
