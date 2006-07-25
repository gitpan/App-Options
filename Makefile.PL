
######################################################################
## File: $Id: Makefile.PL 3400 2005-01-07 13:03:36Z spadkins $
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
    'VERSION_FROM' => 'lib/App/Options.pm',
    'EXE_FILES'    => [ @programs ],
    'PREREQ_PM'    => {
        "Carp"           => 0,  # use croak() instead of die()
        "Sys::Hostname"  => 0,  # use hostname() to get hostname/host options
        "Cwd"            => 0,  # use abs_path() to turn relative to absolute directory
        "File::Spec"     => 0,  # make directory handling work cross-platform (i.e. MSWin)
        "Config"         => 0,  # find prefix directory for the installation of perl
    },
    'dist'         => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                       'ZIP'=>'/usr/bin/zip', 'ZIPFLAGS'=>'-rl'},
);

WriteMakefile(%opts);

