
use Module::Build;

# NOTE: If anyone knows why the CPAN shell does "perl Build.PL Build",
# forcing me to put this next line (hack) in, please let me know.
#   stephen.adkins@officevision.com
shift(@ARGV) if ($#ARGV > -1 && $ARGV[0] eq "Build");

# Enable the continued use of the PREFIX=$PREFIX option
# (from Makefile.PL and ExtUtils::MakeMaker) by making it
# an alias for the "install_base" option of Module::Build.

# Also, install scripts into $PREFIX/bin, not $PREFIX/scripts.

my (@extra_args);
foreach my $arg (@ARGV) {
    if ($arg =~ s!^PREFIX=(.*)!install_base=$1!i) {
        @extra_args = (
            install_path => {bin => "$1/bin"},
        );
    }
    elsif ($arg =~ m!^install_base=(.*)!) {
        # Install scripts into $PREFIX/bin, not $PREFIX/scripts
        @extra_args = (
            install_path => {bin => "$1/bin"},
        );
    }
}

my $build = Module::Build->new (
    dist_name         => "App-Options",
    dist_version_from => "lib/App/Options.pm",
    dist_author       => "stephen.adkins@officevision.com",
    license           => "perl",
    requires => {
        "Carp"           => 0,  # use croak() instead of die()
        "Sys::Hostname"  => 0,  # use hostname() to get hostname/host options
        "Cwd"            => 0,  # use abs_path() to turn relative to absolute directory
        "File::Spec"     => 0,  # make directory handling work cross-platform (i.e. MSWin)
        "Config"         => 0,  # find prefix directory for the installation of perl
    },
    @extra_args,
);

$build->create_build_script;

