
######################################################################
## File: $Id: Makefile.PL,v 1.7 2004/12/28 22:28:24 spadkins Exp $
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
    'VERSION'      => '0.92',
    'EXE_FILES'    => [ @programs ],
    'PREREQ_PM'    => {
        "Carp"           => 0,  # use croak() instead of die()
        "Sys::Hostname"  => 0,  # use hostname() to get hostname/host options
        "Cwd"            => 0,  # use abs_path() to turn relative to absolute directory
        "File::Spec"     => 0,  # make directory handling work cross-platform (i.e. MSWin)
    },
    'dist'         => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                      'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
);

WriteMakefile(%opts);

