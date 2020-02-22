package InfoGopher::InfoRenderer::Base64Renderer ;

#
# Renderer returning base64 encoded infobite data
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;
use MIME::Base64 ; 

use Moose;

extends 'InfoGopher::InfoRenderer' ;
with 'InfoGopher::InfoRenderer::_InfoRenderer' ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Methods 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# render - render one bite of info
#
# in $bite - one info bite
#
# ret $info - rendered info bite
#
sub render
    {
    my ($self, $bite) = @_ ;
    return encode_base64 ( $bite -> data ) ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;