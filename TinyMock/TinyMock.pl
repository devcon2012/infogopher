#!/usr/bin/perl

use strict ;
use warnings ;
use FindBin ;

use lib "$FindBin::Bin/../lib/TinyMock" ;
use TinyMock ;

# -----------------------------------------------------------------------------
# Usage - display options 
#
#

sub Usage
    {
    print "Usage:\n" ;
    print "    --response   =xxx            file containing response filename\n" ;
    print "    --port       =xxx            local listening port (7773)\n" ;
    print "    --crypto     =xxx            basename for certificate/key (if TLS)\n" ;
    print "    --log        =yyy            protocol log file\n" ;
    print "    --help\n" ;
    }

TinyMock::main() ;
sub main
    {

    GetOptions(@$options) ;

    run() ;
    }

