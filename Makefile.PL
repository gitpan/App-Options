
######################################################################
## File: $Id: Makefile.PL,v 1.4 2004/01/30 15:15:07 spadkins Exp $
######################################################################

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @programs = (
    "bin/prefix",
);

%opts = (
    'NAME'        => 'App-Options',
    'DISTNAME'    => 'App-Options',
    'VERSION'     => '0.63',
    'EXE_FILES'   => [ @programs ],
    'dist'        => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                      'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
);

WriteMakefile(%opts);

