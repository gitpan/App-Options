
#############################################################################
## $Id: Options.pm,v 1.2 2004/01/07 15:24:07 spadkins Exp $
#############################################################################

package App::Options;

use strict;

use Carp;

=head1 NAME

App::Options - combine command line options, environment vars, and option file values

=head1 SYNOPSIS

    #!/usr/local/bin/perl

    BEGIN {
        use App::Options;
        App::Options->init();  # reads into %App::options by default
    }

    print "Options:\n";
    foreach $var (sort keys %App::options) {
        printf "    %-20s => [%s]\n", $var, $App::options{$var};
    }

  or a more full-featured example...

    #!/usr/local/bin/perl

    BEGIN {
        use App::Options;
        App::Options->init(
            values => \%MyPackage::some_hash,
            options => [ "option_file", "prefix", "app", "app_path_info",
                        "perlinc", "debug_options", "import", ],
            option => {
                option_file   => "~/.app/app.conf",         # set default
                app           => "default=app;type=string", # default & type
                app_path_info => {default=>"",type=>"string"}, # as a hashref
                prefix        => "type=string;required",
                perlinc       => undef,         # no default
                debug_options => "type=integer",
                import        => "type=string",
                flush_imports => 1,
            },
            no_cmd_args => 1,
            no_env_vars => 1,
            no_option_file => 1,
            print_usage => sub { my ($values, $init_options) = @_; print "Use it right!\n"; },
        );
    }

    print "Options:\n";
    foreach $var (sort keys %MyPackage::some_hash) {
        printf "    %-20s => [%s]\n", $var, $MyPkg::my_hash{$var};
    }

=head1 DESCRIPTION

App::Options combines command-line arguments, environment variables,
option files, and program defaults to produce a hash of
option values.

All of this may be done within the BEGIN block so that the @INC variable
can be modified in time to affect "use" statements within the 
regular code.  This is particularly important to support the installation
of multiple versions of a Perl application on the same physical computer.

App::Options supports the P5EE/App-Context variant of the Perl 5 Enterprise
Environment.  See the P5EE web sites for more information.

    http://www.officevision.com/pub/p5ee
    http://p5ee.perl.org

App::Options is in its own distribution because it will be very stable
and can be installed in the default perl places on the system.
This is different than the App-Context, App-Repository, and App-Widget
distributions which are expected to evolve significantly.

A developer writing an application based on the P5EE/App-Context framework
will want to install App-Options in the default perl places.  The other
distributions will be installed in release-specific locations.

=head1 Methods

=cut

#############################################################################
# init()
#############################################################################

=head2 init()

    * Signature: App::Options->init();
    * Signature: App::Options->init(%named);
    * Signature: App::Options->init($myvalues);
    * Signature: App::Options->init($myvalues, %named);
    * Param:  $myvalues     HASH
    * Param:  values        HASH
    * Return: void
    * Throws: <none>
    * Since:  0.01

    Sample Usage: 

    BEGIN {
        use App::Options;
        App::Options->init();
    }

    ... or, to use every option available ...

    BEGIN {
        use App::Options;
        App::Options->init(
            values => \%MyPackage::options,
            options => [ "option_file", "prefix", "app", "app_path_info",
                         "perlinc", "debug_options", "import", ],
            option => {
                option_file   => "~/.app/app.conf",         # set default
                app           => "default=app;type=string", # default & type
                app_path_info => {default=>"",type=>"string"}, # as a hashref
                prefix        => "type=string;required",
                perlinc       => undef,         # no default
                debug_options => "type=int",
                import        => "type=string",
                flush_imports => 1,
            },
            no_cmd_args => 1,
            no_env_vars => 1,
            no_option_file => 1,
            print_usage => sub { my ($values, $init_options) = @_; print "Use it right!\n"; },
        );
    }

The init() method reads the command line args (@ARGV),
finds an options file, and loads it, all in a way which
can be done in a BEGIN block.  This is important to be able
to modify the @INC array so that normal "use" and "require"
statements will work with the configured @INC path.

The various named parameters of the init() method are as follows.

    values - specify a hash reference other than %App::options to
        put configuration values in.
    options - specify a limited, ordered list of options to be
        displayed when the "--help" or "-?" options are invoked
    option - specify optional additional information about any of
        the various options to the program (see below)
    no_cmd_args - do not process command line arguments
    no_env_vars - do not read environment variables
    no_option_file - do not read in the option file
    print_usage - provide an alternate print_usage() function

The additional information that can be specified about any individual
option variable is as follows.

    default - the default variable if none supplied on the command
        line, in an environment variable, or in an option file
    required - the program will not run unless a value is provided
        for this option
    type - if a value is provided, the program will not run unless
        the value matches the type ("string", "integer", "float",
        "boolean", "date", "time", "datetime", regexp).
    description - printed next to the option in the "usage" page

The init() method stores command line options and option
file values all in the global %App::options hash (unless the
"values" argument specifies another reference to a hash to use).
The special keys to this resulting hash are as follows.

    option_file - specifies the exact file name of the option file useful
       for command line usage (i.e. "app --option_file=/path/to/app.conf")
       "option_file" is automatically set with the option file that it found
       if it is not supplied at the outset as an argument.

    app - specifies the tag that will be used when searching for
       a option file. (i.e. "app --app=myapp" will search for "myapp.conf"
       before it searches for "app.conf")
       "app" is automatically set with the stem of the program file that 
       was run (or the first part of PATH_INFO) if it is not supplied at
       the outset as an argument.

    app_path_info - this is the remainder of PATH_INFO after the first
       part is taken off to make the app.

    prefix - This represents the base directory of the software
       installation (i.e. "/usr/myproduct/1.3.12").  If it is not
       set explicitly, it is detected from the following places:
          1. PREFIX environment variable
          2. the real path of the program with /bin or /cgi-bin stripped
          3. the current directory
       If it is autodetected from one of those three places, that is
       only provisional, in order to find the "option_file".  The "prefix"
       variable should be set authoritatively in the "option_file" if it
       is desired to be in the $values structure.

    perlinc - a path of directories to prepend to the @INC search path.
       This list of directories is separated by any combination of
       [,; ] characters.

    debug_options - if this is set, a variety of debug information is
       printed out during the option processing.  This helps in debugging
       which option files are being used and what the resulting variable
       values are.

    import - a list of additional option files to be processed

=cut

sub init {
    # can call as a function (&App::Options::init()) or a static method (App::Options->init())
    shift if ($#_ > -1 && $_[0] eq "App::Options");

    # can supply initial hashref to use for option values instead of global %App::options
    my $values = ($#_ > -1 && ref($_[0]) eq "HASH") ? shift : \%App::options;

    ($#_ % 2 == 1) || croak "App::Options->init(): must have an even number of vars/values for named args";
    my %init_options = @_;
    # "values" in named arg list overrides the one supplied as an initial hashref
    if (defined $init_options{values}) {
        (ref($init_options{values}) eq "HASH") || croak "App::Options->init(): 'values' arg must be a hash reference";
        $values = $init_options{values};
    }
    else {
        $init_options{values} = $values;
    }

    #################################################################
    # we do all this within a BEGIN block because we want to get an
    # option file and update @INC so that it will be used by
    # "require" and "use".
    # The global option hash (%App::options) is set from 3 sources:
    # command line options, environment variables, and option files.
    #################################################################

    #################################################################
    # 1. Read the command-line options
    # (anything starting with one or two dashes is an option var
    # i.e. --debugmode=record  -debugmode=replay
    # an option without an "=" (i.e. --help) acts as --help=1
    # Put the var/value pairs in %$values
    #################################################################
    my ($var, $value);
    if (! $init_options{no_cmd_args}) {
        while ($#ARGV >= 0 && $ARGV[0] =~ /^--?([^=-][^=]*)(=?)(.*)/) {
            $var = $1;
            $value = ($2 eq "") ? 1 : $3;
            shift @ARGV;
            $values->{$var} = $value;
        }
    }

    #################################################################
    # 2. find the app.
    #    by default this is the basename of the program
    #    in a web application, this is overridden by any existing
    #    first part of the PATH_INFO
    #################################################################
    my $app = $values->{app};
    my $app_path_info = $ENV{PATH_INFO} || "";
    $app_path_info =~ s!/+$!!;    # strip off trailing slashes ("/")
    if (!$app) {
        if ($app_path_info && $app_path_info =~ s!^/([^/]+)!!) {
            $app = $1;            # last part of PATH_INFO (without slashes)
        }
        else {
            $app = $0;            # start with the full script path
            $app =~ s!.*/!!;      # strip off leading path
            $app =~ s/\.[^.]+$//; # strip off trailing file type (i.e. ".pl")
        }
        $values->{app} = $app;
    }
    $values->{app_path_info} = $app_path_info;

    #################################################################
    # 3. find the directory the program was run from.
    #    we will use this directory to search for the
    #    option file.
    #################################################################
    my $prog_dir = $0;                   # start with the full script path
    if ($prog_dir =~ m!^/!) {            # absolute path
        # i.e. /usr/local/bin/app, /app
        $prog_dir =~ s!/[^/]+$!!;        # trim off the program name
    }
    else {                               # relative path
        # i.e. app, ./app, ../bin/app, bin/app
        $prog_dir =~ s!/?[^/]+$!!;       # trim off the program name
        $prog_dir = "." if (!$prog_dir); # if nothing left, directory is current dir
    }

    #################################################################
    # 4. guess the "prefix" directory for the entire
    #    software installation.  The program is usually in
    #    $prefix/bin or $prefix/cgi-bin.
    #################################################################
    my $prefix = $values->{prefix};  # possibly set on command line

    # it can be set in environment.
    # This is the preferred way for Registry and PerlRun webapps.
    $prefix = $ENV{PREFIX} if (!$prefix && $ENV{PREFIX});

    # Using "abs_path" gets rid of all symbolic links and gives the real path
    # to the directory in which the script runs.
    if (!$prefix) {
        use Cwd 'abs_path';
        $prefix = abs_path($prog_dir);
        $prefix =~ s!/bin$!!;
        $prefix =~ s!/cgi-bin.*$!!;
    }

    $prefix = "." if (!$prefix);   # last resort: current directory

    my ($env_var, @env_vars);
    if (! $init_options{no_option_file}) {
        #################################################################
        # 5. Define the standard places to look for an option file
        #################################################################
        my @option_file = ();
        push(@option_file, $values->{option_file}) if ($values->{option_file});
        push(@option_file, "$ENV{HOME}/.app/$app.conf") if ($ENV{HOME} && $app ne "app");
        push(@option_file, "$ENV{HOME}/.app/app.conf") if ($ENV{HOME});
        push(@option_file, "$prog_dir/$app.conf") if ($app ne "app");
        push(@option_file, "$prog_dir/app.conf");
        push(@option_file, "$prefix/etc/app/$app.conf") if ($app ne "app");
        push(@option_file, "$prefix/etc/app/app.conf");

        #################################################################
        # 6. now actually read in the file(s)
        #    we read a set of standard files, and
        #    we may continue to read in additional files if they
        #    are indicated by an "import" line
        #################################################################

        local(*App::FILE);
        my ($option_file, $exclude_section);
        my ($regexp, $expr, @expr, $exclude);
        while ($#option_file > -1) {
            $option_file = shift(@option_file);
            $exclude_section = 0;
            print STDERR "Looking for option file [$option_file]\n" if ($values->{debug_options});
            if (open(App::FILE, "< $option_file")) {
                print STDERR "Found option file [$option_file]\n" if ($values->{debug_options});
                while (<App::FILE>) {
                    chomp;
                    # for lines that are like "[regexp]" or even "[regexp] var = value"
                    # or "[regexp;var=value]" or "[regexp;var1=value1;var2=value2]"
                    if (s|^ *\[([^\[\]]*)\] *||) {
                        @expr = split(/;/,$1);
                        $regexp = undef;
                        $exclude = 0;
                        foreach $expr (@expr) {
                            if ($expr =~ /^([^=]+)=(.*)$/) {  # a variable-based condition
                                $exclude = ((defined $values->{$1} ? $values->{$1} : "") ne $2);
                            }
                            else {  # a program name regexp
                                $regexp = $expr;
                                $exclude = ($regexp ne "" && $regexp ne "ALL" && $app !~ m!^$regexp$!);
                                $exclude = (!defined $regexp && $#expr > -1 && $exclude_section) if (!$exclude);
                            }
                            last if ($exclude);
                        }
                        if ($_) {
                            # this is a single-line condition, don't change the $exclude_section flag
                            next if ($exclude);
                        }
                        else {
                            # this condition pertains to all lines after it
                            $exclude_section = $exclude;
                            next;
                        }
                    }
                    else {
                        next if ($exclude_section);
                    }
                    s/#.*$//;        # delete comments
                    s/^ +//;         # delete leading spaces
                    s/ +$//;         # delete trailing spaces
                    next if (/^$/);  # skip blank lines

                    # look for "var = value" (ignore other lines)
                    if (/^([a-zA-Z0-9_.-]+) *= *(.*)/) {  # untainting also happens
                        $var = $1;
                        $value = $2;
                        # TODO: quoting, var = " hello world "
                        # TODO: here documents, var = <<EOF
                        # only add values which have never been defined before
                        if (!defined $values->{$var}) {
                            if (! $init_options{no_env_vars}) {
                                $env_var = "APP_" . uc($var);
                                if (defined $ENV{$env_var}) {
                                    $value = $ENV{$env_var};
                                }
                            }
                            # do variable substitutions, var = ${prefix}/bin
                            $value =~ s/\$\{([a-zA-Z0-9_\.-]+)\}/(defined $values->{$1} ? $values->{$1} : "")/eg;
                            $values->{$var} = $value;    # save all in %App::options
                        }
                    }
                }
                close(App::FILE);

                if ($values->{flush_imports}) {
                    @option_file = ();  # throw out other files to look for
                    delete $values->{flush_imports};
                }
                if ($values->{import}) {
                    unshift(@option_file, split(/[,:; ]+/, $values->{import}));
                    delete $values->{import};
                }
            }
        }
    }

    #################################################################
    # 6b. convert $init_options{option} to deep hash
    #################################################################

    my (@vars, $option);
    $option = $init_options{option};

    if ($option) {
        croak "App::Options->init(): 'option' arg must be a hash reference"
            if (ref($option) ne "HASH");

        my (@args, $hash, $arg);
        foreach $var (keys %$option) {
            $value = $option->{$var};
            if (ref($value) eq "") {
                $hash = {};
                $option->{$var} = $hash;
                @args = split(/ *; */,$value);
                foreach $arg (@args) {
                    if ($arg =~ /^([^=]+)=(.*)$/) {
                        $hash->{$1} = $2;
                    }
                    elsif (! defined $hash->{default}) {
                        $hash->{default} = $arg;
                    }
                    else {
                        $hash->{$arg} = 1;
                    }
                }
            }
        }
    }

    #################################################################
    # 6c. fill in ENV vars and defaults
    #################################################################

    @vars = ();
    if ($init_options{options}) {
        croak "App::Options->init(): 'options' arg must be an array reference"
            if (ref($init_options{options}) ne "ARRAY");
        push(@vars, @{$init_options{options}});
    }

    if ($option) {
        push(@vars, (sort keys %$option));
    }

    foreach $var (@vars) {
        if (!defined $values->{$var}) {
            $value = $option ? $option->{$var}{default} : undef;
            if (! $init_options{no_env_vars}) {
                $env_var = "APP_" . uc($var);
                if (defined $ENV{$env_var}) {
                    $value = $ENV{$env_var};
                }
            }
            # do variable substitutions, var = ${prefix}/bin
            $value =~ s/\$\{([a-zA-Z0-9_\.-]+)\}/(defined $values->{$1} ? $values->{$1} : "")/eg;
            $values->{$var} = $value;    # save all in %App::options
        }
    }

    #################################################################
    # 7. establish the definitive (not inferred) $prefix
    #################################################################
    if ($values->{prefix}) {
        $prefix = $values->{prefix};
    }
    else {
        $values->{prefix} = $prefix;
    }

    #################################################################
    # 8. add "perlinc" directories to @INC, OR
    #    automatically include (if not already) the directories
    #    $PREFIX/lib/$^V and $PREFIX/lib/site_perl/$^V
    #    i.e. /usr/mycompany/lib/5.6.1 and /usr/mycompany/lib/site_perl/5.6.1
    #################################################################

    if (defined $values->{perlinc}) {    # add perlinc entries
        unshift(@INC, split(/[,; ]+/,$values->{perlinc}));
    }
    else {
        my $libdir = "$prefix/lib";
        my $libdir_found = 0;
        foreach my $incdir (@INC) {
            if ($incdir =~ /^$libdir/) {
                $libdir_found = 1;
            }
        }
        if (!$libdir_found) {
            unshift(@INC, "$libdir");
            if ($^V) {
                my $perlversion = sprintf("%vd", $^V);
                unshift(@INC, "$libdir/perl5/site_perl/$perlversion");  # site_perl goes first!
                unshift(@INC, "$libdir/perl5/$perlversion");
            }
        }
    }

    #################################################################
    # 9. print stuff out for options debugging
    #################################################################

    if ($values->{debug_options}) {
        print STDERR "%App::options (or other) =\n";
        foreach $var (sort keys %$values) {
            print STDERR "   $var = [$values->{$var}]\n";
        }
        print STDERR "\@INC =\n";
        foreach $var (@INC) {
            print STDERR "   $var\n";
        }
    }

    #################################################################
    # 10. perform validations, print help, and exit
    #################################################################

    my $exit_status = -1;
    if ($values->{"?"} || $values->{help}) {
        $exit_status = 0;
    }

    my ($type);
    if ($option) {
        @vars = (sort keys %$option);
        foreach $var (@vars) {
            $type = $option->{$var}{type};
            next if (!$type);  # nothing to validate against
            $value = $values->{$var};
            next if (! defined $value);
            if ($type eq "integer") {
                if ($value !~ /^-?[0-9]+$/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must be of type \"$type\" (not \"$value\")\n";
                }
            }
            elsif ($type eq "float") {
                if ($value !~ /^-?[0-9]+\.?[0-9]*([eE][+-]?[0-9]+)?$/ &&
                    $value !~ /^-?[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?$/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must be of type \"$type\" (not \"$value\")\n";
                }
            }
            elsif ($type eq "string") {
                # anything is OK
            }
            elsif ($type eq "boolean") {
                if ($value !~ /^[01]$/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must be of type \"$type\" (\"0\" or \"1\") (not \"$value\")\n";
                }
            }
            elsif ($type eq "date") {
                if ($value !~ /^[0-9]{4}-[01][0-9]-[0-3][0-9]$/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must be of type \"$type\" (format \"YYYY-MM-DD\") (not \"$value\")\n";
                }
            }
            elsif ($type eq "datetime") {
                if ($value !~ /^[0-9]{4}-[01][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must be of type \"$type\" (format \"YYYY-MM-DD HH:MM::SS\") (not \"$value\")\n";
                }
            }
            elsif ($type eq "time") {
                if ($value !~ /^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must be of type \"$type\" (format \"HH:MM::SS\") (not \"$value\")\n";
                }
            }
            else {
                if ($value !~ /$type/) {
                    $exit_status = 1;
                    print "Error: \"$var\" must match \"$type\" (not \"$value\")\n";
                }
            }
        }
        foreach $var (@vars) {
            next if (!$option->{$var}{required} || defined $values->{$var});
            $exit_status = 1;
            print "Error: \"$var\" is a required option but is not defined\n";
        }
    }

    if ($exit_status >= 0) {
        if ($init_options{print_usage}) {
            &{$init_options{print_usage}}($values, \%init_options);
        }
        else {
            App::Options->print_usage($values, \%init_options);
        }
        exit($exit_status);
    }
}

sub print_usage {
    shift if ($#_ > -1 && $_[0] eq "App::Options");
    my ($values, $init_options) = @_;
    print STDERR "Usage: $0 [options]\n";
    printf STDERR "       --%-32s print this message (also -?)\n", "help";
    my (@vars);
    if ($init_options->{options}) {
        @vars = @{$init_options->{options}};
    }
    elsif ($init_options->{option}) {
        @vars = (sort keys %{$init_options->{option}});
    }
    else {
        @vars = (sort keys %$values);
    }
    my ($var, $value, $type, $desc, $option);
    my ($var_str, $value_str, $type_str, $desc_str);
    $option = $init_options->{option} || {};
    foreach $var (@vars) {
        next if ($var eq "?" || $var eq "help");
        $value = $values->{$var};
        $type  = $option->{$var}{type} || "";
        $desc  = $option->{$var}{description} || "";
        $var_str   = ($type eq "boolean") ? $var : ($type ? "$var=<$type>" : "$var=<$var>");
        $value_str = (defined $value) ? $value : "undef";
        $type_str  = ($type) ? " ($type)" : "";
        $desc_str  = ($desc) ? " $desc"   : "";
        printf STDERR "       --%-32s [%s]$type_str$desc_str\n", $var_str, $value_str;
    }
}

=head1 ACKNOWLEDGEMENTS

 * Author:  Stephen Adkins <stephen.adkins@officevision.com>
 * License: This is free software. It is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;

