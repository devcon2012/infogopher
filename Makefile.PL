#
# InfoGopher - A framework for collecting information
#
#   (c) Klaus Ramstöck klaus@ramstoeck.name 2019
#
# You can use and distribute this software under the same conditions as perl
#

use 5.018001;
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

our @manifest ;
sub UpdateManifest
    {
    push @manifest, glob '*.md' ;
    push @manifest, glob '*.pl' ;
    push @manifest, 'LICENSE' ;
    push @manifest, 'Makefile.PL' ;
    push @manifest, 'Changes' ;
    push @manifest, '.gitignore' ;
    push @manifest, 'TinyMock/.gitignore' ;


    find ( sub { push @manifest, $File::Find::name if ( /\.p[lm]$/ ) ; },
            'lib', 'TinyMock', 'bin'
            );

    find ( sub { push @manifest, $File::Find::name if ( /\.t$/ ) ; },
            't'
            );

    find ( sub { push @manifest, $File::Find::name if ( /\.crt$/ ) ; },
            'TinyMock'
            );

    find ( sub { push @manifest, $File::Find::name if ( /\.pem$/ ) ; },
            'TinyMock'
            );

    push @manifest, glob 'TinyMock/content/*' ;
    push @manifest, 'TinyMock/cryptomock.xdb' ;

    open ( my $fh, ">", "MANIFEST.new")
        or die "cannot open MANIFEST.new: $!";
    print $fh join ("\n", sort { fc($a) cmp fc($b) } @manifest);
    print $fh "\n";
    close $fh ;
    system ("echo 'MANIFEST changes:' ; diff MANIFEST MANIFEST.new") ;
    }

sub CritiqueModules
    {
    find(\&wanted, 'lib', 'bin', 'TinyMock' );

    print STDERR "Run perlcritic on each module:\n";
    
    foreach my $m (@modules)
        {
        system("perlcritic --stern $m")       # --stern ./. --gentle 
            and print STDERR "ERROR in $m\n" ;
        }

    @modules = () ;
    find(\&wanted, 't' );

    print STDERR "Run perlcritic on each test:\n";
    
    foreach my $m (@modules)
        {
        system("perlcritic --theme tests $m")
            and print STDERR "ERROR in $m\n" ;
         }
    
    }

sub PrintInfo
    {
    print "Run some tests verbose:\n" ;
    print "make test TEST_VERBOSE=1 TEST_FILES='t/testInfoBites.t'\n" ;
    print "Run one test for debugging:\n" ;
    print "make testdb TEST_FILE=t/testInfoBites.t\n" ;
    }

WriteMakefile(
    NAME              => 'InfoGopher',
    VERSION_FROM      => 'lib/InfoGopher.pm', 
    PREREQ_PM         => {
                            'Authen::SASL'          => 1,
                            'Data::Dumper'          => 2,
                            'Devel::StealthDebug'   => 1,
                            'Getopt::Long'          => 2,
                            'HTML::Tree'            => 5,
                            'HTTP::Daemon'          => 6, 
                            'HTTP::Request'         => 6, 
                            'HTTP::Status'          => 6,
                            'IO::Socket::SSL'       => 2,
                            'JSON::MaybeXS'         => 1.0,
                            'LWP'                   => 1,
                            'Mail::Mailer'          => 2.2,
                            'Mail::IMAPClient'      => 1,
                            'Moose'                 => 2, 
                            'Moose::Role'           => 1,
                            'MooseX::ClassAttribute' => 0.2,
                            'Readonly'              => 2,
                            'Try::Tiny'             => 0.28,
                            'URI'                   => 0.3,
                            'URL::Encode'           => 0.03,
                            'XML::Parser'           => 2,
                            'HTTP::CookieJar::LWP'  => 0.008
                         }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/InfoGopher.pm', # retrieve abstract from module
    AUTHOR            => 'Klaus Ramstöck <klaus@ramstoeck.name>',
    LICENSE           => 'perl',
);

CritiqueModules() ;

UpdateManifest() ;

PrintInfo() ;