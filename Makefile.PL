
######################################################################
## File: $Id: Makefile.PL,v 1.3 2004/01/19 14:51:40 spadkins Exp $
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
    'VERSION'     => '0.62',
    'EXE_FILES'   => [ @programs ],
    'dist'        => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                      'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
);

WriteMakefile(%opts);

