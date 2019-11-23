package TinyMock::IMAP ;

#
# Not a mock yet ...

use strict ;
use warnings ;
use Moose ;

extends 'TinyMock::SimpleSSL' ;

use IO::Handle ;
use IO::File ;
use IO::Socket::SSL ;

use Data::Dumper ;
use constant timeout => 3 ;
use Symbol 'gensym' ;
use Getopt::Long ;

# 
sub _build_default_port { 993 }

sub accept_fail_msg 
    {
    return "Failed to SSL IMAP accept on " . shift -> port . "($SSL_ERROR)" ;
    }


1 ;