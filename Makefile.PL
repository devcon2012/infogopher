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
        if ( /\.p[ml]$/ ) ;
    push @modules, $File::Find::name
        if ( /\.t$/ ) ;
    }

sub CritiqueModules
    {
    find(\&wanted, 'lib', 'bin', 'TinyMock' );

    print STDERR "Run perlcritic on each module:\n";
    
    foreach my $m (@modules)
        {
        #perprint STDERR "$m\n" ;
        system("perlcritic $m") ;
        }

    @modules = () ;
    find(\&wanted, 't' );

    print STDERR "Run perlcritic on each test:\n";
    
    foreach my $m (@modules)
        {
        #perprint STDERR "$m\n" ;
        system("perlcritic --theme tests $m") ;
        }
    
    }

WriteMakefile(
    NAME              => 'InfoGopher',
    VERSION_FROM      => 'lib/InfoGopher.pm', 
    PREREQ_PM         => {
                            'Moose' => 2, 
                            'HTTP::Daemon' => 6, 
                            'XML::Parser' => 2,
                            'HTML::Tree' => 5,
                            'JSON' => 2.9
                         }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/InfoGopher.pm', # retrieve abstract from module
    AUTHOR            => 'Klaus Ramstöck <klaus@ramstoeck.name>',
    LICENSE           => 'perl',
);

CritiqueModules() ;


print "!! Please use MOCK_HOME=" . getcwd . "/TinyMock make test !!\n" ;
