
######################################################################
## File: $Id: Makefile.PL,v 1.5 2004/02/09 22:03:50 spadkins Exp $
######################################################################

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @programs = (
    "bin/prefix",
);

%opts = (
    'NAME'         => 'App-Options',
    'DISTNAME'     => 'App-Options',
    #'VERSION'      => '0.00',  # not used
    'VERSION_FROM' => 'lib/App/Options.pm',
    'EXE_FILES'    => [ @programs ],
    'dist'         => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                      'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
);

WriteMakefile(%opts);

