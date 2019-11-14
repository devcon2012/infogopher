#
# InfoGopher - A framework for collection information
#
#   (c) Klaus Ramstöck klaus@ramstoeck.name 2019
#
# You can use and distribute this software under the same conditions as perl
#

use 5.026001;
use ExtUtils::MakeMaker;
use File::Find ;
use Cwd ;

our @modules ;

sub wanted
    {
    push @modules, $File::Find::name
        if ( /\.pm$/ ) ;
    }

sub CritiqueModules
    {
    find(\&wanted, 'lib' );

    foreach my $m (@modules)
        {
        print STDERR "$m\n" ;
        system("perlcritic $m") ;
        }
    
    }

WriteMakefile(
    NAME              => 'InfoGopher',
    VERSION_FROM      => 'lib/InfoGopher.pm', 
    PREREQ_PM         => {
                            'Moose' => 1, 
                            'HTTP::Daemon' => 1, 
                            'XML::Parser' => 1,
                            'JSON' => 1
                         }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/InfoGopher.pm', # retrieve abstract from module
    AUTHOR            => 'Klaus Ramstöck <klaus@ramstoeck.name>',
    LICENSE           => 'perl',
);

CritiqueModules() ;


print "!! Please use MOCK_HOME=" . getcwd . "/TinyMock make test !!\n" ;
