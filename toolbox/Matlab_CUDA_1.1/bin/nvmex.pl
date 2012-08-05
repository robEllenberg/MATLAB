#
#  Name:
#     mex/mbuild Perl script for PC only.
# 
#     mex        compilation program for MATLAB C/C++ and Fortran
#                language MEX-files
#
#     mbuild     compilation program for executable programs for
#                the MATLAB compiler.
#
#  Usage:
#     Use mex -h or mbuild -h to see usage.
#
#  Description:
#     This Perl program provides dual functionality for MEX and MBUILD.
#     The input argument '-mb' targets the routine to do MBUILD. 
#     Otherwise, it does MEX.
#     
#  Options:
#     See the 'describe' subroutine below for the MEX options.
#     See the 'describe_mb' subroutine below for the MBUILD options.
#
#  Options (undocumented):
#
#     -setup:$compiler[:$optionfile_type]
#
#           $compiler must be taken from the option file name:
#
#             <compiler>[<optionfile_type>]opts.bat  (mex)
#             <compiler>compp.bat                    (mbuild)
#
#           Currently, <optionfile_type> = 'engmat' for mex only.
#
#     -f $destination
#
#           Where to put the options file. $destination must
#           be $dir/$file where at least $dir exists and is
#           writable. It can be used only with -setup. If
#           not used the file is put in the default location:
#
#           PC: 
#           --
#
#           <UserProfile>\Application Data\MathWorks\MATLAB\R<version>
#
#           where
#
#             <UserProfile>    Is the value determined by Perl
#                              subroutine get_user_profile_dir
#
#             <version>        MATLAB Release number like 14.
#
#           UNIX/Linux/Mac: 
#           --------------
#
#          $HOME/.matlab/R<version>
#
#           where
#
#             <version>        MATLAB Release number like 14.
#
#  Option files:
#
#     mex:    $MATLAB\bin\$ARCH\mexopts\*.stp
#             $MATLAB\bin\$ARCH\mexopts\*.bat
#
#             *opts.bat        files are 'installed' by -setup.
#             *engmatopts.bat  files are arguments using -f only.
#
#     mbuild: $MATLAB\win\$ARCH\mbuildopts\*.stp
#             $MATLAB\win\$ARCH\mbuildopts\*.bat
#
#
#  Call structure:
#
#     mex.pl
#        -> mexsetup.pm
#           MEX:
#              -> mexopts/<compiler>opts.stp
#                 (compiler == msvc50 || msvc60)
#                    -> msvc_modules_installer.pm 
#              -> mexopts/<compiler>opts.bat
#                 (compiler == bcc53 || bcc54 || bcc55 || bcc55free
#                              bcc56)
#                    -> link_borland_mex.pl
#              -> mexopts/<compiler>engmatopts.bat
#
#           MBUILD:
#              -> mbuildopts/<compiler>compp.stp
#                 (compiler == msvc50 || msvc60)
#                    -> msvc_modules_installer.pm 
#              -> mbuildopts/<compiler>compp.bat
#                 (compiler == bcc54 || bcc55 || bcc55free || bcc56)
#                    -> link_borland_mex.pl
#
#
# Copyright 1984-2006 The MathWorks, Inc.
# $Revision: 1.1.6.15.2.2 $
#__________________________________________________________________________
#
#=======================================================================

sub tool_name
{
    #===================================================================
    # tool_name: Returns the tool name, i.e. mex or mbuild.
    #===================================================================
    
    if ($main::mbuild eq "yes")
    {
        "mbuild";
    }
    else
    {
        "mex";
    }
}
#=======================================================================

use File::DosGlob 'glob';
use File::Basename;
use File::Path;
use File::Spec;
use File::Copy;
use Cwd;

BEGIN
{
    #===================================================================
    # Set @INC for 5.00503 perl.
    # If perl gets upgraded, this may have to be changed.
    #===================================================================
    if ( $] < 5.00503 ) {
        die "ERROR: This script requires perl 5.00503 or higher.
You have perl $] installed on your machine and you did not set MATLAB variable,
so the correct version of perl could not be found";
    }

    $main::mbuild = scalar(grep {/^-mb$/i} @ARGV) ? 'yes' : 'no';
    $main::cmd_name = $0;

    my $isUNC = 0;
    if ( $] < 5.006001 && $main::cmd_name =~ m%^[\\/]{2}% ) {
        $isUNC = 1;
    }    
    $main::cmd_name = File::Spec->canonpath($main::cmd_name);
    if ($isUNC) {
        $main::cmd_name = "\\" . $main::cmd_name;
    }

    $main::cmd_name =~ s%\.*[^\\\.][^\\]*\\+\.\.(\\|$)%%g; # xxx\dir\..\yyy --> xxx\yyy
    $main::cmd_name = Win32::GetShortPathName($main::cmd_name);

    (my $unused, $main::script_directory) = fileparse($main::cmd_name);
    ($main::matlabroot = $main::cmd_name) =~ s%\\bin\\mex.pl$%%;

    $main::cmd_name = uc($main::cmd_name);

    push(@INC, $main::script_directory);
}
#=======================================================================

use mexsetup;
use mexutils;

require "shellwords.pl";  # Found in $MATLAB/sys/perl/win32/lib
                          # This is necessary to break up the text in
                          # the file into shell arguments. This is used
                          # to support the @<rspfile> argument.

if ( ( $ENV{'PROCESSOR_ARCHITECTURE'} eq "AMD64" ) ||
     ( $ENV{'PROCESSOR_ARCHITEW6432'} eq "AMD64" ) ) {
    if ( -f  mexCatfile($main::matlabroot, "bin", "win64", "matlab.exe") ) {
        $ARCH = "win64";
    } elsif (-f mexCatfile($main::matlabroot, "bin", "win32", "matlab.exe") ) {
        $ARCH = "win32";
    } else {
        $ARCH = "UNKNOWN";
    }
} elsif ( $ENV{'PROCESSOR_ARCHITECTURE'} eq "x86" ) {
    $ARCH = "win32";
} else {
    $ARCH = "UNKNOWN";
}

# Support command line override
if (grep /^-win32$/, @ARGV) {
    $ARCH = "win32";
}

$ENV{'ARCH'} = $ARCH;

########################################################################
#=======================================================================
# Common subroutines:
#=======================================================================
#
# compile_files:             Compile files and form list of files to
#                            link.
# compile_resource:          Compile the resource.
# do_setup:                  Do only the setup.
# emit_compile_step:         Output compile step to makefile.
# emit_delete_resource_file: Output delete resource file to makefile.
# emit_link_dependency:      Output link dependency to makefile.
# emit_linker_step:          Output linker step to makefile.
# emit_makedef:              Output makedef step to makefile.
# emit_makefile_terminator:  Output terminator for makefile.
# emit_pre_or_postlink_step: Output postlink step to makefile.
# emit_resource_compiler:    Output resource compile step to makefile.
# emit_resource_linker_step: Output resource linker step to makefile.
# expand_wildcards:          Expand possible wildcards in the arguments
#                            for perl >= 5.00503
# expire:                    Die but with cleanup.
# find_options_file:         Find the options file.
# fix_common_variables:      Fix common variables.
# fix_flag_variables:        Fix the flag variables.
# files_to_remove:           Add files to remove list.
# get_user_profile_dir       Returns UserProfile directory
# init_common:               Common initialization.
# linker_arguments:          Create response file of linker arguments or
#                            just string.               
# link_files:                Link files.
# options_file:              Get options file if not passed as an
#                            argument. Source the options file.
# parse_common_dash_args:    Parse the common dash arguments.
# parse_common_nodash_args:  Parse the common non-dash arguments.
# pre_or_postlink:           Do prelink or postlink steps based on input.
# process_overrides:         Process command line overrides.
# process_response_file:     Run shellwords on filename argument.
# rectify_path:              Check path for system directories and add
#                            them if not present.
# resource_linker:           Run resource linker.
# RunCmd:                    Run a single command.
# search_path:               Search DOS PATH environment for $binary_name
#                            argument
# set_common_variables:      Set more common variables.
# smart_quote:               Add quotes around strings with space.
# start_makefile:            Open and write the main dependency to the
#                            makefile.
# tool_name:                 Returns the tool name, i.e. mex or mbuild. This 
#                            function is defined at the top of the script since
#                            it is used in the BEGIN block.
#
#-----------------------------------------------------------------------
#
# Common variables:
#
#   perl:
#
#     FILES_TO_REMOVE
#     FILES_TO_LINK
#     FLAGS
#     LINKFLAGS
#     MAKEFILE
#
#   DOS environment:
#
#     PATH                      system path
#     MATLAB                    MATLAB root
#
#     [$ENV: get in script]
#       MEX_DEBUG               This is for debugging this script.
#
#     [$ENV: set in script]
#       LIB_NAME
#       MATLAB                  MATLAB root
#       MATLAB_BIN
#       MATLAB_EXTLIB
#       OUTDIRN
#       OUTDIR
#       RES_NAME
#       RES_PATH
#  
#=======================================================================
sub compile_files
{
    #===================================================================
    # compile_files: Compile files and form list of files to link.
    #===================================================================

    # Loop over @FILES to compile each file.  Keep files we actually
    # compile separate from the ones we don't compile but need to link.
    # This way, we can later clean up all .obj files we created.
    #
    my $file;

    for (;$file = shift(@FILES);) {
        my ($FILEDIR, $FILENAME, $FILEEXT) = fileparts($file);
        
        if ($FILEEXT =~ /($COMPILE_EXTENSION)$/i ) {
            my ($target_name, $name_arg);
            if ($NAME_OBJECT) {
                if (!$compile_only) {
                    $target_name = mexCatfile($main::temp_dir, "$FILENAME.obj");
                } else {
                    $target_name = mexCatfile($ENV{'OUTDIR'}, "$FILENAME.obj");
                }
                $name_arg = "$NAME_OBJECT " . smart_quote($target_name);
            }
            else {
                $target_name = "$FILENAME.obj";
                $name_arg = "";
            }

            my ($args) = "$ARG_FLAGS $COMPFLAGS $name_arg $FLAGS " . smart_quote($file);

            if (!$makefilename)
            {
                my $messages = RunCmd("$COMPILER $args");
 
                # Check for error; $? might not work, so also check for resulting file
                #
                if ($? != 0 || !(-e "$target_name" || $main::no_execute)) {
                    print "$messages" unless $verbose; # verbose => printed in RunCmd
                    expire("Error: Compile of '$file' failed.");
                }
                if (!$compile_only)
                {
                    push(@FILES_TO_REMOVE, "$target_name");
                }
            }
            else
            {
                emit_compile_step();
            }

            push(@FILES_TO_LINK, "$LINK_FILE " . smart_quote($target_name));
            push(@FILES_TO_LINK_BASE, smart_quote($target_name));
        }
        elsif ($FILEEXT =~ /lib$/i)
        {
            push(@FILES_TO_LINK, "$LINK_LIB " . smart_quote($file));
            push(@FILES_TO_LINK_BASE, smart_quote($file));
        }
        else
        {
            push(@FILES_TO_LINK, "$LINK_FILE " . smart_quote($file));
            push(@FILES_TO_LINK_BASE, smart_quote($file));
        }
    }
}
#=======================================================================
sub compile_resource
{
    #===================================================================
    # compile_resource: Compile the resource.
    #===================================================================

    my ($rc_line) = '';
    $rc_line .= " -DARRAY_ACCESS_INLINING" if ($inline);
    $rc_line .= " -DV5_COMPAT" if ($v5);
    
    my $rc_basename = mexCatfile($ENV{'RES_PATH'}, $ENV{'RES_NAME'});
    $rc_line .= " " . smart_quote("$rc_basename.rc");

    if (!$makefilename)
    {
        my $messages = RunCmd("$RC_COMPILER $rc_line");

        # Check for error; $? might not work, so also check for string "error"
        #
        if ($? != 0 || $messages =~ /\b(error|fatal)\b/i) {
            print "$messages" unless $verbose; # verbose => printed out in RunCmd
            expire("Error: Resource compile of '$ENV{'RES_NAME'}.rc' failed.");
        }
        push(@FILES_TO_REMOVE, "$rc_basename.res");
    }
    else
    {
        emit_resource_compiler();
    }
    
    push(@FILES_TO_LINK, smart_quote("$rc_basename.res"));
}
#=======================================================================
sub do_setup
{
    #===================================================================
    # do_setup: Do only the setup.
    #===================================================================

    my $setupFailure;
    
    if ($setup) { 
        @setup_args = ();
        # 4th arg is 0 == no automode
        $setupFailure = setup(tool_name(), $main::mexopts_directory, 
                  ['ANY'], 0, get_user_profile_dir(), \@setup_args); 
    } else {
        # 4th arg is 2 == full automode
        $setupFailure = setup(tool_name(), $main::mexopts_directory, 
            ['ANY'], 2, get_user_profile_dir(), \@setup_args);
    }
    
    if ($main::temp_dir)
    {
        rmtree($main::temp_dir);
    }
  
    if ($setupFailure) {
        exit(1);
    }

}
#=======================================================================
sub emit_compile_step
{
    #===================================================================
    # emit_compile_step: Output compile step to makefile.
    #===================================================================

    # Emit compile dependency rule
    #
    print MAKEFILE smart_quote($target_name) . " : " . smart_quote($file);
    print MAKEFILE "\n\t$COMPILER $args\n\n";
}
#=======================================================================
sub emit_delete_resource_file
{
    #===================================================================
    # emit_delete_resource_file: Output delete resource file to makefile.
    #===================================================================

    my $res_pathname = mexCatfile($ENV{'OUTDIR'},"$ENV{'RES_NAME'}.res");

    print MAKEFILE "\tif exist \"$res_pathname\" del \"$res_pathname\"\n";
}
#=======================================================================
sub emit_link_dependency
{
    #===================================================================
    # emit_link_dependency: Output link dependency to makefile.
    #===================================================================

    # Emit link dependency rule
    #
    print MAKEFILE mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.$bin_extension");
    print MAKEFILE " : @FILES_TO_LINK_BASE\n";
}
#=======================================================================
sub emit_linker_step
{
    #===================================================================
    # emit_linker_step: Output linker step to makefile.
    #===================================================================

    print MAKEFILE "\t$LINKER $ARGS\n";
}
#=======================================================================
sub emit_makedef
{
    #===================================================================
    # emit_makedef: Output makedef step to makefile.
    #===================================================================

    print MAKEFILE "\t$makedef\n";
}
#=======================================================================
sub emit_makefile_terminator
{
    #===================================================================
    # emit_makefile_terminator: Output terminator for makefile.
    #===================================================================

    print MAKEFILE "\n";
}
#=======================================================================
sub emit_pre_or_postlink_step
{
    #===================================================================
    # emit_pre_or_postlink_step: Output prelink or postlink step to makefile.
    #===================================================================
    my ($step) = @_;
    
    print MAKEFILE "\t$step\n";
}

#=======================================================================
sub emit_resource_compiler
{
    #===================================================================
    # emit_resource_compiler: Output resource compile step to makefile.
    #===================================================================

    print MAKEFILE "\t$RC_COMPILER $rc_line\n";
}
#=======================================================================
sub emit_resource_linker_step
{
    #===================================================================
    # emit_resource linker_step: Output resource linker step to makefile
    #===================================================================

    print MAKEFILE "\t$RC_LINKER $rc_line\n";
}
#=======================================================================
sub expand_wildcards
{
    #===================================================================
    # expand_wildcards: Expand possible wildcards in the arguments
    #                   for perl >= 5.00503
    #===================================================================

    if ($] >= 5.00503) {
        my (@a) = map { /\*/ ? glob($_) : $_ } @ARGV;
        if ( "@a" ne "@ARGV" ) {
            @ARGV = @a;
        }
    }
}
#=======================================================================
sub expire
{
    #===================================================================
    # expire: Issue message and exit. This is like "die" except that
    #         it cleans up intermediate files before exiting.
    #         expire("normally") exits normally (doesn't die).
    #===================================================================

    # Clean up compiled files, unless we're only compiling
    #
    unlink @FILES_TO_REMOVE;

    if ($makefilename)
    {
        close(MAKEFILE);
        if ($_[0] ne "normally")
        {
            unlink $makefilename;
        }
    }

    if ($main::temp_dir)
    {
        rmtree($main::temp_dir);
    }

    if ($ARCH eq "win32" && $foundMEXW32ExtensionConflict) {
            if ($called_from_matlab) {
                 describe("extension_wont_work_preR14sp3withHTML");
            } else {
                 describe("extension_wont_work_preR14sp3");
            }
        }


    die "\n  $main::cmd_name: $_[0]\n\n" unless ($_[0] eq "normally");
    exit(0);
}
#=======================================================================
sub find_options_file
{
    #===================================================================
    # find_options_file: Find the options file.
    #===================================================================

    # inputs:
    #
    my ($OPTFILE_NAME, $language, $no_setup) = @_;

    # outputs: ($OPTFILE_NAME,$source_dir,$sourced_msg)
    #
    my ($source_dir, $sourced_msg);

    # locals:
    #
    my ($REGISTERED_COMPILER, @JUNK);

    if (-e mexCatfile(File::Spec->curdir(), $OPTFILE_NAME))
    {
        chop($source_dir = `cd`);
    }
    elsif (-e mexCatfile(get_user_profile_dir(), $OPTFILE_NAME))
    {
        $source_dir = get_user_profile_dir();
    }
    elsif (-e mexCatfile($main::mexopts_directory, $OPTFILE_NAME))
    {
        $source_dir = "$main::mexopts_directory";
    }
    else
    {
        if (!$no_setup)
        {
            # Not a preset so create an empty setup argument list
            # 
            @setup_args = ();

            # No options file found, so try to detect the compiler
            #
            if($silent_setup)
            {
                setup(tool_name(), $main::mexopts_directory, [uc($lang)], 
                       2, get_user_profile_dir(), \@setup_args); # 2 == silent automode
            }
            else
            {
                setup(tool_name(), $main::mexopts_directory, [uc($lang)],
                      1, get_user_profile_dir(), \@setup_args); # 1 == automode
            }
        }

        if (-e mexCatfile(get_user_profile_dir(), $OPTFILE_NAME))
        {
            $source_dir = get_user_profile_dir();
        }
        else
        {
            expire("Error: No compiler options file could be found to compile source code. Please run \"" . tool_name() . " -setup\" to rectify.");
        }
    }
    $OPTFILE_NAME = mexCatfile($source_dir, $OPTFILE_NAME);
    $sourced_msg = "-> Default options filename found in $source_dir";

    ($OPTFILE_NAME, $source_dir, $sourced_msg);
}
#=======================================================================
sub fix_common_variables
{
    #===================================================================
    # fix_common_variables: Fix common variables.
    #===================================================================

    $bin_extension = $NAME_OUTPUT;
    $bin_extension =~ s/\"//g;
    $bin_extension =~ s/.*\.([^.]*)$/$1/;

    # WATCOM Compiler can't handle MATLAB installations with spaces in
    # path names.
    #
    if ($COMPILER =~ /(wpp)|(wcc)|(wcl)/ && $MATLAB =~ " ")
    {
        expire("You have installed MATLAB into a directory whose name contains spaces. " .
            "The WATCOM compiler cannot handle that. Either rename your MATLAB " .
            "directory (currently $MATLAB) or run mex -setup and select a " .
            "different compiler.");
    }

    # Decide how to optimize or debug
    #
    if (! $debug) {                                  # Normal case
        $LINKFLAGS = "$LINKFLAGS $LINKOPTIMFLAGS";
    } elsif (! $optimize) {                          # Debug; don't optimize
        $LINKFLAGS = "$LINKDEBUGFLAGS $LINKFLAGS";
    } else {                                         # Debug and optimize
        $LINKFLAGS = "$LINKDEBUGFLAGS $LINKFLAGS $LINKOPTIMFLAGS ";
    }

    # Add inlining if switch was set
    #
    $FLAGS = "$FLAGS -DARRAY_ACCESS_INLINING" if ( $inline );

    $FLAGS = "$FLAGS -DMX_COMPAT_32" if ( $v7_compat eq "yes" );
}
#=======================================================================
sub fix_flag_variables
{
    #===================================================================
    # fix_flag_variables: Fix the flag variables.
    #===================================================================

    # Based on the language we're using, possibly adjust the flags
    # 
    if ($lang eq "cpp" && $CPPCOMPFLAGS ne "")
    {
        $COMPFLAGS = $CPPCOMPFLAGS;
        $LINKFLAGS = "$LINKFLAGS $CPPLINKFLAGS";
        $DEBUGFLAGS = $CPPDEBUGFLAGS;
        $OPTIMFLAGS = $CPPOPTIMFLAGS;
    }
}
#=======================================================================
sub files_to_remove
{
    #===================================================================
    # files_to_remove: Add files to remove list.
    #===================================================================

    push(@FILES_TO_REMOVE,
         ("$ENV{'MEX_NAME'}.bak"));
}
#=======================================================================
sub get_user_profile_dir
{
    #===================================================================
    # get_user_profile_dir: Return UserProfile directory
    #===================================================================
    # UserProfile environment variable is set by NT variants of Windows
    my($userProfile) = $ENV{'UserProfile'};
    if ($userProfile eq "")
    {
        $userProfile = $ENV{'windir'};
    }

    $userProfile = mexCatdir($userProfile, "Application Data", "MathWorks", "MATLAB", "R2006b");
    
    $userProfile;
} # get_user_profile_dir
#=======================================================================
sub init_common
{
    #===================================================================
    # init_common: Common initialization.
    #===================================================================

    $ENV{'MATLAB'} = $main::matlabroot;

    expand_wildcards();

    $sourced_msg = 'none';

    $| = 1;                              # Force immediate output flushing
    open(STDERR,">&STDOUT");             # redirect stderr to stdout for matlab
    select((select(STDERR), $|=1 )[0]);  # force immediate flushing for STDERR

    # Fix the path if necessary.
    #
    rectify_path();

    # Trap case where an invalid options file is used, by checking the
    # value of the compiler.
    #
    $COMPILER = "none";
    
    # Create a temporary directory for temporary files
    if ($ENV{'TEMP'} && -d $ENV{'TEMP'} && -w $ENV{'TEMP'})
    {
        $main::temp_dir = mexCatdir($ENV{'TEMP'},
                                             tool_name() . "_" . uuidgen());
        
        mkdir($main::temp_dir, 777) or
            expire("Error: Could not create directory \"$main::temp_dir\": $!.");
    }
    else
    {
        expire("Error: The environment variable %TEMP% must contain the name " .
               "of a writable directory.");
    }
}

#=======================================================================
sub linker_arguments
{
    #===================================================================
    # linker_arguments: Create response file of linker arguments or just
    #                   string.
    #===================================================================

    # NAME_OUTPUT always goes in the list, but it may be blank (in which
    # case it's harmless to put it in).  Leaving the variable blank is
    # equivalent to assuming that the output will be named after the
    # first object file in the list.
    #

    $ARGS = '';
    if ( $ENV{'RSP_FILE_INDICATOR'} )
    {
        my $response_file;
        if ($makefilename)
        {
            $response_file = mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}_master.rsp");
        }
        else
        {
            $response_file = mexCatfile($main::temp_dir,
                                                 tool_name() . "_tmp.rsp");
        }
        open(RSPFILE, ">$response_file") || expire("Error: Can't open file '$response_file': $!");
        print RSPFILE " @FILES_TO_LINK";
        close(RSPFILE);

        $ARGS = "$NAME_OUTPUT $LINKFLAGS " .
                smart_quote("$ENV{'RSP_FILE_INDICATOR'}$response_file") .
                " $IMPLICIT_LIBS $LINKFLAGSPOST";

        if ($verbose && !$makefilename)
        {
            print "    Contents of $response_file:\n";
            print " @FILES_TO_LINK\n\n";
        }
    }
    else
    {
        $ARGS = "$NAME_OUTPUT $LINKFLAGS @FILES_TO_LINK $IMPLICIT_LIBS $LINKFLAGSPOST";
    }
}
#=======================================================================
sub link_files
{
    #===================================================================
    # link_files: Link files.
    #===================================================================

    if (!$makefilename)
    {
        my $messages = RunCmd("$LINKER $ARGS");

    # LCC doesn't pay attention to -"output dir\file" as an option
    # it puts the file into the current directory.  If that's the case
    # move the file to dir
    my $output_pathname = mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.$bin_extension");
    if (($ENV{'COMPILER'} eq "lcc") &&
        !(-e $output_pathname) &&
        (-e "$ENV{'MEX_NAME'}.$bin_extension")) {
      
        print "    Renaming $ENV{'MEX_NAME'}.$bin_extension to $output_pathname\n" if $verbose;
        rename("$ENV{'MEX_NAME'}.$bin_extension", $output_pathname) == 1 ||
            expire("Error: Rename of '$output_pathname' failed: $!");
    }

    if ($ARCH eq "win32")
    {
        my $fileWithMexext = mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.mexw32");
        my $fileWithDll = mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.dll");
        
        # Make sure that there are not two viable MEX-files in the same
        # directory with different extensions.  On win32 both MEXw32 and
        # DLL are valid.  If both are found one is renamed with the .old
        # tagged onto the end.
        
        # Create DLL, so rename MEXEXT
        if (($output_pathname eq $fileWithDll) &&
            -e $fileWithDll && -e $fileWithMexext) {
            backup_the_other_extension($fileWithMexext);
        }
        # Create MEXEXT, so rename DLL
        if (($output_pathname eq $fileWithMexext) &&
            -e $fileWithMexext && -e $fileWithDll) {
            backup_the_other_extension($fileWithDll);
            $foundMEXW32ExtensionConflict = "true";
        }
    }

        # Check for error; $? might not work, so also check for resulting file
        #
        if ($? != 0 || !(-e $output_pathname || $main::no_execute ))
        {
            print "$messages" unless $verbose; # verbose => printed in RunCmd
            expire("Error: Link of '$output_pathname' failed.");
        }

        # If we got a file, make sure there were no errors
        #
        if ($messages =~ /\b(error|fatal)\b/i) {
            print $messages unless $verbose; # verbose => printed in RunCmd
            expire("Error: Link of '$output_pathname' failed.");
        }

        if ($COMPILER =~ /bcc/ && $debug ne "yes")
        {
            push(@FILES_TO_REMOVE, mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.tds"));
        }
    }
    else
    {
        emit_linker_step();
    }
}


#=======================================================================
sub backup_the_other_extension
{
    #===================================================================
    # backup_the_other_extension: Rename the MEXEXT that is not being created.
    #===================================================================

    my ($oldFileToRename) = @_;

    rename($oldFileToRename,"$oldFileToRename.old") == 1 ||
          expire("Error: Rename of '$oldFileToRename' to '$oldFileToRename.old' failed: $!");
    print "\n  Warning: Renaming \"$oldFileToRename\" to ",
          "\"$oldFileToRename.old\" to avoid name conflicts.\n\n";

}

#=======================================================================
sub options_file
{
    #===================================================================
    # options_file: Get options file if not passed as an argument.
    #               Source the options file.
    #===================================================================

    # MATHWORKS ONLY: VCnn, BORLANDnn, etc. are MathWorks-specific
    #                 environment variables used only for internal regression
    #                 testing.  For instance, if MSVCDir is not set then we
    #                 check if a Microsoft Visual Studio compiler options
    #                 file (msvcNNopts) was specified on the command line and
    #                 the appropriate environment variable is exists.
    #
    if ( ! $ENV{'MSVCDir'} && $OPTFILE_NAME =~ /msvc\d+/) {
        # Microsoft Visual Studio Compiler option file was specified
        if ($OPTFILE_NAME =~ /msvc60/ && $ENV{'VC60'}) {
            print("Setting MSVCDir for use with MSVC 6.0 (MathWorks-only diagnostic - do not geck)\n");
            $ENV{'MSVCDir'} = mexCatdir($ENV{'VC60'}, "VC98");
        }
    } elsif ($OPTFILE_NAME =~ /bcc(\d+)free/ && $ENV{'BORLAND'.$1.'FREE'}) {
        print("Setting BORLAND for use with Borland Free $1 (MathWorks-only diagnostic - do not geck)\n");
        $ENV{'BORLAND'} = $ENV{'BORLAND'.$1.'FREE'};
    } elsif ($OPTFILE_NAME =~ /bcc(\d+)(?!free)/ && $ENV{'BORLAND'.$1}) {
        print("Setting BORLAND for use with Borland $1 (MathWorks-only diagnostic - do not geck)\n");
        $ENV{'BORLAND'} = $ENV{'BORLAND'.$1};
    } elsif ($OPTFILE_NAME =~ /openwatc(\d+)/ && $ENV{'OPENWATCOM'.$1}) {
        print("Setting WATCOM for use with Open Watcom $1 (MathWorks-only diagnostic - do not geck)\n");
        $ENV{'WATCOM'} = $ENV{'OPENWATCOM'.$1};
    } elsif ($OPTFILE_NAME =~ /wat(\d+)/ && $ENV{'WATCOM'.$1}) {
        print("Setting WATCOM for use with Watcom $1 (MathWorks-only diagnostic - do not geck)\n");
        $ENV{'WATCOM'} = $ENV{'WATCOM'.$1};
    } elsif ($OPTFILE_NAME =~ /df(\d+)/ && $ENV{'DF'.$1}) {
        print("Setting DF_ROOT for use with Digital Fortran $1 (MathWorks-only diagnostic - do not geck)\n");
        $ENV{'DF_ROOT'} = $ENV{'DF'.$1};
    } elsif ($OPTFILE_NAME =~ /cvf(\d+)/ && $ENV{'CVF'.$1}) {
        print("Setting DF_ROOT for use with Compaq Digital Fortran $1 (MathWorks-only diagnostic - do not geck)\n");
        $ENV{'DF_ROOT'} = $ENV{'CVF'.$1};
    }

    # Search and locate options file if not specified on the command
    # line.
    #
    if ($sourced_msg eq 'none') {
        ($OPTFILE_NAME, $source_dir, $sourced_msg) = find_options_file($OPTFILE_NAME, $lang, $no_setup);
    }

    # Parse the batch file. DOS batch language is too limited.
    #
    open (OPTIONSFILE, $OPTFILE_NAME) || expire("Error: Can't open file '$OPTFILE_NAME': $!");
    while ($_ = <OPTIONSFILE>) {
        chomp;
        next if (!(/^\s*set /i));     # Ignore everything but set commands
        s/^\s*set //i;                # Remove "set " command itself
        s/\s+$//;                     # Remove trailing whitespace
        s/\\$//g;                     # Remove trailing \'s
        s/\\/\\\\/g;                  # Escape all other \'s with another \
        s/%(\w+)%/'.\$ENV{'$1'}.'/g;  # Replace %VAR% with $ENV{'VAR'}
        s/%%/%/g;                     # Replace %%s with %s
        my $perlvar = '$' . $_ . "\';";
        $perlvar =~ s/=/='/;
        my $dosvar = '$ENV{'."'".$_."';";
        $dosvar =~ s/=/'}='/;
        eval($perlvar);
        eval($dosvar);
        # We need a special case for the WATCOM compiler because it
        # can't handle directories with spaces or quotes in their
        # names. So only put the quotes around the MATLAB directory
        # name if it has spaces in it.
        #
        $ML_DIR = smart_quote($MATLAB);

        # Set the special MATLAB_BIN environment variable
        #
        if ( (! $ENV{'MATLAB'} eq "") && $ENV{'MATLAB_BIN'} eq "" ) {
            $ENV{'MATLAB_BIN'} = mexCatdir($ML_DIR, "bin", $ARCH);
        }

        # Set the special MATLAB_EXTLIB environment variable
        #
        if ( (! $ENV{'MATLAB'} eq "") && $ENV{'MATLAB_EXT'} eq "" ) {
            $ENV{'MATLAB_EXTLIB'} = mexCatdir($ML_DIR, "extern", "lib", $ARCH);
        }

	# Set the special MANIFEST_RESOURCE environment variable, if
	# either DLL_MANIFEST_RESOURCE or EXE_MANIFEST_RESOURCE is set.
	#
	# I know this pollutes all platforms with Windows-specific
	# variables, but the mbuildopts files are not sophisticated 
	# enough to make any decisions, so the code has to live here.
	if ($link =~ /dll/ || $link =~ /shared/)
        {
	    if ($ENV{'DLL_MANIFEST_RESOURCE'})
            {
		$ENV{'MANIFEST_RESOURCE'} = $ENV{'DLL_MANIFEST_RESOURCE'};
	    }
	    if ($ENV{'DLL_OUTPUT_NAME'})
            {
		$ENV{'MBUILD_OUTPUT_FILE_NAME'} = $ENV{'DLL_OUTPUT_NAME'};
	    }
	}

	if ($link =~ /exe/)
        {
	    if ($ENV{'EXE_MANIFEST_RESOURCE'})
            {
		$ENV{'MANIFEST_RESOURCE'} = $ENV{'EXE_MANIFEST_RESOURCE'};
	    }
	    if ($ENV{'EXE_OUTPUT_NAME'})
            {
		$ENV{'MBUILD_OUTPUT_FILE_NAME'} = $ENV{'EXE_OUTPUT_NAME'};
	    }

	}

    }

    close(OPTIONSFILE);
    
    # Validate that the options file matches the target architecture
    if (($MW_TARGET_ARCH) && ($MW_TARGET_ARCH ne $ARCH)) {
        my $archMismatchBaseMessage = "\n" .
            "  Error: Using options file:\n" .
            "         $OPTFILE_NAME\n" .
            "         You cannot use this file with the " . uc($ARCH) . " architecture because it enables\n" .
            "         a compiler for a different architecture.\n";
        my $archMismatchFixMessage;
        if ($dashFused eq "yes") {
            $archMismatchFixMessage = 
            "         Choose a file that is compatible with the " . uc($ARCH) . " architecture."
        } else {
            $archMismatchFixMessage =
            "         Running ". tool_name() . " -setup may resolve this problem."
        }
        my $archMismatchMessage = $archMismatchBaseMessage . $archMismatchFixMessage;
        expire($archMismatchMessage);
    }
}
#=======================================================================
sub parse_common_dash_args
{
    #===================================================================
    # parse_common_dash_args: Parse the common dash arguments.
    #===================================================================

    local ($_) = @_;

    ARGTYPE: { 
      /^-c$/ && do {
          $compile_only = "yes";
          last ARGTYPE;
      };

      /^-D\S*$/ && do {
        if ($_ eq "-DV5_COMPAT") {
            expire("Please use -V5 rather than directly passing in -DV5_COMPAT.");
        } elsif ($_ eq "-DARRAY_ACCESS_INLINING") {
            expire("Please use -inline rather than directly passing in -DARRAY_ACCESS_INLINING.");
        } else {
            $_ =~ s/[=\#]/=/;
            $ARG_FLAGS = "$ARG_FLAGS $_";
            last ARGTYPE;
        }
      };

      /^-U\S*$/ && do {
          $ARG_FLAGS = "$ARG_FLAGS $_";
          last ARGTYPE;
      };

      /^-I.*$/ && do {
          $ARG_FLAGS .= " " . &smart_quote($_);
          last ARGTYPE;
      };

      # Look for libraries specified as -l<name> but continue to handle
      # -link and -lang options to mbuild correctly
      /^-l(.*)$/ && (($main::mbuild eq 'no') || (! /^-link$/ && ! /^-lang$/)) && do {
        my $lib_found = 0;
        foreach my $lib_dir (@IMPLICIT_LIB_DIRS) {
            my $win_name = mexCatfile($lib_dir, $1 . ".lib");
            my $unx_name = mexCatfile($lib_dir, "lib" . $1 . ".lib");
            if (-e $win_name) {
                $IMPLICIT_LIBS .= " " . smart_quote($win_name);
                $lib_found = 1;
                last;
            } elsif (-e $unx_name) {
                $IMPLICIT_LIBS .= " " . smart_quote($unx_name);
                $lib_found = 1;
                last;
            }
        }
        
        if (! $lib_found) {
            print "Warning: $1 specified with -l option not found on -L path\n";
        }
        last ARGTYPE;
      };

      /^-L(.*)$/ && do {
          push(@IMPLICIT_LIB_DIRS, $1);
          last ARGTYPE;
      };

      /^-f$/ && do {
        $dashFused = "yes";
        $filename = shift(@ARGV);
        if ("$setup_special" eq "yes") {
            $setup_args[2] = $filename;
            last ARGTYPE;
        }
        if (-e $filename) {
            $OPTFILE_NAME = $filename;
        } else {
            my $script_dir_filename = mexCatfile($main::mexopts_directory, $filename);
            if (-e $script_dir_filename) {
                $OPTFILE_NAME = $script_dir_filename;
            }
            else {
                expire("Error: Could not find specified options file\n    '$filename'.");
            }
        }
        $sourced_msg = '-> Options file specified on command line';
        last ARGTYPE;
      };

      # This is an undocumented feature which is subject to change
      #
      /^-silentsetup$/ && do {
          $silent_setup = "yes";
          last ARGTYPE;
      };

      /^-g$/ && do {
          $debug = "yes";
          last ARGTYPE;
      };

      /^-inline$/ && do {
          $inline = "yes";
          last ARGTYPE;
      };

      # This is an undocumented feature which is subject to change.
      #
      /^-k$/ && do {
          $makefilename = shift(@ARGV);
          last ARGTYPE;
      };

      /^-setup$/ && do {
          $setup = "yes";
          last ARGTYPE;
      };

      /^-setup:.*$/ && do {
          $setup_special = "yes";
          s/-setup://;
          @setup_args = ($f1,$f2,$f3) = split(/:/);
          if (!$f1) {
              print "\nError: No compiler specified . . .\n\n";
              exit(1);
          }
          last ARGTYPE;
      };

      # This is passed by mex.m and mbuild.m
      #
      /^-called_from_matlab$/ && do {
          $called_from_matlab = "yes";
          last ARGTYPE;
      };

      /^-output$/ && do {
          $output_flag = "yes";
          $mex_name = shift(@ARGV);
          ($link_outdir, $mex_name, $mex_ext) = &fileparts($mex_name);
          if ($mex_ext eq ".dll") {
              $mexext_was_dll = true;
          }
          $ENV{'MEX_NAME'}=$mex_name;
          last ARGTYPE;
      };

      /^-O$/ && do {
          $optimize = "yes";
          last ARGTYPE;
      };

      /^-outdir$/ && do {
        $outdir_flag = "yes";
        my $outdir = mexCanonpath(shift(@ARGV));
        $ENV{'OUTDIRN'} = $outdir;
        # Cannot use mexCatdir here, as it strips the trailing
        # backslash and the trailing backslash is needed when %OUTDIR% used in
        # mexopts files.
        $outdir = $outdir . "\\";
        $ENV{'OUTDIR'} = $outdir;
        last ARGTYPE;
      };

      /^-matlab$/ && do {
          $matlab = shift(@ARGV);
          $matlab =~ tr/"//d;
          $ENV{'MATLAB'} = Win32::GetShortPathName($matlab);
          last ARGTYPE;
      };

      /^-n$/ && do {
          $main::no_execute = 1; # global used by RunCmd
          last ARGTYPE;
      };

      # This is an undocumented feature which is subject to change
      #
      /^-no_setup$/ && do {
          $no_setup = 1;
          last ARGTYPE;
      };

      /^-win(32|64)$/ && do {
         $_ =~ s/-//;
         if ($ARCH ne $_) {
             printf("WARNING: \$ARCH ($ARCH) not set correctly [$_]\n");
         }
         last ARGTYPE;
      };

      return 0;
    }
    return 1;
}

#=======================================================================
sub parse_common_nodash_args
{
    #===================================================================
    # parse_common_nodash_args: Parse the common non-dash arguments.
    #===================================================================

    local ($_) = @_;

    ARGTYPE: {
        /^[A-Za-z0-9_]+[#=].*$/ && do {
            push(@CMD_LINE_OVERRIDES, $_);
            last ARGTYPE;
        };

      /^@(.*)$/ && do {
          @NEW_ARGS = process_response_file($1);

            # Expand possible wildcards in the arguments for
            # perl >= 5.00503
            #
            if ($] >= 5.00503) {
                my (@a) = map { /\*/ ? glob($_) : $_ } @NEW_ARGS;
                @NEW_ARGS = @a;
            }
             
            unshift(@ARGV, @NEW_ARGS);
            last ARGTYPE;
        };

        return 0;
    }
    
    return 1;
}
#=======================================================================
sub pre_or_postlink
{
    #===================================================================
    # pre_or_postlink: Do prelink or postlink steps.
    #===================================================================

    # Note that error checking is not possible; we don't get a return
    # status, and there's no way of knowing a priori what each task is
    # supposed to do.
    
    my ($step_type_string) = @_;
    
    # Call any commands that may exist  
    my @steps = split(/;/, $ENV{$step_type_string});
    my $step;
    while ($step = shift(@steps)) {
        # Skip if $step is only whitespace
        next if (!($step =~ /\S/));
        $step =~ s%/%\\%g;
        if (!$makefilename)
        {
            RunCmd($step);
        }
        else
        {
            emit_pre_or_postlink_step($step);
        }
    }

    # There can be multiple steps called, for example, POSTLINK_CMDS1,
    # POSTLINK_CMDS2, etc. (where $step_type_string is "POSTLINK_CMDS").
    # So loop through dealing with each.
    $i = 1;
    $step = $ENV{$step_type_string . $i};
    while ($step && $step =~ /\S/)
    {
        if (!$makefilename)
        {
            RunCmd($step);
        }
        else
        {
            emit_pre_or_postlink_step($step);
        }
        $i++;
        $step = $ENV{$step_type_string . $i};
    }
}
#=======================================================================
sub process_overrides
{
    #===================================================================
    # process_overrides: Process command line overrides.
    #===================================================================

    foreach my $override (@CMD_LINE_OVERRIDES)
    {
        $override =~ /^([A-Za-z0-9_]+)[#=](.*)$/;
        $lhs = $1;
        $rhs = $2;

        $rhs =~ s/\\/\\\\/g;              # Escape all other \'s with another \
        $rhs =~ s/"/\\"/g;
        $rhs =~ s/\$([A-Za-z0-9_]+)/\$ENV{'$1'}/g;  # Replace $VAR with $ENV{'VAR'}

        my $perlvar = '$' . $lhs . " = \"" . $rhs . "\";";
        my $dosvar = "\$ENV{\'" . $lhs . "\'} = \"" . $rhs . "\";";

        eval($perlvar);
        eval($dosvar);
    }
}
#=======================================================================
sub process_response_file
{
    #===================================================================
    # process_response_file: Run shellwords on filename argument.
    #===================================================================

    # inputs:
    #
    my ($filename) = @_;

    # locals:
    #
    my ($rspfile);

    open(RSPFILE, $filename) || expire("Error: Can't open response file '$filename': $!");
    while (<RSPFILE>)
    {
        $rspfile .= $_;
    }
    close(RSPFILE);

    # shellwords strips out backslashes thinking they are escape sequences.
    # In DOS we'd rather treat them as DOS path separators.
    #
    $rspfile =~ s/\\/\\\\/g;

    # return output of shellwords
    #
    shellwords($rspfile);
}
#=======================================================================
sub rectify_path
{
    #===================================================================
    # rectify_path: Check path for system directories and add them if
    #               not present.
    #===================================================================
  
    # Fix for Windows NT/2000 systemroot bug
    #
    $ENV{'PATH'} =~ s/\%systemroot\%/$ENV{'systemroot'}/ig;

    # Make sure system path is on path so perl can spawn commands.
    # If %SystemRoot% is unavailable perl may still fail in a very
    # uninformative way.
    #
    my $systemdir = $ENV{'SystemRoot'};
  
    # if we got something make sure it's on the path
    #
    if($systemdir ne "")
    {
        # system32
        my $system32dir = mexCatdir($systemdir, "system32");
        if (index(lc($ENV{'PATH'}), lc($system32dir) . ";") < 0)
        {
            # $system32dir not found on path. Add it.
            $ENV{PATH} = $system32dir . ";" . $ENV{PATH};
        }

        # Root system dir (i.e. WINNT or WINDOWS)
        if (index(lc($ENV{PATH}), lc($systemdir) . ";") < 0)
        {
            # $systemdir not found, add to path
            $ENV{PATH} = $systemdir . ";" . $ENV{PATH};
        }
    }
    else
    {
        print "Warning: %SystemRoot% environment variable is not defined.\n";
    }
}
#=======================================================================
sub resource_linker
{
    #===================================================================
    # resource_linker: Run resource linker. 
    #===================================================================

    my $rc_line = smart_quote(mexCatfile($ENV{'RES_PATH'},"$ENV{'RES_NAME'}.rc")) . " " .
    smart_quote(mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.$bin_extension"));

    $rc_line = "$rc_line -DARRAY_ACCESS_INLINING" if ($inline);
    $rc_line = "$rc_line -DV5_COMPAT" if ($v5);

    if (!$makefilename)
    {
        my $messages = RunCmd("$RC_LINKER $rc_line");

        # Check for error; $? might not work, so also check for string "error"
        #
        if ($? != 0 || $messages =~ /\b(error|fatal)\b/i) {
            print "$messages" unless $verbose; # verbose => printed in RunCmd
            expire("Error: Resource link of '$ENV{'RES_NAME'}.rc' failed.");
        }

        push(@FILES_TO_REMOVE, mexCatfile($ENV{'OUTDIR'}, "$ENV{'RES_NAME'}.res"));
    }
    else
    {
        emit_resource_linker_step();
    }
}
#=======================================================================
sub RunCmd
{
    #===================================================================
    # RunCmd: Run a single command.
    #===================================================================

    my ($cmd) = @_;
    my ($rc, $messages);
    if ( $] < 5.006001 ) {
        # Add double quotes around the entire command line.  For reasons that
        # Microsoft does not seem to have documented, enclosing the /c argument
        # to cmd.exe (which is what Perl calls to evaluate backtick expressions)
        # increases the maximum permissible line length and avoids "The input
        # line is too long." error messages from cmd.exe.
        $cmd = "\"$cmd\"";
    }

    print "\n--> $cmd\n\n" if ($verbose || $main::no_execute);
    if (! $main::no_execute)
    {
        $messages = `$cmd`;
        $rc = $?;
        print $messages if $verbose;
        $rc = $rc >> 8 if $rc;
    }
    else
    {
        $messages = "";
        $rc = 0;
    }
    wantarray ? ($messages, $rc) : $messages;
}
#=======================================================================
sub search_path
{
    #===================================================================
    # search_path: Search DOS PATH environment variable for
    #              $binary_name.  Return the directory containing the
    #              binary if found on the path, or an empty path
    #              otherwise.
    #===================================================================

    my ($binary_name) = @_;
 
    foreach my $path_entry ( split(/;/,$ENV{'PATH'}) ) {
        my $filename = mexCatfile($path_entry, $binary_name);
        print "checking existence of:  $filename\n" if $ENV{MEX_DEBUG};
        if ( -e $filename ) {
            print "search_path found: $filename\n" if $ENV{MEX_DEBUG};
            return $path_entry;
        }
    }
    '';
}
#=======================================================================
sub set_common_variables
{
    #===================================================================
    # set_common_variables: Set more common variables.
    #===================================================================

    #Only set OUTDIR env from -output if linking is happening.
    if (!$ENV{'OUTDIR'})
    {
        if (!$compile_only && $link_outdir ne "")
        {
            $ENV{'OUTDIR'} = $link_outdir;
        }
    }

    # Create a unique name for the created import library
    #
    $ENV{'LIB_NAME'} = smart_quote(mexCatfile($main::temp_dir, "templib"));

    $RC_LINKER = " ";
    $RC_COMPILER = " ";

}
#=======================================================================
sub smart_quote
{
    #===================================================================
    # smart_quote: Adds quotes (") at the beginning and end of its input
    #              if the input contains a space. The quoted string is
    #              returned as the output. If the input contains no
    #              spaces, the input is returned as the output.
    #===================================================================

    my ($str) = @_;     # input

    $str = "\"$str\"" if ($str =~ / /);
    $str;               # output
}
#=======================================================================
sub start_makefile
{
    #===================================================================
    # start_makefile: Open and write the main dependency to the makefile.
    #===================================================================

    open(MAKEFILE, ">>$makefilename")
        || expire("Error: Cannot append to file '$makefilename': $!");

    # Emit main dependency rule
    #
    print MAKEFILE "bin_target : " .
        mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.$bin_extension") . "\n\n";
}
########################################################################
#=======================================================================
# Mex only subroutines:
#=======================================================================
#
# build_ada_s_function:      Builds an Ada S-Function
# describe:                  Issues mex messages.
# fix_mex_variables:         Fix variables for mex. 
# init_mex:                  Mex specific initialization.
# parse_mex_args:            Parse all arguments including mex.
# set_mex_variables:         Set more variables for mex.
#
#-----------------------------------------------------------------------
#
# Mex variables:
#
#   Perl:
#
#     <none>
#
#   DOS environment:
#
#     <none>
#
#     [$ENV: set in script]
#       MEX_NAME                WATCH THE NAME! This is the target name
#                               for both MEX and MBUILD!
#       ENTRYPOINT              default is "mexFunction"
#
#     [$ENV: get in script]
#
#     [set in option .bat files]
#
#       [General]
#         MATLAB                [script]
#         -------
#         BORLAND               (Borland compilers only)
#         DF_ROOT               (Dec Fortran and Dec Visual Fortran)
#         VCDir                 (Dec Visual Fortran)
#         MSDevDIR              (Dec Visual Fortran)
#         DFDir                 (Dec Visual Fortran)
#         MSVCDir               (Microsoft Visual Studio only)
#                                 [MathWorks]
#         MSDevDir              (Microsoft Visual Studio only)
#         WATCOM                (WATCOM compilers only)
#         -------
#         PATH                  [DOS]
#         INCLUDE
#         LIB
#         -------
#         LCCMEX                (standalone engine or MAT programs
#                                only for lcc)
#         DevEnvDir             (Microsoft Visual Studio only)
#         PERL                  (some)
#         EDPATH                (some WATCOM compilers only)
#         -------
#
#       [Compile]
#         COMPILER              compiler name
#         COMPFLAGS             compiler flags
#         DEBUGFLAGS            debug flags
#         OPTIMFLAGS            optimization flags
#         NAME_OBJECT
#
#       [library creation]
#         PRELINK_CMDS1         (some)
#       
#       [linker]
#         LIBLOC
#         LINKER
#         LINKFLAGS
#         LINKOPTIMFLAGS
#         LINKDEBUGFLAGS        (some)
#         LINK_FILE
#         LINK_LIB
#         NAME_OUTPUT
#         RSP_FILE_INDICATOR
#
#       [resource compiler]
#         RC_COMPILER       
#         RC_LINKER
#
#       [postlink]
#         POSTLINK_CMDS		(some)			
#         POSTLINK_CMDS1	(some)
#         POSTLINK_CMDS2	(some)
#         POSTLINK_CMDS3	(some)
#=======================================================================
sub build_ada_s_function
{
    #===================================================================
    # build_ada_s_function: Builds an Ada S-Function.
    #===================================================================

    my ($ada_sfunction, $ada_include_dirs) = @_;
    $ada_sfunction = mexCanonpath($ada_sfunction);
    if ($ada_sfunction eq "") {
        expire("Error: Invalid use of -ada option");
    }

    # get the directories
    #
    my $mlroot = $main::matlabroot;
    my $cwd = mexCanonpath(getcwd());

    my $sfcn_base = $ada_sfunction;
    $sfcn_base =~ s/(.+\\)*(\w+).ad[bs]/$2/;

    my $sfcn_dir = $ada_sfunction;
    $sfcn_dir =~ s/(.*)$sfcn_base\.ad[sb]/$1/;
    if ($sfcn_dir eq "") {
        $sfcn_dir = $cwd;
    } else {
        # strip trailing backslash:
        $sfcn_dir = mexCanonpath($sfcn_dir);
    }

    my $sfcn_ads = mexCatfile($sfcn_dir, $sfcn_base . ".ads");
    my $sfcn_adb = mexCatfile($sfcn_dir, $sfcn_base . ".adb");

    # get s-function name
    #
    my $sl_ada_dir = mexCatdir($mlroot, "simulink", "ada");
    my $get_defines_path = mexCatfile($sl_ada_dir, "bin", "win32", "get_defines");
    my $sfcn_name = RunCmd("$get_defines_path $ada_sfunction 0");
    if ($? != 0) {
        print "$sfcn_name" unless $verbose;
        expire("Error: Unable to determine S-Function name - $!");
    }
    chomp($sfcn_name);

    # get s-function defines
    #
    my $sfcn_defs = RunCmd("$get_defines_path $ada_sfunction");
    if ($? != 0) {
        print "$sfcn_defs" unless $verbose;
        expire("Error: Unable to determine S-Function methods - $!");
    }
    chomp($sfcn_defs);

    # Make sure that the GNAT Ada Compiler is available.
    #
    my $gnat_check = `gnatdll -v`;
    if ($? != 0) {
        expire("Error: Unable to find the GNAT Ada compiler.  To use mex to " .
               "build Ada S-function '$ada_sfunction', you need to have the " .
               "GNAT Ada compiler (version 3.12 or higher), correctly " .
               "installed and available on the path.");
    }

    # create obj dir, and cd to it.
    #
    my $obj_dir = mexCatdir($cwd, $sfcn_base . "_ada_sfcn_win32");
    if ( !(-e $obj_dir) ) {
        mkdir($obj_dir, 777);
        if ($? != 0) {
            expire("Error: Unable to create $obj_dir -> $!");
        }
    }
    chdir($obj_dir);
    if ($? != 0) {
        expire("Error: Unable to cd to $obj_dir -> $!");
    }

    # compiler flags for gcc
    #
    my $gcc_flags = "-Wall -malign-double";
    if ($debug eq "yes") {
        $gcc_flags = $gcc_flags . " -g";
    } else {
        $gcc_flags = $gcc_flags . " -O2";
    }

    # fixup include paths, if any, specified in $ARG_FLAGS
    #
    my $args = '';
    foreach my $arg (split(' ',$ARG_FLAGS)) {
    if ($arg =~ /-I(.+)/) {
        $arg = $1;
        if ( !($arg =~ /^[a-zA-Z]:\\.*/) ) {
        $arg = mexCatdir(File::Spec->updir(), $arg);
        }
        $arg = ' -aI' . $arg;
    }
    $args .= ' ' . $arg;
    }

    # invoke gnatmake to compile the ada sources (creates .ali file)
    #
    my $sfcn_ali = $sfcn_base . ".ali";
    my $sl_ada_interface_dir = mexCatdir($sl_ada_dir, "interface");
    my $messages = RunCmd("gnatmake -q -c -aI$sl_ada_interface_dir -aI$sfcn_dir " .
                          "$ada_include_dirs $args $sfcn_adb -cargs $gcc_flags");
    if ($? != 0 || !(-e "$sfcn_ali" || $main::no_execute)) {
        print "$messages" unless $verbose;
        expire("Error: Unable to compile $sfcn_adb -> $!");
    }

    # Compile the Ada S-Function's entry point
    #
    my $sl_ada_entry = mexCatfile($sl_ada_interface_dir, "sl_ada_entry.c");
    my $ml_ext_inc_dir = mexCatdir($mlroot, "extern", "include");
    my $sl_inc_dir = mexCatdir($mlroot, "simulink", "include");
    $messages = RunCmd("gcc -I$sl_ada_dir\\interface -I$ml_ext_inc_dir " .
                       "-I$sl_inc_dir $gcc_flags -DMATLAB_MEX_FILE " .
                       "$sfcn_defs -c $sl_ada_entry");
    if ($? != 0 || !(-e "sl_ada_entry.o" || $main::no_execute)) {
        print "$messages" unless $verbose;
        expire("Error: Unable to compile $sl_ada_entry -> $!");
    }

    # invoke dlltool to build the stubs libraries.
    #
    my @stubs = ('libmx', 'libmex');
    foreach my $s (@stubs) {
        my $perlexe = $^X;
        my $def_file = mexCatfile($ml_ext_inc_dir, "$s.def");
        $messages = RunCmd("type $def_file | $perlexe -p -e \"s/LIBRARY.*//g;s/^\\s*\$//g\" > $s_tmp.def &" .
                           "dlltool -k --def $s_tmp.def --output-lib $s.lib --dllname $s.dll");
        if ( $? != 0 || !(-e "$s.lib" || $main::no_execute) ) {
            print "$messages" unless $verbose;
            expire("Error: Unable to create $s.lib : $!");
        }
    }

    # Invoke gnatdll to build MEX file (-d parameter must have .dll extension)
    #
    my $ada_dll  = $sfcn_name . ".dll";
    my $mex_file = $sfcn_name . $ENV{'MEX_EXT'};
    $messages = RunCmd("gnatdll -q -n -e " . mexCatfile($sl_ada_interface_dir, "mex.def") .
                       " -d $ada_dll $sfcn_ali sl_ada_entry.o " .
                       "-largs libmx.lib libmex.lib");
    if ( $? != 0 || !(-e $ada_dll || $main::no_execute) ) {
        print "$messages" unless $verbose;
        expire("Error: Unable to build $ada_dll - $!");
    }

    # Move and rename the resulting dll
    #
    if (!rename $ada_dll, mexCatfile($cwd, $mex_file)) {
        expire("Error: Unable to rename $ada_dll to $cwd\\$mex_file - $!");
    }
    print "---> Created Ada S-Function: $mex_file\n\n" if ($verbose);
}

#=======================================================================
sub printHelp
{
    #===================================================================
    # printHelp: Prints the help text for MEX and MBUILD.
    #===================================================================

    my $mexScriptsDir = mexCatdir($main::script_directory,"util","mex");

    if (tool_name() eq "mex") {
        my $helpTextFileName = mexCatfile($mexScriptsDir,"mexHelp.txt");
        copy($helpTextFileName,\*STDOUT);
    } else {
        my $helpTextFileName = mexCatfile($mexScriptsDir,"mbuildHelp.txt");
        copy($helpTextFileName,\*STDOUT);
    }
    print("\n");
}

#=======================================================================
sub describe
{
    #===================================================================
    # describe: Issues mex messages. This way lengthy messages do not
    #           clutter up the main body of code.
    #===================================================================

    local($_) = $_[0];

 DESCRIPTION: {
     /^usage$/ && print(<<'end_usage') && last DESCRIPTION;
    Usage:
        MEX [option1 ... optionN] sourcefile1 [... sourcefileN]
            [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]

      or (to build an Ada S-function):
        MEX [-v] [-g] -ada <sfcn>.ads

    Use the -help option for more information, or consult the MATLAB API Guide.

end_usage
     /^general_info$/ && print(<<"end_general_info") && last DESCRIPTION;
 This is mex, Copyright 1984-2005 The MathWorks, Inc.

end_general_info
     /^invalid_options_file$/ && print(<<"end_invalid_options_file") && last DESCRIPTION;
    Warning: An options file for MEX.BAT was found and sourced, but the
             value for 'COMPILER' was not set.  This could mean that the
             value is not specified within the options file, or it could
             mean that there is a syntax error within the file.

end_invalid_options_file
     /^final_options$/ && print(<<"end_final_options") && last DESCRIPTION;
$sourced_msg
----------------------------------------------------------------
->    Options file           = $OPTFILE_NAME
      MATLAB                 = $MATLAB
->    COMPILER               = $COMPILER
->    Compiler flags:
         COMPFLAGS           = $COMPFLAGS
         OPTIMFLAGS          = $OPTIMFLAGS
         DEBUGFLAGS          = $DEBUGFLAGS
         arguments           = $ARG_FLAGS
         Name switch         = $NAME_OBJECT
->    Pre-linking commands   = $PRELINK_CMDS
->    LINKER                 = $LINKER
->    Link directives:
         LINKFLAGS           = $LINKFLAGS
         LINKDEBUGFLAGS      = $LINKDEBUGFLAGS
         LINKFLAGSPOST       = $LINKFLAGSPOST
         Name directive      = $NAME_OUTPUT
         File link directive = $LINK_FILE
         Lib. link directive = $LINK_LIB
         Rsp file indicator  = $RSP_FILE_INDICATOR
->    Resource Compiler      = $RC_COMPILER
->    Resource Linker        = $RC_LINKER
----------------------------------------------------------------

end_final_options
     /^file_not_found$/ && print(<<"end_file_not_found") && last DESCRIPTION;
  $main::cmd_name:  $filename not a normal file or does not exist.

end_file_not_found
     /^meaningless_output_flag$/ && print(<<"end_meaningless_output_flag")  && last DESCRIPTION;
  Warning: -output ignored (no MEX-file is being created).

end_meaningless_output_flag

    /^compiler_not_found$/ && print(<<"end_compiler_not_found") && last DESCRIPTION;
  Could not find the compiler "$COMPILER" on the DOS path.
  Use mex -setup to configure your environment properly.

end_compiler_not_found

    /^wrong_mexext_in_output_flag$/ && print(<<"end_wrong_mexext_in_output_flag") && last DESCRIPTION;

  Warning: Output file was specified with file extension, "$mex_ext", which
           is not a proper MEX-file extension.  The proper extension for 
           this platform, "$ENV{'MEX_EXT'}", will be used instead.

end_wrong_mexext_in_output_flag

    /^outdir_missing_name_object$/ && print(<<"end_outdir_missing_name_object") && last DESCRIPTION;
  Warning: The -outdir switch requires the mex options file to define
           NAME_OBJECT. Make sure you are using the latest version of
           your compiler's mexopts file.

end_outdir_missing_name_object

    /^extension_wont_work_preR14sp3$/ && print(<<"end_extension_wont_work_preR14sp3") && last DESCRIPTION;
***************************************************************************
  Warning: The file extension of 32-bit Windows MEX-files was changed
           from ".dll" to ".mexw32" in MATLAB 7.1 (R14SP3). The generated 
           MEX-file will not be found by MATLAB versions prior to 7.1.
           Use the -output option with the ".dll" file extension to
           generate a MEX-file that can be called in previous versions.
***************************************************************************

end_extension_wont_work_preR14sp3

    /^extension_wont_work_preR14sp3withHTML$/ && print(<<"end_extension_wont_work_preR14sp3withHTML") && last DESCRIPTION;
***************************************************************************
  Warning: The file extension of 32-bit Windows MEX-files was changed
           from ".dll" to ".mexw32" in MATLAB 7.1 (R14SP3). The generated 
           MEX-file will not be found by MATLAB versions prior to 7.1.
           Use the -output option with the ".dll" file extension to
           generate a MEX-file that can be called in previous versions.
           For more information see: 
           <a href="matlab:helpview([docroot '/techdoc/rn/f26-998197.html#f26-1011282'])">MATLAB 7.1 Release Notes, New File Extension for MEX-Files on Windows</a>
***************************************************************************

end_extension_wont_work_preR14sp3withHTML

    /^fortran_cannot_change_entrypt$/ && print(<<"end_fortran_cannot_change_entrypt") && last DESCRIPTION;
  Warning: -entrypt ignored (FORTRAN entry point cannot be overridden).

end_fortran_cannot_change_entrypt


    do {
        print "Internal error: Description for $_[0] not implemented\n";
        last DESCRIPTION;
    };
 }
}
#=======================================================================
sub fix_mex_variables
{
    #===================================================================
    # fix_mex_variables: Fix variables for mex.
    #===================================================================

    if ($verbose) {
        describe("final_options");
    }

    if ($COMPILER eq "none") {
        describe("invalid_options_file");
    }

    if ($outdir_flag && $NAME_OBJECT eq "") {
        describe("outdir_missing_name_object");
    }

    # check that MATLAB is where it is expected to be
    #
    if ( ! -e mexCatfile($MATLAB, "extern", "include", "matrix.h") ) {
        expire("Error: The variable MATLAB in \"mex.bat\" was not set properly.\n" .
                "           Please modify this variable at the top of the file " .
                "\"mex.bat\".\n\n           MATLAB is currently set to $MATLAB");
    }

    # If we are checking arguments, add $MATLAB/extern/src/mwdebug.c
    # to source file list.
    #
    push(@FILES, mexCatfile($MATLAB, "extern", "src", "mwdebug.c")) if ($argcheck eq "yes");

    # Decide how to optimize or debug
    #
    if (! $debug) {                                  # Normal case
        $FLAGS = $OPTIMFLAGS;
    } elsif (! $optimize) {                          # Debug; don't optimize
        $FLAGS = $DEBUGFLAGS;
    } else {                                         # Debug and optimize
        $FLAGS = "$DEBUGFLAGS $OPTIMFLAGS";
    }

    # Include the simulink include directory if it exists
    #
    my $simulink_inc_dir = mexCatdir($ML_DIR, "simulink", "include");
    if (-e $simulink_inc_dir && !$fortran)
    {
        $FLAGS = "-I$simulink_inc_dir $FLAGS";
    }

    # Add extern/include to the path (it always exists)
    #
    my $extern_include_dir = mexCatdir($ML_DIR, "extern", "include");
    if (!$fortran)
    {
        $FLAGS = "-I$extern_include_dir $FLAGS";
    }

    # Verify that compiler binary exists
    #
    $COMPILER_DIR = search_path("$COMPILER.exe");
    if ( ! $COMPILER_DIR ) {
        describe("compiler_not_found");
        expire("Error: Unable to locate compiler.");
    }

    # If there are no files, then exit.
    #
    if (!@FILES) {
        describe("usage");
        expire("Error: No file names given.");
    }
}
#=======================================================================
sub init_mex
{
    #===================================================================
    # init_mex: Mex specific initialization.
    #===================================================================

    $main::mexopts_directory = mexCatdir($main::script_directory,
                                                     $ARCH,
                                                     "mexopts");
    $OPTFILE_NAME = "mexopts.bat";

    # Ada S-Functions:
    #
    #    mex [-v] [-g] [-aI<dir1>] ... [-aI<dirN>] -ada sfcn.ads
    #
    #
    $ada_sfunction    = "";
    $ada_include_dirs = "";

    # 32-bit compatibility mode. Default for now
    $v7_compat = "yes";

    # Should always be one of {"c", "cpp", "fortran", "all", "ada"}
    #
    $lang = "c"; 
    $link = "unspecified";
    $ENV{'ENTRYPOINT'} = "mexFunction";
    $argcheck = "no";

    $COMPILE_EXTENSION = 'c|cu|f|cc|cxx|cpp|for|f90';
}
#=======================================================================
sub parse_mex_args
{
    #===================================================================
    # parse_mex_args: Parse all mex arguments including common.
    #===================================================================

    for (;$_=shift(@ARGV);) {

        # Perl-style case construct
        ARGTYPE: {

            /^-compatibleArrayDims$/ && do {
                $v7_compat = "yes";
                last ARGTYPE;
            };

            /^-largeArrayDims$/ && do {
                $v7_compat = "no";
                last ARGTYPE;
            };

            /^[-\/](h(elp)?)|\?$/ && do {
                printHelp();
                expire("normally");
                last ARGTYPE;
    	    };

          /^-v$/ && do {
              describe("general_info");
              $verbose = "yes";
              last ARGTYPE;
          };

          if (parse_common_dash_args($_)) {
              last ARGTYPE;
          }

          /^-argcheck$/ && do {
              $ARG_FLAGS = "$ARG_FLAGS -DARGCHECK";
              $argcheck = "yes";
              last ARGTYPE;
          };

          /^-V5$/ && do {
              $v5 = "yes";
              $ARG_FLAGS = "$ARG_FLAGS -DV5_COMPAT";
              last ARGTYPE;
          };

          /^-ada$/ && do {
              if ($ada_sfunction ne "" || $#ARGV == -1) {
                  expire("Error: Invalid use of -ada option");
              }
              $ada_sfunction = shift(@ARGV);
              if ( !(-e $ada_sfunction) ) {
                  expire("Error: File '$ada_sfunction' not found");
              }
              $lang_override = "ada";
              last ARGTYPE;
          };

          /^-aI.*$/ && do {
              $ada_include_dirs .= " " . $_;
              last ARGTYPE;
          };

          /^-entrypt$/ && do {
              $ENV{'ENTRYPOINT'} = shift(@ARGV);
              if ($ENV{'ENTRYPOINT'} ne "mexFunction" &&
                  $ENV{'ENTRYPOINT'} ne "mexLibrary")
              {
                  expire("Error: -entrypt argument must be either 'mexFunction'\n  or 'mexLibrary'");
              }
              last ARGTYPE;
          };

          # Finished processing all '-' arguments. Error at this
          # point if a '-' argument.
          #
          /^-.*$/ && do {
              describe("usage");
              expire("Error: Unrecognized switch: $_.");
              last ARGTYPE;
          };

            if (parse_common_nodash_args($_)) {
                last ARGTYPE;
            }

            do {

                # Remove command double quotes (but there by mex.m)
                #
                tr/"//d;

                if (/(.*)\.dll$/)
                {
                    expire("Error: " . tool_name() . " cannot link to '$_' directly.\n" .
                            "  Instead, you must link to the file '$1.lib' which corresponds " .
                            "to '$_'.");
                }

                if (!/\.lib$/ && !-e $_) {
                    expire("Error: '$_' not found.");
                }

                # Put file in list of files to compile
                #
                push(@FILES, $_);

                # Try to determine compiler (C or C++) to use from
                # file extension.
                #
                if (/\.(cpp|cxx|cc)$/i)
                {
                    $lang = "cpp";
                }
                if (/\.(c|cu)$/i)
                {
                    $lang = "c";
                }
                if (/\.(f|for|f90)$/i)
                {
                    $lang = "fortran";
                }
                last ARGTYPE;
            }
        } # end ARGTYPE block
    } # end for loop 

    if ($lang_override) { $lang = $lang_override; }

    if ($lang eq "fortran" && $ENV{'ENTRYPOINT'} ne "mexFunction")
    {
        describe("fortran_cannot_change_entrypt");
        $ENV{'ENTRYPOINT'} = "mexFunction";
    }

    # Warn user that output target is ignored when compile only.
    #
    if ($compile_only && $output_flag) {
        describe("meaningless_output_flag");
    }
}
#=======================================================================
sub set_mex_variables
{
    #===================================================================
    # set_mex_variables: Set more variables for mex.
    #===================================================================

    # Use the 1st file argument for the target name (MEX_NAME)
    # if not set. Also set $fortran variable if correct extension.
    #
    ($derived_name, $EXTENSION) = ($FILES[0] =~ /([ \w]*)\.(\w*)$/);
    $ENV{'MEX_NAME'} = $derived_name if (!($ENV{'MEX_NAME'}));
    $fortran = "yes" if ($EXTENSION =~ /^(f|for|f90)$/i);

    if ($ARCH eq "win32")
    {
        $ENV{'MEX_EXT'} = $mexext_was_dll ? ".dll" : ".mexw32";
    }
    elsif ($ARCH eq "win64")
    {
        $ENV{'MEX_EXT'} = ".mexw64";
    }

    if (!$compile_only && 
         $mex_ext ne "" &&
         $mex_ext ne $ENV{'MEX_EXT'} &&
         !$mexext_was_dll) {
                describe("wrong_mexext_in_output_flag");
    }

    if ($RC_COMPILER =~ /\S/) {
        $ENV{'RES_PATH'} = mexCatdir($ENV{'MATLAB'}, "extern", "include") . "\\";
        $ENV{'RES_NAME'} = "mexversion";
    }
}
#=======================================================================
########################################################################
#=======================================================================
# Mbuild only subroutines:
#=======================================================================
#
# create_export_file:        Create a single exports file.
# describe_mb:               Issues mbuild messages.
# dll_makedef:               Make the exports list.
# dll_variables:             Set variables with dll options.
# fix_mbuild_variables:      Fix variables for mbuild.
# init_mbuild:               Mbuild specific initialization.
# parse_mbuild_args:         Parse all mbuild arguments including common.
# process_idl_files:         Process any idl files.
# process_java_files:        Process any java files.
# register_dll:              Register DLL with COM object system.
# set_mbuild_variables:      Set more variables for mbuild.
#
#-----------------------------------------------------------------------
#
# Mbuild variables:
#
#   Perl:
#
#     <none>
#
#   DOS environment:
#
#     <none>
#
#     [$ENV: set in script]
#       MEX_NAME                WATCH THE NAME! This is the target name
#                               for both MEX and MBUILD!
#       BASE_EXPORTS_FILE
#       DEF_FILE
#
#     [$ENV: get in script]
#
#       JAVA_DEBUG_FLAGS
#       JAVA_HOME
#       JAVA_OPTIM_FLAGS
#       JAVA_OUTPUT_DIR
#
#     [set in option .bat files]
#
#       [General]
#         MATLAB                [script]
#         -------
#         BORLAND               (Borland compilers only)
#         LCCMEX                (LCC C compiler)
#         MSVCDir               (Microsoft Visual Studio only)
#                                 [MathWorks]
#         DevEnvDir             (Microsoft Visual Studeio 7.1 only)
#                                 [MathWorks]   
#         MSDevDir              (Microsoft Visual Studio only)
#         -------
#         PATH                  [DOS]
#         INCLUDE               (some)
#         LIB                   (some)
#         -------
#         PERL
#         -------
#
#       [Compile]
#         COMPILER              compiler name
#         COMPFLAGS             compiler flags
#         CPPCOMPFLAGS          C++ executable compiler flags
#         DLLCOMPFLAGS          C++ shared library compiler flags
#         OPTIMFLAGS            optimization flags
#         DEBUGFLAGS            debug flags
#         CPPOPTIMFLAGS         C++ optimization flags
#         CPPDEBUGFLAGS         C++ DEBUG flags
#         NAME_OBJECT           
#
#       [library creation]
#         DLL_MAKEDEF
#         DLL_MAKEDEF1          (some)
#       
#       [linker]
#         LIBLOC
#         LINKER
#         LINK_LIBS             (some)
#         LINKFLAGS
#         LINKFLAGSPOST         (some)
#         CPPLINKFLAGS
#         DLLLINKFLAGS
#         LINKFLAGSPOST         (some)
#         HGLINKFLAGS           (OBSOLETE)
#         HGLINKFLAGSPOST       (OBSOLETE some)
#         LINKOPTIMFLAGS
#         LINKDEBUGFLAGS
#         LINK_FILE
#         LINK_LIB
#         NAME_OUTPUT
#         DLL_NAME_OUTPUT
#         RSP_FILE_INDICATOR
#
#       [resource compiler]
#         RC_COMPILER       
#         RC_LINKER
#
#       [IDL Compiler]
#         IDL_COMPILER          (some)
#         IDL_OUTPUTDIR         (some)
#         IDL_DEBUG_FLAGS       (some)  
#         IDL_OPTIM_FLAGS       (some)
#
#       [postlink]
#	  POSTLINK_CMDS1		
#	  POSTLINK_CMDS2	(some)
#=======================================================================
sub create_export_file
{
    #===================================================================
    # create_export_file: Create a single exports file.
    #===================================================================

    # copy all exported symbols into one master export file
    #
    open(EXPORT_FILE, ">$base_exports_file_nq") ||
            expire("Could not open file '$base_exports_file_nq': $!");
    push(@FILES_TO_REMOVE, "$base_exports_file_nq") if (!$makefilename);
    foreach my $an_export_file (@EXPORT_FILES)
    {
        open(AN_EXPORT_FILE, "$an_export_file") ||
             expire("Could not open file '$an_export_file': $!");
        while (<AN_EXPORT_FILE>)
        {
            # Strip out lines that only contain whitespace and
            # lines that start with '#' or '*' (comments)
            #
            if (/\S/ && !/^[\#*]/)
            {
                print EXPORT_FILE $_;
            }
        }
        close(AN_EXPORT_FILE);
    }
    close(EXPORT_FILE);
}
#=======================================================================
sub describe_mb
{
    #===================================================================
    # describe_mb: Issues mbuild messages. This way lengthy messages do
    #              not clutter up the main body of code.
    #===================================================================

    local($_) = $_[0];

 DESCRIPTION: {
     /^usage$/ && print(<<'end_usage_mb') && last DESCRIPTION;
    Usage:
      MBUILD [option1 ... optionN] sourcefile1 [... sourcefileN]
             [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
             [exportfile1 ... exportfileN]

    Use the -help option for more information, or consult the MATLAB Compiler
    User's Guide.

end_usage_mb
     /^general_info$/ && print(<<"end_general_info_mb") && last DESCRIPTION;
 This is mbuild Copyright 1984-2005 The MathWorks, Inc.

end_general_info_mb
     /^invalid_options_file$/ && print(<<"end_invalid_options_file_mb") && last DESCRIPTION;
    Warning: An options file for MBUILD.BAT was found but the
             value for 'COMPILER' was not set.  This could mean that the
             value is not specified within the options file, or it could
             mean that there is a syntax error within the file.


end_invalid_options_file_mb
     /^final_options$/ && print(<<"end_final_options_mb") && last DESCRIPTION;
$sourced_msg
----------------------------------------------------------------
->    Options file           = $OPTFILE_NAME
->    COMPILER               = $COMPILER
->    Compiler flags:
         COMPFLAGS           = $COMPFLAGS
         OPTIMFLAGS          = $OPTIMFLAGS
         DEBUGFLAGS          = $DEBUGFLAGS
         arguments           = $ARG_FLAGS
         Name switch         = $NAME_OBJECT
->    Pre-linking commands   = $PRELINK_CMDS
->    LINKER                 = $LINKER
->    Link directives:
         LINKFLAGS           = $LINKFLAGS
         LINKFLAGSPOST       = $LINKFLAGSPOST
         Name directive      = $NAME_OUTPUT
         File link directive = $LINK_FILE
         Lib. link directive = $LINK_LIB
         Rsp file indicator  = $RSP_FILE_INDICATOR
->    Resource Compiler      = $RC_COMPILER
->    Resource Linker        = $RC_LINKER
----------------------------------------------------------------

end_final_options_mb
     /^file_not_found$/ && print(<<"end_file_not_found_mb") && last DESCRIPTION;
  $main::cmd_name:  $filename not a normal file or does not exist.

end_file_not_found_mb
     /^meaningless_output_flag$/ && print(<<"end_meaningless_output_flag_mb")  && last DESCRIPTION;
  Warning: -output ignored (no MBUILD application is being created).

end_meaningless_output_flag_mb

    /^compiler_not_found$/ && print(<<"end_compiler_not_found_mb") && last DESCRIPTION;
  Could not find the compiler "$COMPILER" on the DOS path.
  Use mbuild -setup to configure your environment properly.

end_compiler_not_found_mb

    /^outdir_missing_name_object$/ && print(<<"end_outdir_missing_name_object_mb") && last DESCRIPTION;
  Warning: The -outdir switch requires the mbuild options file to define
           NAME_OBJECT. Make sure you are using the latest version of
           your compiler's mbuildopts file.

end_outdir_missing_name_object_mb

    /^bad_lang_option$/ && print(<<"end_bad_lang_option_mb") && last DESCRIPTION;
  Unrecognized language specified. Please use -lang cpp (for C++) or
  -lang c (for C).

end_bad_lang_option_mb

    /^bad_link_option$/ && print(<<"end_bad_link_option_mb") && last DESCRIPTION;
  Unrecognized link target specified. Please use -link exe (for an executable)
  or -link shared (for a shared/dynamically linked library).

end_bad_link_option_mb

     do {
         print "Internal error: Description for $_[0] not implemented\n";
         last DESCRIPTION;
     };
 }
}
#=======================================================================
sub dll_makedef
{
    #===================================================================
    # dll_makedef: Make the exports list.
    #===================================================================

    $i = 0;
    my $makedef = $ENV{"DLL_MAKEDEF"};
    while ($makedef =~ /\S/)
    {
        if ($makefilename)
        {
            emit_makedef($makedef);
        }
        RunCmd($makedef);
        $i++;
        $makedef = $ENV{"DLL_MAKEDEF" . $i};
    }

}
#=======================================================================
sub dll_variables
{
    #===================================================================
    # dll_variables: set variables with dll options.
    #===================================================================

    if ($DLLCOMPFLAGS eq "")
    {
        expire("Error: The current options file is not configured to create DLLs. "
                . "You can use\n" . tool_name() . " -setup to set up an options file "
                . "which is configured to create DLLs.");
    }

    $COMPFLAGS = $DLLCOMPFLAGS;
    $LINKFLAGS = $DLLLINKFLAGS;
    $LINKFLAGSPOST = $DLLLINKFLAGSPOST;
    $NAME_OUTPUT = $DLL_NAME_OUTPUT;
}
#=======================================================================
sub fix_mbuild_variables
{
    #===================================================================
    # fix_mbuild_variables: Fix variables for mbuild.
    #===================================================================

    if ($verbose) {
        describe_mb("final_options");
    }

    if ($COMPILER eq "none") {
        describe_mb("invalid_options_file");
    }

    if ($outdir_flag && $NAME_OBJECT eq "") {
        describe_mb("outdir_missing_name_object");
    }

    # Decide how to optimize or debug
    #
    if (! $debug) {                                  # Normal case
        $FLAGS = $OPTIMFLAGS;
    } elsif (! $optimize) {                          # Debug; don't optimize
        $FLAGS = $DEBUGFLAGS;
    } else {                                         # Debug and optimize
        $FLAGS = "$DEBUGFLAGS $OPTIMFLAGS";
    }

    # Include the simulink include directory if it exists
    #
    my $simulink_inc_dir = mexCatdir($ML_DIR, "simulink", "include");
    if (-e $simulink_inc_dir)
    {
        $FLAGS = "-I$simulink_inc_dir $FLAGS";
    }

    # Add extern/include to the path (it always exists)
    #
    my $extern_include_dir = mexCatdir($ML_DIR, "extern", "include");
    $FLAGS = "-I$extern_include_dir $FLAGS";

    # Verify that compiler binary exists
    #
    $COMPILER_DIR = search_path("$COMPILER.exe");
    if ( ! $COMPILER_DIR ) {
        describe_mb("compiler_not_found");
        expire("Error: Unable to locate compiler.");
    }

    # If there are no files, then exit.
    #
    if (!@FILES) {
        describe_mb("usage");
        expire("Error: No file names given.");
    }
}
#=======================================================================
sub init_mbuild
{
    #===================================================================
    # init_mbuild: Mbuild specific initialization.
    #===================================================================

    $main::mexopts_directory = mexCatdir($main::script_directory,
                                                     $ARCH,
                                                     "mbuildopts");
    $OPTFILE_NAME = "compopts.bat";

    # Should always be one of {"c", "cpp", "fortran", "all"}
    #
    $lang = "c"; 
    $link = "unspecified";

    $COMPILE_EXTENSION = 'c|cu|cc|cxx|cpp';
}
#=======================================================================
sub parse_mbuild_args
{
    #===================================================================
    # parse_mbuild_args: Parse all mbuild arguments including common.
    #===================================================================

    for (;$_=shift(@ARGV);) {

        # Perl-style case construct
        # print "DEBUG input argument is $_\n";
        #
        ARGTYPE: {

          /^[-\/](h(elp)?)|\?$/ && do {
              printHelp();
              expire("normally");
              last ARGTYPE;
          };

          /^-v$/ && do {
              describe_mb("general_info");
              $verbose = "yes";
              last ARGTYPE;
          };

          if (parse_common_dash_args($_)) {
              last ARGTYPE;
          }

          /^-lang$/ && do {
              $lang_override = shift(@ARGV);
              if (!($lang_override =~ /(cpp|c)/)) { describe_mb("bad_lang_option"); }
              last ARGTYPE;
          };

          # This is an undocumented feature which is subject to change
          #
          /^-link$/ && do {
              $link = shift(@ARGV);
              if (!($link =~ /^(shared|exe|dll)$/)) { describe_mb("bad_link_option"); }
              last ARGTYPE;
          };

          /^-regsvr$/ && do {
              $regsvr = "yes";
              last ARGTYPE;
          };

          # Already found. Skip over it.
          #
          /^-mb$/ && do {
              last ARGTYPE;
          };

          /^-package$/ && do {
              $jpackage_flag = "yes";
              $jpackage = shift(@ARGV);
              last ARGTYPE;
          };

          # Finished processing all '-' arguments. Error at this
          # point if a '-' argument.
          #
          /^-.*$/ && do {
              describe_mb("usage");
              expire("Error: Unrecognized switch: $_.");
              last ARGTYPE;
          };

          if (parse_common_nodash_args($_)) {
              last ARGTYPE;
          }

          /^.*\.exports$/ && do {
              push(@EXPORT_FILES, $_);
              last ARGTYPE;
          };

          /^.*\.def$/ && do {
              if (@DEF_FILES > 0) {
                  expire( "Error: " . tool_name() . " Only one .def file is allowed on the command line." );
              }
              push(@DEF_FILES, $_);
              last ARGTYPE;
          };

          /^(.*)\.rc$/ && do {
              if (@RC_FILES > 0) {
                  expire( "Error: " . tool_name() . " Only one .rc file is allowed on the command line." );
              }
              push(@RC_FILES, $1);
              last ARGTYPE;
          };

          /^.*\.idl/  && do {
              push(@IDL_FILES, $_);
              last ARGTYPE;
          };

          /^.*\.java/ && do {
              push(@JAVA_FILES, $_);
              last ARGTYPE;
          };

            do {

                # Remove command double quotes (but there by mex.m)
                #
                tr/"//d;

                if (/(.*)\.dll$/)
                {
                    expire("Error: " . tool_name() . " cannot link to '$_' directly.\n" .
                            "  Instead, you must link to the file '$1.lib' which corresponds " .
                            "to '$_'.");
                }

                if (!/\.lib$/ && !-e $_) {
                    expire("Error: '$_' not found.");
                }

                # Put file in list of files to compile
                #
                push(@FILES, $_);

                # Try to determine compiler (C or C++) to use from
                # file extension.
                #
                if (/\.(cpp|cxx|cc)$/i)
                {
                    $lang = "cpp";
                }
                if (/\.(c|cu)$/i)
                {
                    $lang = "c";
                }
                if (/\.(f|for|f90)$/i)
                {
                    $lang = "fortran";
                }

                last ARGTYPE;
            }
        } # end ARGTYPE block
    } # end for loop

    if ($lang_override) { $lang = $lang_override; }

    if ($link eq "unspecified")
    {
        if (@EXPORT_FILES > 0)
        {
            $link = "shared";
        }
        elsif (@DEF_FILES >0) 
        {
            $link = "dll";
        }
        else
        {
            $link = "exe";
        }
    }

    # Warn user that output target is ignored when compile only.
    #
    if ($compile_only && $output_flag) {
        describe_mb("meaningless_output_flag");
    }
}
#=======================================================================
sub process_idl_files
{
    #===================================================================
    # process_idl_files: Process any idl files.
    #===================================================================

    if ($debug eq "yes") {
        $options = $ENV{'IDL_DEBUG_FLAGS'};
    }
    else {
        $options = $ENV{'IDL_OPTIM_FLAGS'};
    }
    if ($ENV{'OUTDIR'} ne "") {
        $options = "$options $ENV{'IDL_OUTPUTDIR'}";
    }
    if ($ENV{'IDL_COMPILER'} eq "") {
        expire("Error: The chosen compiler does not support building COM objects.\n\tPlease see the MATLAB Builder for .NET/Excel documentation for the latest list of supported compilers." );
    }
    RunCmd("copy " . smart_quote(mexCatfile($ENV{'MATLAB'}, "extern", "include", "mwcomutil.tlb")) . " .");

    foreach my $an_idl_file (@IDL_FILES) 
    {        
        RunCmd( "$ENV{'IDL_COMPILER'} $options \"$an_idl_file\"" );
        if ($? != 0) {
            expire("Error: IDL compile of '$an_idl_file' failed.");
        }
    }

    RunCmd("del mwcomutil.tlb");
}
#=======================================================================
sub process_java_files
{
    #===================================================================
    # process_java_files: Process any java files.
    #===================================================================

    # environment variable takes precedence
    #
    $java_home = $ENV{'JAVA_HOME'};
    if($java_home eq "")
    {
        #attempt to lookup java info in registry
        $java_version = registry_lookup("SOFTWARE\\JavaSoft\\Java Development Kit", "CurrentVersion");
        if($java_version ne "")
        {
            $java_home = registry_lookup("SOFTWARE\\JavaSoft\\Java Development Kit\\" . $java_version, "JavaHome");
        }
        else
        {
            expire("Error: Failed to locate java home location in either windows registry or environment variable.");
        }
    }

    if($java_home ne "")
    {
        print "JAVA HOME: $java_home\n";
 
        $java_bin = mexCatdir($java_home, "bin");
        $javac = mexCatdir($java_bin, "javac");
        $javah = mexCatdir($java_bin, "javah");
        $jar = mexCatdir($java_bin, "jar");

        $jni_include = mexCatdir($java_home, "include");
        $jni_include = "-I" . smart_quote($jni_include) .
                       " -I" . smart_quote(mexCatdir($jni_include, $ARCH));
        $FLAGS = "$FLAGS $jni_include";

        #Wrap in quotes in case of space in path
        $java_bin = smart_quote($java_bin);
        $javac = smart_quote($javac);
        $javah = smart_quote($javah);
        $jar = smart_quote($jar);
    }

    # classpath handling
    #
    $java_builder_jar = smart_quote(mexCatfile($ENV{'MATLAB'}, "java", "jar", "toolbox", "javabuilder.jar"));
    $java_builder_jar_qm = quotemeta($java_builder_jar);
    print "matlab jar file $java_builder_jar\n";
    $java_classpath = $ENV{'CLASSPATH'};
    print "classpath unadulterated: $java_classpath\n";
    if($java_classpath eq "")
    {
       $java_classpath = ".;" . smart_quote($java_builder_jar) .";";
       print "classpath was empty - set classpath to: $java_classpath\n";
    }
    elsif ($java_classpath =~ m/$java_builder_jar_qm/i eq "")
    {
        $java_classpath = $java_classpath . ";" . smart_quote($java_builder_jar) . ";";
        print "added mathworks jar file - set classpath to: $java_classpath\n";
    }
    else
    {
        print "classpath ok: $java_classpath\n";
    }

    # if we didn't get a hit in the registry try the environment
    #
    if ($java_home eq "")
    {
        print "Did not locate java in registry.  Trying environment.\n";

        $java_home = $ENV{'JAVA_HOME'};
        if($java_home eq "")
        {
            expire("Error: Failed to locate java home location in either windows registry or environment variable.");
        }
    }

    if ($debug eq "yes") {
        $options = $ENV{'JAVA_DEBUG_FLAGS'};
    }
    else {
        $options = $ENV{'JAVA_OPTIM_FLAGS'};
    }
    if ($ENV{'OUTDIR'} ne "") {
        $options = "$options $ENV{'JAVA_OUTPUTDIR'}";
    }

    $new_jar = 1;
    foreach my $a_java_file (@JAVA_FILES) 
    {
        print "javac\n";
        RunCmd( "$javac $options -classpath $java_classpath " . smart_quote($a_java_file) );
        if ($? != 0) {
            expire("Error: javac of '$a_java_file' failed.");
        }

        $base = (fileparse($a_java_file))[0];      
        $jni_file = (fileparse($base,'\..*'))[0];
        if($jpackage_flag eq "yes")
        {
            $jni_file = $jpackage . "." . $jni_file;
        }

        print "javah\n";
        RunCmd( "$javah $options -classpath $java_classpath " . smart_quote($jni_file) );
        if ($? != 0) {
            expire("Error: javah of '$jni_file' failed.");
        }

        print "jar\n";
        $jpackage_orig = $jpackage;
        $jpackage =~ s/\./\\/g;
        $jpackage_path = $jpackage;
        $jpackage = $jpackage_orig;

        print "jpackage path = $jpackage_path\n";

        $java_class_file = mexCatfile($jpackage_path, (fileparse($base,'\..*'))[0] . ".class");

        if($new_jar == 1)
        {
            $jar_opts = "-cvf";
        }
        else
        {
            $jar_opts = "-uvf";
        }

        RunCmd( "$jar $jar_opts $ENV{'MEX_NAME'}.jar " . smart_quote($java_class_file) );
        if ($? != 0) {
            expire("Error: jar failed.");
        }
        else
        {
            $new_jar = 0;
        }
    }

    print "Done processing files";
}
#=======================================================================
sub register_dll
{
    #===================================================================
    # register_dll: Register DLL with COM object system.
    #===================================================================
    my $dllpath = mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}.$bin_extension");
    RunCmd( "mwregsvr " . smart_quote($dllpath));
    if ($? != 0) {
        expire("Error: regsvr32 for $dllpath failed.");
    }
}
#=======================================================================
sub set_mbuild_variables
{
    #===================================================================
    # set_mbuild_variables: Set more variables for mbuild.
    #===================================================================

    # Use the 1st file argument for the target name (MEX_NAME)
    # if not set.
    #
    ($derived_name, $EXTENSION) = ($FILES[0] =~ /([ \w]*)\.(\w*)$/);
     $ENV{'MEX_NAME'} = $derived_name if (!($ENV{'MEX_NAME'}));

    # Create the name of the master exports file which mex will generate.
    # This is an "input" to the options file so it needs to be set before we
    # process the options file.
    #
    if ($link eq "dll") {
        $ENV{'DEF_FILE'}          = smart_quote(@DEF_FILES);
    }
    elsif ($makefilename)
    {
        # _nq => not quoted
        #
        $base_exports_file_nq     = mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}_master.exports");
        $ENV{'BASE_EXPORTS_FILE'} = smart_quote($base_exports_file_nq);
        $ENV{'DEF_FILE'}          = smart_quote(mexCatfile($ENV{'OUTDIR'}, "$ENV{'MEX_NAME'}_master.def"));
    }
    else
    {
        $base_exports_file_nq     = mexCatfile($main::temp_dir,
                                                        tool_name() . "_tmp.exports");
        $ENV{'BASE_EXPORTS_FILE'} = smart_quote($base_exports_file_nq);
        $ENV{'DEF_FILE'}          = "$ENV{'LIB_NAME'}.def";
    }
    $BASE_EXPORTS_FILE = $ENV{'BASE_EXPORTS_FILE'};
    $DEF_FILE          = $ENV{'DEF_FILE'};

    if (@RC_FILES>0) {
        $_ = pop(@RC_FILES);
        /(.*\\|)([ \w]+)$/;
        $ENV{'RES_PATH'} = $1;
        $ENV{'RES_NAME'} = $2;
    }
}
#=======================================================================
########################################################################
#=======================================================================
# Main:
#=======================================================================
init_common();

if ($main::mbuild eq 'no')
{
    #===================================================================
    # MEX section
    #===================================================================

    init_mex();
    parse_mex_args();

    set_common_variables();
    set_mex_variables();    
    

    # Ada S-function
    #
    if ($lang eq "ada")
    {
        build_ada_s_function($ada_sfunction, $ada_include_dirs);
        expire("normally");
    }

    # Do only setup if specified.
    #
    if ($setup || $setup_special)
    {
        do_setup();
        exit(0);
    }

    options_file();

    fix_flag_variables();
    process_overrides();

    fix_mex_variables();
    fix_common_variables();

    if ($makefilename)
    {
        # MAKEFILE is closed in expire()
        #
        start_makefile();
    }
    compile_files();
    expire("normally") if ($compile_only);
    if ($makefilename)
    {
        emit_link_dependency();
    }
    pre_or_postlink("PRELINK_CMDS");
    files_to_remove();
    if ($ENV{'RES_NAME'} =~ /\S/)
    {
        compile_resource();
    }
    linker_arguments();
    link_files();
    if ($ENV{'RES_NAME'} =~ /\S/ && $RC_LINKER =~ /\S/)
    {
        resource_linker();
    }
    pre_or_postlink("POSTLINK_CMDS");
    if ($makefilename)
    {
       emit_delete_resource_file();
       emit_makefile_terminator();
    }
    expire("normally");
}
else
{
    #===================================================================
    # MBUILD section
    #===================================================================

    init_mbuild();
    parse_mbuild_args();

    # Do only setup if specified.
    #
    if ($setup || $setup_special)
    {
        do_setup();
        exit(0);
    }

    set_common_variables();
    set_mbuild_variables();    

    options_file();
    if ($link eq "shared" || $link eq "dll") 
    {
        dll_variables();
        if ($link eq "shared")
        {
            create_export_file();
        }
    } 

    fix_flag_variables();
    process_overrides();

    fix_mbuild_variables();
    fix_common_variables();
    
    if ($makefilename)
    {
        # MAKEFILE is closed in expire()
        #
        start_makefile();
    }
    if (scalar(@JAVA_FILES) > 0)
    {
        process_java_files();
    }
    if (scalar(@IDL_FILES) > 0)
    {
        process_idl_files();
    }
    compile_files();
    expire("normally") if ($compile_only);
    if ($makefilename)
    {
        emit_link_dependency();
    }
    pre_or_postlink("PRELINK_CMDS");
    if ($link eq "shared")
    {
        dll_makedef();
    }
    files_to_remove();
    if ($ENV{'RES_NAME'} =~ /\S/)
    {
        compile_resource();
    }
    linker_arguments();
    link_files();
    if ($ENV{'RES_NAME'} =~ /\S/ && $RC_LINKER =~ /\S/)
    {
        resource_linker();
    }
    pre_or_postlink("POSTLINK_CMDS");
    if ($regsvr)
    {
        register_dll();
    }
    if ($makefilename)
    {
       emit_delete_resource_file();
       emit_makefile_terminator();
    }
    expire("normally");
}
#=======================================================================
