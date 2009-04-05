#! /bin/sh
# Simple wrapper around SVN and Git featuring auto-ChangeLog entries and
# emailing.
# $Id: 7b9caf76ced039c6e8d8fc58d4636134197098a4 $
# Copyright (C) 2006, 2007  Benoit Sigoure.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Quick install: alias svn=path/to/svn-wrapper.sh -- that's all.

 # ------ #
 # README #
 # ------ #

# This script is a wrapper around the SVN and Git command-line clients for
# UNIX.  It has been designed mainly to automagically generate GNU-style
# ChangeLog entries when committing and mail them along with a diff and an
# optional comment from the author to a list of persons or a mailing list.
# Although this script was originally written for SVN (hence the name), it
# also works with Git and tries to detect whether the current repository is a
# Git or SVN repository.
# This script has been written to be as much portable as possible and cover as
# many use-case as reasonably possible.  It won't work with Solaris'
# brain-damaged stock /bin/sh.
#
# HOWEVER, there will be bugs, there will be cases in which the script doesn't
# wrap properly the svn-cli, etc.  In this case, you can try to mail me at
# <tsuna at lrde dot epita dot fr>.  Include the revision of the svn-wrapper
# you're using, and full description of what's wrong etc. so I can reproduce
# your problem.
#
# If you feel like, you can try to fix/enhance the script yourself. It only
# requires some basic Shell-scripting skills.  Knowing sed will prove useful :)

 # ------------- #
 # DOCUMENTATION #
 # ------------- #

# If you're simply looking for the usage, run `svn-wrapper.sh help' (or
# `svn help' if you aliased `svn' on svn-wrapper.sh) as usual.
#
# This script is (hopefully) portable, widely commented and self-contained. Do
# not hesitate to hack it. It might look rather long (because it does a lot of
# things :P) but you should be able to easily locate which part of the code
# you're looking for.
#
# The script begins by defining several functions. Then it really starts where
# the comment "# `main' starts here. #" is placed.
# Some svn commands are hooked (eg, `svn st' displays colors).  Hooks and
# extra commands are defined in functions named `svn_<command-name>'.

 # ---- #
 # TODO #
 # ---- #

#  * Write a real testsuite.  :/
#  * Automatic proxy configuration depending on the IP in ifconfig?
#  * Customizable behavior/colors via some ~/.<config>rc file (?)
#  * Handle things such as svn ci --force foobar.
#
#  * svn automerge + automatic fill in branches/README.branches.
#    => won't do (SVN is too borken WRT merges, I use Git now so I don't feel
#       like dealing with this sort of SVN issue)
#  * Automatically recognize svn cp and svn mv instead of writing "New" and
#    "Remove" in the template ChangeLog entry (hard). Pair the and new/remove
#    to prepare a good ChangeLog entry (move to X, copy from X) [even harder].
#    => won't do (Git does this fine, can't be bothered to deal with this for
#       SVN)



# Default values (the user can export them to override them).
use_changelog=:
git_mode=false
using_git_svn=false
case $SVN in
  git*) git_mode=:;;
  '')
    if [ -d .git ] || [ -d ../.git ]; then
      SVN=git
      git_mode=:
    else
      SVN=svn
    fi
    ;;
esac

: ${EDITOR=missing}
export EDITOR
: ${GPG=gpg}
: ${TMPDIR=/tmp}
export TMPDIR
: ${PAGER=missing}
export PAGER
# Override the locale.
LC_ALL='C'
export LC_ALL
: ${AWK=missing}
: ${DIFF=missing}
: ${COLORDIFF=missing}

# Signal number for traps (using plain signal names is not portable and breaks
# on recent Debians that use ash as their default shell).
SIGINT=2

me=$0
bme=`basename "$0"`

# Pitfall: some users might be tempted to export SVN=svn-wrapper.sh for some
# reason. This is just *wrong*. The following is an attempt to save them from
# some troubles.
if [ x`basename "$SVN"` = x"$bme" ]; then
  echo "warning: setting SVN to $bme is wrong"
  SVN='svn'
fi

# This code comes (mostly) from Autoconf.
# The user is always right.
if test "${PATH_SEPARATOR+set}" != set; then
  PATH_SEPARATOR=:
  (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 && {
    (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 ||
      PATH_SEPARATOR=';'
  }
fi

version='0.4'
full_rev='$Id: 7b9caf76ced039c6e8d8fc58d4636134197098a4 $'
# Get the first 6 digits (without forking)
revision=${full_rev#'$'Id': '}
revision=${revision%??????????????????????????????????' $'}

# The `main' really starts after the functions definitions.

  # ---------------- #
  # Helper functions #
  # ---------------- #

set_colors()
{
  red='[0;31m';    lred='[1;31m'
  green='[0;32m';  lgreen='[1;32m'
  yellow='[0;33m'; lyellow='[1;33m'
  blue='[0;34m';   lblue='[1;34m'
  purple='[0;35m'; lpurple='[1;35m'
  cyan='[0;36m';   lcyan='[1;36m'
  grey='[0;37m';   lgrey='[1;37m'
  white='[0;38m';  lwhite='[1;38m'
  std='[m'
}

set_nocolors()
{
  red=;    lred=
  green=;  lgreen=
  yellow=; lyellow=
  blue=;   lblue=
  purple=; lpurple=
  cyan=;   lcyan=
  grey=;   lgrey=
  white=;  lwhite=
  std=
}

# abort err-msg
abort()
{
  echo "svn-wrapper: ${lred}abort${std}: $@" \
  | sed '1!s/^[ 	]*/             /' >&2
  exit 1
}

# warn msg
warn()
{
  echo "svn-wrapper: ${lred}warning${std}: $@" \
  | sed '1!s/^[ 	]*/             /' >&2
}

# notice msg
notice()
{
  echo "svn-wrapper: ${lyellow}notice${std}: $@" \
  | sed '1!s/^[ 	]*/              /' >&2
}

# yesno question
yesno()
{
  printf "$@ [y/N] "
  read answer || return 1
  case $answer in
    y* | Y*) return 0;;
    *)       return 1;;
  esac
  return 42 # should never happen...
}

# yesnewproceed what
# returns true if `yes' or `proceed', false if `new'.
# the answer is stored in $yesnoproceed_res which is /yes|new|proceed/
yesnewproceed()
{
  printf "$@ [(y)es/(p)roceed/(u)p+proceed/(N)ew] "
  read answer || return 1
  case $answer in
    y* | Y*) yesnoproceed_res=yes;     return 0;;
    p* | P*) yesnoproceed_res=proceed; return 0;;
    u* | U*) yesnoproceed_res=upproceed; return 0;;
    *)       yesnoproceed_res=new;      return 1;;
  esac
  return 42 # should never happen...
}

# warn_env env-var
warn_env()
{
  warn "cannot find the environment variable $1
        You might consider using \`export $1='<FIXME>'\`"
}

# get_unique_file_name file-name
get_unique_file_name()
{
  test -e "$1" || {
    echo "$1" && return 0
  }
  gufn=$1; i=1
  while test -e "$gufn.$i"; do
    i=$(($i + 1))
  done
  echo "$gufn.$i"
}

# ensure_not_empty description value
ensure_not_empty()
{
  case $2 in #(
    # `value' has at least one non-space character.
    *[-a-zA-Z0-9_!@*{}|,./:]*)
      return;;
  esac
  ene_val=`echo "$2" | tr -d ' \t\n'`
  test -z "$ene_val" && abort "$1: empty value"
}

# find_prog prog-name
# return true if prog-name is in the PATH
# echo the full path to prog-name on stdout.
# Based on a code from texi2dvi
find_prog()
{
  save_IFS=$IFS
  IFS=$PATH_SEPARATOR
  for dir in $PATH; do
    IFS=$save_IFS
    test -z "$dir" && continue
    # The basic test for an executable is `test -f $f && test -x $f'.
    # (`test -x' is not enough, because it can also be true for directories.)
    # We have to try this both for $1 and $1.exe.
    #
    # Note: On Cygwin and DJGPP, `test -x' also looks for .exe. On Cygwin,
    # also `test -f' has this enhancement, bot not on DJGPP. (Both are
    # design decisions, so there is little chance to make them consistent.)
    # Thusly, it seems to be difficult to make use of these enhancements.
    #
    if test -f "$dir/$1" && test -x "$dir/$1"; then
      echo "$dir/$1"
      return 0
    elif test -f "$dir/$1.exe" && test -x "$dir/$1.exe"; then
      echo "$dir/$1.exe"
      return 0
    fi
  done
  return 1
}

# find_progs prog [progs...]
# Look in PATH for one of the programs given in argument.
# If none of the progs can be found, the string "exit 2" is "returned".
find_progs()
{
  # This code comes mostly from Autoconf.
  for fp_prog in "$@"; do
    fp_res=`find_prog $fp_prog`
    if [ $? -eq 0 ]; then
      echo "$fp_res"
      return 0
    fi
  done
  echo "exit 2"
  return 1
}

test x"$EDITOR" = xmissing && EDITOR=`find_progs vim vi emacs nano`
test x"$PAGER" = xmissing && PAGER=`find_progs less more`
test x"$AWK" = xmissing && AWK=`find_progs gawk mawk nawk awk`
test x"$DIFF" = xmissing && DIFF=`find_progs diff`
if test x"$COLORDIFF" = xmissing; then
  if test -t 1; then
    COLORDIFF=`find_progs colordiff diff`
  else
    COLORDIFF=$DIFF
  fi
fi

# -R will tell less to interpret some terminal codes, which will turn on
# colors.
case $PAGER in #(
  less) PAGER='less -R';;
esac

# require_diffstat
# return true if diffstat is in the PATH
require_diffstat()
{
  if [ x"$require_diffstat_cache" != x ]; then
    return $require_diffstat_cache
  fi
  if (echo | diffstat) >/dev/null 2>/dev/null; then :; else
    warn 'diffstat is not installed on your system or not in your PATH.'
    test -f /etc/debian_version \
    && notice 'you might want to `apt-get install diffstat`.'
    require_diffstat_cache=1
    return 1
  fi
  require_diffstat_cache=0
  return 0
}

# require_mail
# return 0 -> found a mailer
# return !0 -> no mailer found
# The full path to the program found is echo'ed on stdout.
require_mail()
{
  save_PATH=$PATH
  PATH="${PATH}${PATH_SEPARATOR}/sbin${PATH_SEPARATOR}/usr/sbin${PATH_SEPARATOR}/usr/libexec"
  export PATH
  find_progs sendEmail sendmail mail
  rv=$?
  PATH=$save_PATH
  export PATH
  return $rv
}

# my_sendmail mail-file mail-subject mail-to [extra-headers]
# mail-to is a comma-separated list of email addresses.
# extra-headers is an optionnal argument and will be prepended at the
# beginning of the mail headers if the tool used to send mails supports it.
# The mail-file may also contain headers. They must be separated from the body
# of the mail by a blank line.
my_sendmail()
{
  test -f "$1" || abort "my_sendmail: Cannot find the mail file: $1"
  test -z "$2" && warn 'my_sendmail: Empty subject.'
  test -z "$3" && abort 'my_sendmail: No recipient specified.'

  content_type='Content-type: text/plain'
  extra_headers="X-Mailer: svn-wrapper v$version (g$revision)
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit"
  if test x"$4" != x; then
    extra_headers="$4
$extra_headers"
    # Remove empty lines.
    extra_headers=`echo "$extra_headers" | sed '/^[ 	]*$/d;s/^[ 	]*//'`
  fi

  # If we have a signature, add it.
  if test -f ~/.signature; then
    # But don't add it if it is already in the mail.
    if grep -Fe "`cat ~/.signature`" "$1" >/dev/null; then :; else
      echo '-- ' >>"$1" && cat ~/.signature >>"$1"
    fi
  fi
  # VCS-compat: handle user option 'sign'.
  if (grep '^sign: false' ~/.vcs) >/dev/null 2>/dev/null; then :; else
    ($GPG -h) >/dev/null 2>/dev/null
    gpg_rv=$?
    if [ -e ~/.gnupg ] || [ -e ~/.gpg ] || [ -e ~/.pgp ] && [ $gpg_rv -lt 42 ]
    then
      if grep 'BEGIN PGP SIGNATURE' "$1" >/dev/null; then
        notice 'message is already GPG-signed'
      elif yesno "Sign the mail using $GPG ?"; then
        # Strip the headers
        sed '1,/^$/d' "$1" >"$1.msg"
        sed '1,/^$/!d' "$1" >"$1.hdr"
        # Sign the message, keep only the PGP signature.
        $GPG --clearsign <"$1.msg" >"$1.tmp" || {
          rm -f "$1.msg" "$1.hdr" "$1.tmp"
          abort "\`$GPG' failed (r=$?)"
        }
        sed '/^--*BEGIN PGP SIGNATURE--*$/,/^--*END PGP SIGNATURE--*$/!d' \
            "$1.tmp" >"$1.sig"

        boundary="svn-wrapper-2-$RANDOM"
        boundary="$boundary$RANDOM"
        # Prepend some stuff before the PGP signature.
        echo "
--$boundary
content-type: application/pgp-signature; x-mac-type=70674453;
        name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit" | cat - "$1.sig" >"$1.tmp"
        mv -f "$1.tmp" "$1.sig"

        # Append some stuff after the PGP signature.
        echo "
--$boundary--" >>"$1.sig"
        # Re-paste the headers before the signed body and prepend some stuff.
        echo "This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--$boundary
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=iso-8859-1; format=flowed
" \
        | cat "$1.hdr" - "$1.msg" "$1.sig" >"$1.tmp" \
        && mv -f "$1.tmp" "$1"
        content_type="Content-Type: multipart/signed;\
 protocol=\"application/pgp-signature\"; micalg=pgp-sha1;\
 boundary=\"$boundary\""
        # Cleanup.
        rm -f "$1.tmp" "$1.sig" "$1.msg" "$1.hdr"
        extra_headers="$extra_headers
X-Pgp-Agent: `$GPG --version | sed q`"
      fi
    fi
  fi
  extra_headers="$extra_headers
$content_type"

  mailer=`require_mail`
  if [ $? -ne 0 ]; then
    warn 'my_sendmail: No suitable mailer found.'
    return 1
  fi
  case $mailer in
    */sendmail)
       to=`echo "$3" | sed 's/,//g'`
       echo "$extra_headers" | cat - "$1" | $mailer $to;;
    */mail)
       cat "$1" | $mailer -s "$2" "$3";;
    */sendEmail)
       if [ x"$SMTP" = x ]; then
         warn 'my_sendmail: (sendEmail) please tell me the SMTP server to use'
         printf 'STMP server: '
         read SMTP || abort 'could not read the SMTP server'
         notice "hint: you can export SMTP=$SMTP if you don't want to be asked"
       fi
       sendEmail -f "$FULLNAME <$EMAIL>" -t "$3" -u "$2" \
                 -s "$SMTP" -o message-file="$1";;
    *) # wtf
       abort 'my_sendmail: Internal error.';;
  esac
}

# selfupdate
selfupdate()
{
  my_url='http://www.lrde.epita.fr/~sigoure/svn-wrapper'
  # You can use https if you feel paranoiac.

  echo ">>> Fetching svn-wrapper.sh from $my_url/svn-wrapper.sh"

  # --------------------- #
  # Fetch the new version #
  # --------------------- #

  tmp_me=`get_unique_file_name "$TMPDIR/svn-wrapper.sh"`
  if (wget --help) >/dev/null 2>/dev/null; then
    wget --no-check-certificate "$my_url/svn-wrapper.sh" -O "$tmp_me"
    my_wget='wget'
  else
    curl --help >/dev/null 2>/dev/null
    if [ $? -gt 42 ]; then
      abort 'Cannot find wget or curl.
             How can I download any update without them?'
    fi
    my_wget='curl'
    curl --insecure "$my_url/svn-wrapper.sh" >"$tmp_me"
  fi

  test -r $tmp_me \
    || abort "Cannot find the copy of myself I downloaded in $tmp_me"

  # ---------------------------------------- #
  # Compare versions and update if necessary #
  # ---------------------------------------- #

  my_ver=$revision
  tmp_ver=`sed '/^# $Id[:].*$/!d;
                s/.*$Id[:] *\([a-f0-9]\{6\}\).*/\1/' "$tmp_me"`
  test -z "$tmp_ver" && abort "Cannot find the revision of $tmp_me"
  if [ x"$my_ver" != x"$tmp_ver" ]; then # There IS an update...
    echo "An update is available, r$tmp_ver (your version is r$my_ver)"

    # Wanna see the diff?
    if yesno 'Do you want to see the diff?'
    then
      (require_diffstat && diff -uw "$me" "$tmp_me" | diffstat;
       echo
       $COLORDIFF -uw "$me" "$tmp_me") | $PAGER
    fi

    # Let's go :)
    if yesno "Overwrite $me (r$my_ver) with $tmp_me (r$tmp_ver)?"; then
      chmod a+x "$tmp_me"
      cp -p "$me" "$me.r$my_ver"
      mv "$tmp_me" "$me" && exit 0
    fi
    rm -f "$tmp_me"
    return 1
  else
    echo "You're already up to date [r$my_ver] :)"
  fi
  rm -f "$tmp_me"
}

# get_svn_diff_and_diffstat [files to diff]
# Helper for svn_commit
get_svn_diff_and_diffstat()
{
  if $git_mode; then
    svn_diff=`git diff --ignore-all-space --no-color -B -C --cached`
    svn_diff_stat=`git diff --stat --ignore-all-space --no-color -B -C --cached`
  else
    # Ignore white spaces. Can't svn diff -x -w: svn 1.4 only.
    svn_diff=`svn_diffw "$@"`
    test -z "$svn_diff" && svn_diff=`$SVN diff "$@"`
    if require_diffstat; then
      svn_diff_stat=`echo "$svn_diff" | diffstat`
    else
      svn_diff_stat='diffstat not available'
    fi
  fi
}

# Helper.  Sets the variables repos_url, git_branch, git_head, repos_root,
# extra_repos_info and using_git_svn properly.
git_get_repos_info_()
{
  # FIXME: 1st commit: "fatal: bad default revision 'HEAD'" on stderr
  git_config_list=`git config -l`
  using_git_svn=false
  case $git_config_list in #(
    *svn-remote.*.url=*)
      repos_url=`echo "$git_config_list" \
                 | sed '/^svn-remote.svn.url=\(.*\)$/!d;s//\1/'`
      using_git_svn=:
      ;; #(
    *remote.origin.url=*)
      repos_url=`echo "$git_config_list" \
                 | sed '/^remote.origin.url=\(.*\)$/!d;s//\1/'`
      ;;
  esac
  test -z "$repos_url" && repos_url='(git:unknown)'
  git_branch=`git branch | awk '/^\*/ { print substr($0, 3) }'`
  if [ x"$git_branch" = x'(no branch)' ]; then
    yesno 'You are on a detached HEAD, do you really want to continue?' \
      || return 1
  fi
  git_head=`git rev-list --pretty=format:%h HEAD --max-count=1 | sed '1d;q'`
  extra_repos_info="Git branch: $git_branch (HEAD: $git_head)"
  repos_root=$repos_url
}

# git_warn_missing_prop(PROP-NAME, SAMPLE-VALUE)
git_warn_missing_prop()
{
  if $using_git_svn; then
    warn "No $1 property set for this repository.
This is a git-svn repository, so you can set it in an SVN working copy:
  svn propset $1 $2 .
Otherwise you can just set the property in your git-svn repository:
  git config svnw.$1 $2"
  else
    warn "No $1 property set for this repository.
You can set it like this:
  git config svnw.$1 $2"
  fi
}

# Helper.  Find the `mailto' property, be it an SVN property or a git-config
# option.  Relies on the value of $change_log_dir and sets the values of
# $mailto (the value of the `mailto' property) and $to (a string to append in
# templates that contains the `To:' line, or an empty string if no mail must
# be sent).
get_mailto_property()
{
  test -d "$change_log_dir" || abort 'Internal error in get_mailto_property:
    $change_log_dir not pointing to a directory'
  if $git_mode; then
    mailto=`git config svnw.mailto`
    if [ x"$mailto" = x ] \
      && [ -f "$change_log_dir/.git/svn/git-svn/unhandled.log" ]
    then
      mailto=`grep mailto "$change_log_dir/.git/svn/git-svn/unhandled.log"`
      sed_tmp='$!d;s/^.*+dir_prop: . mailto //;s/%40/@/g;s/%2C/,/g;s/%20/ /g;'
      mailto=`echo "$mailto" | sed "$sed_tmp"`
    fi
    if [ x"$mailto" = x ]; then
      git_warn_missing_prop 'mailto' 'maintainer1@foo.com,maint2@bar.com'
    fi
  else
    mailto=`$SVN propget mailto "$change_log_dir"`
  fi

  if [ x"$mailto" = x ]; then
    test x$new_user = xyes \
    && warn "no svn property mailto found in $change_log_dir
             You might want to set default email adresses using:
             svn propset mailto 'somebody@mail.com, foobar@example.com'\
             $change_log_dir" >&2
    # Try to be VCS-compatible and find a list of mails in a *.rb.
    if [ -d "$change_log_dir/vcs" ]; then
      mailto=`grep '.@.*\..*' "$change_log_dir"/vcs/*.rb \
              | tr '\n' ' ' \
              | sed 's/^.*[["]\([^["]*@[^]"]*\)[]"].*$/\1/' | xargs`
      test x"$mailto" != x && test x$new_user = xyes \
      && notice "VCS-compat: found mailto: $mailto
                 in " "$change_log_dir"/vcs/*.rb
    fi # end VCS compat
  fi # end guess mailto

  # Ensure that emails are comma-separated.
  mailto=`echo "$mailto" | sed 's/[ ;]/,/g' | tr -s ',' | sed 's/,/, /g'`

  to=
  if [ x"$mailto" != xdont_send_mails ] && [ x"$mailto" != xnothx ]; then
    to="
To: $mailto"
  fi
}



  # ------------------------------- #
  # Hooks for standard SVN commands #
  # ------------------------------- #

# svn_commit [args...]
# Here is how the commit process goes:
#
# First we look in the arguments passed to commit:
#   If there are some files or paths, the user wants to commit these only. In
#   this case, we must search for ChangeLogs from these paths. We might find
#   more than one ChangeLog, in this case the user will be prompted to pick up
#   one.
#   Otherwise (no path passed in the command line) the user just wants to
#   commit the current working directory.
# In any case, we schedule "ChangeLog" for commit.
#
# Alright now that we know which ChangeLog to use, we look in the ChangeLog's
# directory if there is a ",svn-log" file which would mean that a previous
# commit didn't finish successfully. If there is such a file, the user is
# prompted to know whether they want to resume that commit or simply start a
# new one.
# When the user wants to resume a commit, the ",svn-log" file is loaded and we
# retrieve the value of "$@" that was saved in the file.
# Otherwise we build a template ChangeLog entry.
# Then we open the template ChangeLog entry with $EDITOR so that the user
# fills it properly.
# Finally, we commit.
# Once the commit is sent, we ask the server to know which revision was
# commited and we also retrieve the diff. We then send a mail with these.
svn_commit()
{
  here=`pwd -P`
  dry_run=false
  git_commit_all=false
  use_log_message_from_file=false
  log_message_to_use=

  # Check if the user passed some paths to commit explicitly
  # because in this case we must add the ChangeLog to the commit and search
  # the ChangeLog from the dirname of that file.
  i=0; search_from=; add_changelog=false; extra_files=
  while [ $i -lt $# ]; do
    arg=$1
    case $arg in
      --dry-run)
        dry_run=:
        shift
        i=$(($i + 1))
        continue
        ;;
      -a|--all)
        git_commit_all=:
        ;;
      --use-log-file)
        shift
        test -z "$1" && abort "$arg needs an argument"
        test -r "$1" || abort "'$1' does not seem to be readable"
        test -w "$1" || abort "'$1' does not seem to be writable"
        test -d "$1" && abort "'$1' seems to be a directory"
        use_log_message_from_file=:
        log_message_to_use=$1
        shift
        continue
        ;;
    esac
    # If the argument is a valid path: add the ChangeLog in the list of
    # files to commit
    if test -e "$arg"; then
      add_changelog=:
      if test -d "$arg"; then
        search_from_add=$arg
      else
        search_from_add=`dirname "$arg"`
      fi
      search_from="$search_from:$search_from_add"
    fi
    shift
    set dummy "$@" "$arg"
    shift
    i=$(($i + 1))
  done
  if $add_changelog; then :; else
    # There is no path/file in the command line: the user wants to commit the
    # current directory. Make it explicit now:
    extra_files=$here
  fi
  search_from=`echo "$search_from" | sed 's/^://; s/^$/./'`

  # ----------------- #
  # Find ChangeLog(s) #
  # ----------------- #

  nb_chlogs=0; change_log_dirs=
  save_IFS=$IFS; IFS=':'
  for dir in $search_from; do
    IFS=$save_IFS
    $use_changelog || break
    test -z "$dir" && dir='.'
    # First: come back to the original place
    cd "$here" || abort "Cannot cd to $here"
    cd "$dir"  || continue # Then: Enter $dir (which can be a relative path)
    found=0 
    while [ $found -eq 0 ]; do
      this_chlog_dir=`pwd -P`
      if [ -f ./ChangeLog ]; then
        found=1
        nb_chlogs=$(($nb_chlogs + 1))
        change_log_dirs="$change_log_dirs:$this_chlog_dir"
      else
        cd ..
      fi
      # Stop searching when in / ... hmz :P
      test x"$this_chlog_dir" = x/ && break
    done # end while: did we find a ChangeLog
  done # end for: find ChangeLogs in $search_from
  if [ $nb_chlogs -gt 0 ]; then
    change_log_dirs=`echo "$change_log_dirs" | sed 's/^://' | tr ':' '\n' \
                     | sort -u`
    nb_chlogs=`echo "$change_log_dirs" | wc -l`
  fi

  # Did we find a ChangeLog? More than one?
  if [ $nb_chlogs -eq 0 ] && $use_changelog; then
    if yesno 'svn-wrapper: Error: Cannot find a ChangeLog file!
You might want to create an empty one (eg: `touch ChangeLog` where appropriate)
Do you want to proceed without using a ChangeLog?'; then
      cd "$here"
      $SVN commit "$@"
      return $?
    else
      return 1
    fi
  elif [ $nb_chlogs -gt 1 ]; then
    notice "$nb_chlogs ChangeLogs were found, pick up one:"

    IFS=':'; i=0
    for a_chlog_dir in $change_log_dirs; do
      i=$(($i + 1))
      echo "$i. $a_chlog_dir/ChangeLog"
    done
    printf "Which ChangeLog do you want to use? [1-$i] "
    read chlog_no || abort 'Cannot read answer on stdin.'

    case $chlog_no in
      *[^0-9]*) abort "Invalid ChangeLog number: $chlog_no"
    esac
    test "$chlog_no" -le $i || abort "Invalid ChangeLog number: $chlog_no
                                      max value was: $i"
    test "$chlog_no" -ge 1 || abort "Invalid ChangeLog number: $chlog_no
                                     min value was: 1"
    change_log_dir=`echo "$change_log_dirs" | tr ':' '\n' | sed "${chlog_no}!d"`
  else # Only one ChangeLog found
    if $use_changelog; then
      change_log_dir=$change_log_dirs
      notice "using $change_log_dir/ChangeLog"
    fi
  fi

  if $use_changelog; then
    test -f "$change_log_dir/ChangeLog" \
      || abort "No such file or directory: $change_log_dir/ChangeLog"
    # Now we can safely schedule the ChangeLog for the commit.
    extra_files="$extra_files:$change_log_dir/ChangeLog"
  else
    change_log_dir='.' # Hack.  FIXME: Does this work in all cases?
  fi

  if [ -d "$change_log_dir/.git" ] || $git_mode; then
    SVN=git
    git_mode=:
    git_get_repos_info_
  else
    svn_st_tmp=`$SVN status "$change_log_dir"`

    # Warn for files that are not added in the repos.
    conflicts=`echo "$svn_st_tmp" | sed '/^ *$/d;
                                         /^[^?]/d;
                                         /^?.......*\/[,+]/d;
                                         /^?......[,+]/d'`
    if test x"$conflicts" != x; then
      warn "make sure you don't want to \`svn add'
            any of the following files before committing:"
      echo "$conflicts" | sed "$sed_svn_st_color"
      printf 'Type [ENTER] to continue :)' && read chiche_is_gay
    fi

    # If there are changes in an svn:externals, advise the user to commit that
    # first.
    changed_externals=`echo "$svn_st_tmp" | $AWK \
                       'function printext()
                        {
                          if (ext && !printed)
                          {
                            print this_ext "\n";
                            printed = 1;
                          }
                        }
                        BEGIN     { this_ext = ""; ext = 0; ext_modified = 0; }
                        /^Performing status on external/ {
                          ext = 1;
                          sub(/.* at ./, ""); sub(/.$/, ""); this_ext = $0;
                          printed = 0;
                        }
                        /^[ADMR]/ { ext_modified = ext; printext(); }
                        /^.[M]/   { ext_modified = ext; printext(); }
                        END       { exit ext_modified; }'`
    if [ $? -ne 0 ]; then
      warn "the following external items have local modifications:
$changed_externals"
      yesno "You are advised to commit them separately first. Continue anyway?" \
      || return 1
    fi

    # Detect unresolved conflicts / missing files.
    conflicts=`echo "$svn_st_tmp" | sed '/^[C!]/!d'`
    test x"$conflicts" != x && abort "there are unresolved conflicts (\`C')
                                      and/or missing files (\`!'):
                                      $conflicts"

    svn_info_tmp=`$SVN info "$change_log_dir"`
    test $? -ne 0 && abort "Failed to get svn info on $change_log_dir"
    repos_root=`echo "$svn_info_tmp" | sed '/^Repository Root: /!d;s///'`
    repos_url=`echo "$svn_info_tmp" | sed '/^URL: /!d;s///'`
    # It looks like svn <1.3 didn't display a "Repository Root" entry.
    test -z "$repos_root" && repos_root=$repos_url
  fi

  cd "$here"

  YYYY=`date '+%Y'`
  MM=`date '+%m'`
  DD=`date '+%d'`

  # VCS-compat: handle user option 'new_user'
  new_user='yes'
  grep '^new_user: false' ~/.vcs >/dev/null 2>/dev/null && new_user='no'

  edit_changelog=:
  tmp_log="$change_log_dir/,svn-log"
  $use_log_message_from_file \
    && tmp_log=$log_message_to_use \
    && edit_changelog=false

  if [ -f "$tmp_log" ] \
      && { $use_log_message_from_file \
           || yesnewproceed "It looks like the last commit did not\
 terminate successfully.
Would you like to resume it or proceed immediately?"; }; then
    case $yesnoproceed_res in
      *proceed)   edit_changelog=false;;
    esac
    if test x"$yesnoproceed_res" = xupproceed; then
      svn_update "$@" || abort 'update failed'
    fi
    echo 'Resuming ...'
    internal_tags=`sed '/^--- Internal stuff, DO NOT change please ---$/,$!d' \
                     "$tmp_log"`
    saved_args=`echo "$internal_tags" | sed '/^args: */!d;s///'`
    extra_files=`echo "$internal_tags" | sed '/^extra_files: */!d;s///'`
    if [ x"$saved_args" != x ]; then
      if [ x"$*" != x ] && [ x"$saved_args" != x"$*" ]; then
        warn "overriding arguments:
              you invoked $me with the following arguments: $@
              they have been replaced by these: $saved_args"
        set dummy $saved_args
        shift
      else
        notice "setting the following arguments: $saved_args"
        set dummy $saved_args
        shift
      fi
    elif [ x"$*" != x ]; then
        warn "overriding arguments:
              you invoked $me with the following arguments: $@
              they have been dropped"
    fi

    for i; do
      case $i in
        -a|--all)
          git_commit_all=:
          if [ $git_mode ]; then
            (cd $change_log_dir && git add -v -u) || abort '`git add -v -u` failed'
          fi
          ;;
      esac
    done

    get_svn_diff_and_diffstat "$@"

    # Update the file with the new diff/diffstat in case it changed.
    $AWK 'BEGIN {
            tlatbwbi_seen = 0;
            ycewah_seen = 0;
          }
          /^--This line, and those below, will be ignored--$/ {
            tlatbwbi_seen = 1;
          }
          /^	Your ChangeLog entry will appear here\.$/ {
            if (tlatbwbi_seen) ycewah_seen = 1;
          }
          {
            if (ycewah_seen != 2) print;
            if (ycewah_seen == 1) ycewah_seen = 2;
          }
          END {
            if (tlatbwbi_seen == 0)
            {
              print "--This line, and those below, will be ignored--\n\n" \
                    "	Your ChangeLog entry will appear here.";
            }
          }' "$tmp_log" >"$tmp_log.tmp"
    echo "
---
$svn_diff_stat

$svn_diff

$internal_tags" >>"$tmp_log.tmp"
    mv -f "$tmp_log.tmp" "$tmp_log" || abort "failed to write '$tmp_log'"

  else # Build the template message.

    # ------------------------------------ #
    # Gather info for the template message #
    # ------------------------------------ #

    if $git_mode; then
      projname=`git config svnw.project`
      if [ x"$projname" = x ] \
        && [ -f "$change_log_dir/.git/svn/git-svn/unhandled.log" ]
      then
        projname=`grep project "$change_log_dir/.git/svn/git-svn/unhandled.log"`
        sed_tmp='$!d;s/^.*+dir_prop: . project //'
        projname=`echo "$projname" | sed "$sed_tmp"`
      fi
      if [ x"$projname" = x ]; then
        git_warn_missing_prop 'project' 'myproj'
      fi
    else
      projname=`$SVN propget project "$change_log_dir"`
    fi
    # Try to be VCS-compatible and find a project name in a *.rb.
    if [ x"$projname" = x ] && [ -d "$change_log_dir/vcs" ]; then
      projname=`sed '/common_commit/!d;s/.*"\(.*\)<%= rev.*/\1/' \
                    "$change_log_dir"/vcs/*.rb`
      test x"$projname" != x && test x$new_user = xyes \
      && notice "VCS-compat: found project name: $projname
                 in " "$change_log_dir"/vcs/*.rb
    fi
    test x"$projname" != x && projname=`echo "$projname" | sed '/[^ ]$/s/$/ /'`

    get_mailto_property

    test -z "$FULLNAME" && FULLNAME='Type Your Name Here' \
    && warn_env FULLNAME
    test -z "$EMAIL" && EMAIL='your.mail.here@FIXME.com' && warn_env EMAIL

    if $git_mode; then
      if $git_commit_all; then
        (cd $change_log_dir && git add -v -u) || abort '`git add -v -u` failed'
      fi
      my_git_st=`git diff -C --raw --cached`
      test $? -eq 0 || abort 'git diff failed'
      # Format: ":<old_mode> <new_mode> <old_sha1> <new_sha1> <status>[
      #          <similarity score>]\t<file-name>"
      change_log_files=`echo "$my_git_st" | sed '
        t dummy_sed_1
        : dummy_sed_1
        s/^:[0-7 ]* [0-9a-f. ]* M[^	]*	\(.*\)$/	* \1: ./;         t
        s/^:[0-7 ]* [0-9a-f. ]* A[^	]*	\(.*\)$/	* \1: New./;      t
        s/^:[0-7 ]* [0-9a-f. ]* D[^	]*	\(.*\)$/	* \1: Remove./;   t
        s/^:[0-7 ]* [0-9a-f. ]* R[^	]*	\([^	]*\)	\(.*\)$/	* \2: Rename from \1./;t
        s/^:[0-7 ]* [0-9a-f. ]* C[^	]*	\([^	]*\)	\(.*\)$/	* \2: Copy from \1./;t
        s/^:[0-7 ]* [0-9a-f. ]* T[^	]*	\(.*\)$/	* \1: ./;         t
        s/^:[0-7 ]* [0-9a-f. ]* X[^	]*	\(.*\)$/	* \1: ???./;      t
        s/^:[0-7 ]* [0-9a-f. ]* U[^	]*	\(.*\)$/	* \1: UNMERGED./; t
      '`
    else
      # --ignore-externals appeared after svn 1.1.1
      my_svn_st=`$SVN status --ignore-externals "$@" \
                 || $SVN status "$@" | sed '/^Performing status on external/ {
                                              d;q
                                            }'`

      # Files to put in the ChangeLog entry.
      change_log_files=`echo "$my_svn_st" | sed '
        t dummy_sed_1
        : dummy_sed_1
        s/^M......\(.*\)$/	* \1: ./;       t
        s/^A......\(.*\)$/	* \1: New./;    t
        s/^D......\(.*\)$/	* \1: Remove./; t
        d
      '`
    fi
    if [ x"$change_log_files" = x ]; then
      yesno 'Nothing to commit, continue anyway?' || return 1
    fi

    change_log_files=`echo "$change_log_files" | sort -u`

    get_svn_diff_and_diffstat "$@"

    # Get any older svn-log out of the way.
    test -f "$tmp_log" && mv "$tmp_log" `get_unique_file_name "$tmp_log"`
    # If we can't get an older svn-log out of the way, find a new name...
    test -f "$tmp_log" && tmp_log=`get_unique_file_name "$tmp_log"`
    if [ x$new_user = no ]; then
      commit_instructions='
Instructions:
 - Fill the ChangeLog entry.
 - If you feel like, write a comment in the "Comment:" section.
   This comment will only appear in the email, not in the ChangeLog.
   By default only the location of the repository is in the comment.
 - Some tags will be replaced. Tags are of the form: <TAG>. Unknown
   tags will be left unchanged.
 - The tag <REV> may only be used in the Subject.
 - Your ChangeLog entry will be used as commit message for svn.'
    else
      commit_instructions=
    fi
    r_before_rev=r
    $git_mode && r_before_rev=
    test -z "$extra_repos_info" || extra_repos_info="
  $extra_repos_info"
    echo "\
--You must fill this file correctly to continue--           -*- vcs -*-
Title: 
Subject: ${projname}$r_before_rev<REV>: <TITLE>
From: $FULLNAME <$EMAIL>$to

Comment:
  URL: $repos_url$extra_repos_info

ChangeLog:

<YYYY>-<MM>-<DD>  $FULLNAME  <$EMAIL>

	<TITLE>
$change_log_files

--This line, and those below, will be ignored--
$commit_instructions
--Preview of the message that will be sent--

URL: $repos_url$extra_repos_info
Your comments (if any) will appear here.

ChangeLog:
$YYYY-$MM-$DD  $FULLNAME  <$EMAIL>

	Your ChangeLog entry will appear here.

---
$svn_diff_stat

$svn_diff" >"$tmp_log"

    echo "
--- Internal stuff, DO NOT change please ---
args: $@" >>"$tmp_log"
    echo "extra_files: $extra_files
vi: ft=diff:noet:tw=76:" >>"$tmp_log"

  fi # end: if svn-log; then resume? else create template
  $edit_changelog && $EDITOR "$tmp_log"

  # ------------------ #
  # Re-"parse" the log #
  # ------------------ #

  # hmz this section is a bit messy...
  # helper string... !@#$%* escaping \\\\\\...
  sed_escape='s/\\/\\\\/g;s/@/\\@/g;s/&/\\\&/g'
  sed_eval_tags="s/<MM>/$MM/g; s/<DD>/$DD/g; s/<YYYY>/$YYYY/g"
  full_log=`sed '/^--*This line, and those below, will be ignored--*$/,$d;
                 /^--You must fill this/d' "$tmp_log"`
  chlog_entry=`echo "$full_log" | sed '/^ChangeLog:$/,$!d; //d'`
  ensure_not_empty 'ChangeLog entry' "$chlog_entry"
  full_log=`echo "$full_log" | sed '/^ChangeLog:$/,$d'`
  mail_comment=`echo "$full_log" | sed '/^Comment:$/,$!d; //d'`
  full_log=`echo "$full_log" | sed '/^Comment:$/,$d'`
  mail_title=`echo "$full_log" | sed '/^Title: */!d;s///;'`
  ensure_not_empty 'commit title' "$mail_title"
  # Add a period at the end of the title.
  mail_title=`echo "$mail_title" | sed -e '/ *[.!?]$/!s/ *$/./' \
                                       -e "$sed_eval_tags; $sed_escape"`
  sed_eval_tags="$sed_eval_tags; s@<TITLE>\\.*@$mail_title@g"
  mail_comment=`echo "$mail_comment" | sed "$sed_eval_tags"`
  raw_chlog_entry=$chlog_entry # ChangeLog entry without tags expanded
  chlog_entry=`echo "$chlog_entry" | sed "$sed_eval_tags; 1{
  /^ *$/d
  }"`
  mail_subject=`echo "$full_log" | sed '/^Subject: */!d;s///'`
  ensure_not_empty 'mail subject' "$mail_subject"
  mail_to=`echo "$full_log" | sed '/^To:/!d'`
  send_a_mail=:
  if test x"$mail_to" = x; then
    send_a_mail=false
  else
    mail_to=`echo "$mail_to" | sed 's/^To: *//;s///'`
    # If there is a <MAILTO> in the 'To:' line, we must expand it.
    case $mail_to in #(
      *'<MAILTO>'*)
        get_mailto_property
        # Are we meant to send a mail?
        case $to in #(
          '') # No, don't send a mail.
            mail_to=
            send_a_mail=false
            ;; #(
          *) # Yes, send a mail.
            mail_to=`echo "$mail_to" | sed "s#<MAILTO>#$mailto#g"`
            ;;
        esac
    esac
    $send_a_mail && ensure_not_empty '"To:" field of the mail' "$mail_to"
  fi

  test -z "$FULLNAME" && warn_env FULLNAME && FULLNAME=$USER
  test -z "$EMAIL" && warn_env EMAIL && EMAIL=$USER
  myself=`echo "$FULLNAME <$EMAIL>" | sed "$sed_escape"`
  mail_from=`echo "$full_log" | sed "/^From: */!d;s///;s@<MYSELF>@$myself@g"`
  ensure_not_empty '"From:" field of the mail' "$mail_from"

  # ------------------------------------ #
  # Sanity checks on the ChangeLog entry #
  # ------------------------------------ #

  if echo "$chlog_entry" | grep '<REV>' >/dev/null; then
    warn 'Using the tag <REV> anywhere else than in the Subject is deprecated.'
    yesno 'Continue anyway?' || return 1
  fi

  if echo "$chlog_entry" | grep ': \.$' >/dev/null; then
    warn 'It looks like you did not fill all entries in the ChangeLog:'
    echo "$chlog_entry" | grep ': \.$' 
    yesno 'Continue anyway?' || return 1
  fi

  if echo "$chlog_entry" | grep '^--* Internal stuff' >/dev/null; then
    warn "It looks like you messed up the delimiters and I did not properly
    find your ChangeLog entry.  Here it is, make sure it is correct:"
    echo "$chlog_entry"
    yesno 'Continue anyway?' || return 1
  fi

  if echo "$chlog_entry" | grep -i 'dont[^a-z0-9]' >/dev/null; then
    warn "Please avoid typos such as ${lred}dont$std instead of\
 ${lgreen}don't$std:"
    echo "$chlog_entry" | grep -n -i 'dont[^a-z0-9]' \
      | sed "s/[dD][oO][nN][tT]/$lred&$std/g"
    yesno 'Continue anyway?' || return 1
  fi

  if echo "$chlog_entry" | grep -i 'cant[^a-z0-9]' >/dev/null; then
    warn "Please avoid typos such as ${lred}cant$std instead of\
 ${lgreen}can't$std:"
    echo "$chlog_entry" | grep -n -i 'cant[^a-z0-9]' \
      | sed "s/[cC][aA][nN][tT]/$lred&$std/g"
    yesno 'Continue anyway?' || return 1
  fi

  if echo "$chlog_entry" | grep '^.\{80,\}' >/dev/null; then
    warn 'Please avoid long lines in your ChangeLog entry (80 columns max):'
    echo "$chlog_entry" | grep '^.\{80,\}'
    yesno 'Continue anyway?' || return 1
  fi

  if echo "$mail_title" | grep -i '^[a-z][a-z]*ed[^a-z]' >/dev/null; then
    warn 'ChangeLog entries should be written in imperative form:'
    echo "$mail_title" | grep -i '^[a-z][a-z]*ed[^a-z]' \
      | sed "s/^\\([a-zA-Z][a-zA-Z]*ed\\)\\([^a-zA-Z]\\)/$lred\\1$std\\2/"
    yesno 'Continue anyway?' || return 1
  fi

  # Check whether the user passed -m | --message
  i=0
  while [ $i -lt $# ]; do
    arg=$1
    # This is not really a reliable way of knowing whether -m | --message was
    # passed but hum... Let's assume it'll do :s
    if [ x"$arg" = 'x-m' ] || [ x"$arg" = 'x--message' ]; then
      my_message=$2
    fi
    shift
    set dummy "$@" "$arg"
    shift
    i=$(($i + 1))
  done
  if [ x"$my_message" = x ]; then
    # The title must not be indented in the commit message and must be
    # followed by a blank line.  This yields much better results with most
    # VC-viewer (especially for Git but including for SVN, such as Trac for
    # instance).  We assume that the title will always be on the 1st line.
    sed_git_title="1s@^[	 ]*<TITLE>\\.*@$mail_title\\
@g; $sed_eval_tags"
    # First, remove empty lines at the beginning, if any.
    # Remove also the date information (useless in commit messages)
    my_message=`echo "$raw_chlog_entry" \
                | sed -e '1,4 {
                            /^<YYYY>-<[MD][MD]>-<[DM][DM]>/d
                            /^[1-9][0-9][0-9][0-9]-[0-9][0-9]*-[0-9][0-9]*/d
                            /^	and .*<.*@.*>$/d
                            /^ *$/d
                          }' \
                | sed -e "$sed_git_title" \
                      -e "$sed_eval_tags; 1{
                            /^ *$/d
                          }"`
  else
    notice 'you are overriding the commit message.'
  fi

  # Show suspicious whitespace additions with Git.
  $git_mode && git diff --cached --check

  if $dry_run; then
    proposal_file=',proposal'
    test -f "$proposal_file" \
      && proposal_file=`get_unique_file_name "$proposal_file"`
    sed_tmp='s/<REV>/???/g;s/\([^.]\) *\.$/\1/'
    mail_subject=`echo "$mail_subject" | sed "$sed_eval_tags; $sed_tmp"`
    to=
    if [ x"$mailto" != xdont_send_mails ] && [ x"$mailto" != xnothx ]; then
      to="
To: $mailto"
    fi
    echo "\
From: $mail_from$to
Subject: $mail_subject

$mail_comment

ChangeLog:
$chlog_entry

---
$svn_diff_stat

$svn_diff" >"$proposal_file"
    notice "A proposal of your commit was left in '$proposal_file'"
    return 0
  fi

  # Are you sure?
  if $git_mode; then
    $git_commit_all \
    || notice 'You are using git, unlike SVN, do not forget to git add your
            changes'
  fi

  # Change edit_changelog so that we're asking the confirmation below.
  $use_log_message_from_file && edit_changelog=: \
    && notice "You are about to commit the following change:
$mail_title"

  $edit_changelog \
    && {
      yesno 'Are you sure you want to commit?' \
        || return 1
    }

  # Add the ChangeLog entry
  old_chlog=`get_unique_file_name "$change_log_dir/ChangeLog.old"`
  mv "$change_log_dir/ChangeLog" "$old_chlog" || \
    abort 'Could not backup ChangeLog'
  trap "echo SIGINT; mv \"$old_chlog\" \"$change_log_dir/ChangeLog\";
        exit 130" $SIGINT
  echo "$chlog_entry" >"$change_log_dir/ChangeLog"
  echo >>"$change_log_dir/ChangeLog"
  cat "$old_chlog" >>"$change_log_dir/ChangeLog"

  # Add extra files such as cwd or ChangeLog to the commit.
  tmp_sed='s/ /\\ /g' # Escape spaces for the shell.
  if $git_mode && $use_changelog; then
    # Schedule the ChangeLog for the next commit
    (cd "$change_log_dir" && git add ChangeLog) \
      || abort 'failed to git add the ChangeLog'
    extra_files=
  else
    extra_files=`echo "$extra_files" | sed "$tmp_sed" | tr ':' '\n'`
  fi

  # Always sign the commits with Git (but not with git-svn).
  $using_git_svn || $git_mode && set dummy --signoff "$@" && shift

  # Update the Git index if necessary (just in case the user changed his
  # working copy in the mean time)
  if $git_mode && $git_commit_all; then
    (cd $change_log_dir && git add -v -u) || abort '`git add -v -u` failed'
  fi

  # --Commit-- finally! :D
  $SVN commit -m "$my_message" "$@" $extra_files || {
    svn_commit_rv=$?
    mv "$old_chlog" "$change_log_dir/ChangeLog"
    abort "Commit failed, $SVN returned $svn_commit_rv"
  }

  printf 'Getting the revision number... '
  if $git_mode; then
    REV=`git rev-list --pretty=format:%h HEAD --max-count=1 | sed '1d;q'`
  else
    svn_info_tmp=`$SVN info "$change_log_dir/ChangeLog"`
    REV=`echo "$svn_info_tmp" | sed '/^Revision: /!d;s///'`
    test -z "$REV" && REV=`echo "$svn_info_tmp" \
                             | sed '/^Last Changed Rev: /!d;s///'`
  fi
  test -z "$REV" && abort 'Cannot detect the current revision.'
  echo "$REV"

  # Let's make sure we have the real diff by asking the ChangeSet we've just
  # committed to the server.

  # Backup the old stuff in case we fail to get the real diff from the server
  # for some reason...
  save_svn_diff=$svn_diff
  save_svn_diff_stat=$svn_diff_stat

  if $git_mode; then
    svn_diff=`git diff --ignore-all-space --no-color -C 'HEAD^' HEAD`
    svn_diff_stat=`git diff --stat --ignore-all-space --no-color -C 'HEAD^' HEAD`
    $using_git_svn &&
      notice 'Do not forget to use `git-svn dcommit` to push your commits in SVN'
  else
    # Fetch the ChangeSet and filter out the ChangeLog entry. We don't use
    # svn diff -c because this option is not portable to older svn versions.
    REV_MINUS_ONE=$(($REV - 1))
    svn_diff=`svn_diffw -r"$REV_MINUS_ONE:$REV" "$repos_root" \
             | $AWK '/^Index: / { if (in_chlog) in_chlog = 0; }
                    /^Index: .*ChangeLog$/ { in_chlog = 1 }
                    { if (!in_chlog) print }'`
    if [ x"$svn_diff" = x ]; then
      svn_diff=$save_svn_diff
      svn_diff_stat=$save_svn_diff_stat
    else
      if require_diffstat; then
        svn_diff_stat=`echo "$svn_diff" | diffstat`
      else
        svn_diff_stat='diffstat not available'
      fi
    fi
  fi

  # Expand <REV> and remove the final period from the mail subject if there is
  # only one period.
  sed_tmp="s/<REV>/$REV/g;"'s/\([^.]\) *\.$/\1/'
  mail_subject=`echo "$mail_subject" | sed "$sed_eval_tags; $sed_tmp"`

  mail_file=`get_unique_file_name "$change_log_dir/+mail"`
  echo "\
From: $mail_from
To: $mail_to
Subject: $mail_subject

$mail_comment

ChangeLog:
$chlog_entry

---
$svn_diff_stat

$svn_diff" | sed 's/^\.$/ ./' >"$mail_file"
    # We change lines with only a `.' because they could mean "end-of-mail"

  # Send the mail
  if $send_a_mail; then
    trap 'echo SIGINT; exec < /dev/null' $SIGINT
    # FIXME: Move the mail to the +committed right now, in case the user
    # CTLR+C the mail-sending-thing, so that the mail will be properly saved
    # their.
    my_sendmail "$mail_file" "$mail_subject" "$mail_to" \
                "X-svn-url: $repos_root
                 X-svn-revision: $REV"
  fi # end do we have to send a mail?
  rm -f "$tmp_log"
  rm -f "$old_chlog"
  save_mail_file=`echo "$mail_file" | sed 's/+//'`
  mkdir -p "$change_log_dir/+committed" \
    || warn "Couldn't mkdir -p $change_log_dir/+committed"
  if [ -d "$change_log_dir/vcs" ] \
     || [ -d "$change_log_dir/+committed" ]
  then
    mkdir -p "$change_log_dir/+committed/$REV" \
      && mv "$mail_file" "$change_log_dir/+committed/$REV/mail"
  fi
  return $svn_commit_rv
}

# svn_diffw [args...]
svn_diff()
{
  # Ignore white spaces.
  if $git_mode; then
    git diff -C "$@"
  else
    diffarg='-u'
    # Can't svn diff -x -w: svn 1.4 only.
    # Moreover we *MUST* use -x -uw, not -x -u -w or -x -u -x -w ...
    # Hence the hack to stick both diff arguments together...
    # No comment :)
    test x"$1" = x'--SVNW-HACK-w' && shift && diffarg='-uw'
    $SVN diff --no-diff-deleted --diff-cmd $DIFF -x $diffarg "$@"
  fi
}

# svn_diffw [args...]
svn_diffw()
{
  # Ignore white spaces.
  if $git_mode; then
    svn_diff --ignore-all-space "$@"
  else
    svn_diff --SVNW-HACK-w "$@"
  fi
}

# svn_mail REV [mails...]
svn_mail()
{
  test $# -lt 1 && abort "Not enough arguments provided;
                          Try 'svn help mail' for more info."
  case $1 in
    PREV)
      if $git_mode; then
        REV=`git rev-list --pretty=format:%h 'HEAD^' --max-count=1 | sed '1d;q'`
      else
        REV=`svn_revision || abort 'Cannot get current revision number'`
        test -z "$REV" && abort 'Cannot get current revision number'
        if [ "$REV" -lt 1 ]; then
          abort 'No previous revision.'
        fi
        REV=$(($REV - 1))
      fi
      ;;
    HEAD)
      REV=`svn_revision || abort 'Cannot get current revision number'`
      test -z "$REV" && abort 'Cannot get current revision number'
      ;;
    *) REV=$1;;
  esac
  shift

  found_committed=0; found=0 
  while [ $found -eq 0 ]; do
    this_chlog_dir=`pwd -P`
    if [ -d ./+committed ]; then
      found_committed=1
      if [ -d ./+committed/$REV ]; then
        found=1
      else
        cd ..
      fi
    else
      cd ..
    fi
    # Stop searching when in / ... hmz :P
    test x`pwd` = x/ && break
  done
  if [ $found -eq 0 ]; then
    if [ $found_committed -eq 0 ]; then
      abort 'Could not find the +committed directory.'
    else
      abort "Could not find the revision $REV in +committed."
    fi
    abort 'Internal error (should never be here).'
  fi

  mail_file=; subject=; to=
  if [ -f ./+committed/$REV/mail ]; then
    # svn-wrapper generated file
    mail_file="./+committed/$REV/mail"
    subject=`sed '/^Subject: /!d;s///' $mail_file | sed '1q'`
    to=`sed '/^To: /!d;s///' $mail_file | sed '1q'`
  elif [ -f ./+committed/$REV/,iform ] && [ -f ./+committed/$REV/,message ]
  then
    # VCS-generated file
    subject=`sed '/^Subject: /!d;s///;s/^"//;s/"$//' ./+committed/$REV/,iform \
             | sed "s/<%= *rev *%>/$REV/g"`
    to=`sed '/^To:/,/^[^-]/!d' ./+committed/$REV/,iform | sed '1d;s/^- //;$d' \
        | xargs | sed 's/  */, /g'`
    mail_file=`get_unique_file_name "$TMPDIR/mail.r$REV"`
    echo "From: $FULLNAME <$EMAIL>
To: $to
Subject: $subject
" >"$mail_file" || abort "Cannot create $mail_file"
    cat ./+committed/$REV/,message >>"$mail_file" \
    || abort "Cannot copy ./+committed/$REV/,message in $mail_file"
  else
    abort "Couldn't find the mail to re-send in `pwd`/+committed/$REV"
  fi
  if [ $# -gt 0 ]; then
    to=`echo "$*" | sed 's/  */, /g'`
  fi

  test -z "$to" && abort 'Cannot find the list of recipients.
                            Please report this bug.'
  test -z "$subject" && abort 'Cannot find the subject of the mail.
                                 Please report this bug.'

  if yesno "Re-sending the mail of r$REV
Subject: $subject
To: $to
Are you sure?"; then :; else
    return 1
  fi

  if $git_mode; then
    git_get_repos_info_
  else
    svn_info_tmp=`$SVN info`
    test $? -ne 0 && abort "Failed to get svn info on `pwd`"
    repos_root=`echo "$svn_info_tmp" | sed '/^Repository Root: /!d;s///'`
    repos_url=`echo "$svn_info_tmp" | sed '/^URL: /!d;s///'`
    # It looks like svn <1.3 didn't display a "Repository Root" entry.
    test -z "$repos_root" && repos_root=$repos_url
  fi

  my_sendmail "$mail_file" "$subject" "$to" \
              "X-svn-url: $repos_url
               X-svn-revision: $REV"
}

# svn_version
svn_version()
{
  echo "Using svn-wrapper v$version-g$revision (C) SIGOURE Benoit [GPL]"
}

# has_prop prop-name [path]
# return value: 0 -> path has the property prop-name set.
#               1 -> path has no property prop-name.
#               2 -> svn error.
has_prop()
{
  hp_plist=`$SVN proplist "$2"`
  test $? -ne 0 && return 2
  hp_res=`echo "$hp_plist" | sed "/^ *$1\$/!d"`
  test -z "$hp_res" && return 1
  return 0
}

# svn_propadd prop-name prop-val [path]
svn_propadd()
{
  if $git_mode; then
    abort 'propadd is only for SVN, not for Git.'
  fi
  test $# -lt 2 \
  && abort 'Not enough arguments provided;
            try `svn help propadd` for more info'
  test $# -gt 3 \
  && abort 'Too many arguments provided;
            try `svn help propadd` for more info'

  path=$3
  test -z "$path" && path='.' && set dummy "$@" '.' && shift
  has_prop "$1" "$3" || {
    test $? -eq 2 && return 1 # svn error
    # no property found:
    yesno "'$path' has no property named '$1', do you want to add it?" \
    && $SVN propset "$@"
    return $?
  }

  current_prop_val=`$SVN propget "$1" "$3"`
  test $? -ne 0 && abort "Failed to get the current value of property '$1'."

  $SVN propset "$1" "$current_prop_val
$2" "$3" >/dev/null || abort "Failed to add '$3' in the property '$1'."

  current_prop_val=`$SVN propget "$1" "$3" || echo "$current_prop_val
$2"`
  echo "property '$1' updated on '$path', new value:
$current_prop_val"
}

# svn_propsed prop-name sed-script [path]
svn_propsed()
{
  if $git_mode; then
    abort 'propsed is only for SVN, not for Git.'
  fi
  test $# -lt 2 \
  && abort 'Not enough arguments provided;
            try `svn help propsed` for more info'
  test $# -gt 3 \
  && abort 'Too many arguments provided;
            try `svn help propsed` for more info'

  path=$3
  test -z "$path" && path='.'
  has_prop "$1" "$3" || {
    test $? -eq 2 && return 1 # svn error
    # no property found:
    abort "'$path' has no property named '$1'."
  }

  prop_val=`$SVN propget "$1" "$3"`
  test $? -ne 0 && abort "Failed to get the current value of property '$1'."

  prop_val=`echo "$prop_val" | sed "$2"`
  test $? -ne 0 && abort "Failed to run the sed script '$2'."

  $SVN propset "$1" "$prop_val" "$3" >/dev/null \
  || abort "Failed to update the property '$1' with value '$prop_val'."

  new_prop_val=`$SVN propget "$1" "$3" || echo "$prop_val"`
  echo "property '$1' updated on '$path', new value:
$new_prop_val"
}

# svn_revision [args...]
svn_revision()
{
  if $git_mode; then
    short=`git rev-list --pretty=format:%h HEAD --max-count=1 | sed '1d;q'`
    long=`git rev-list --pretty=format:%H HEAD --max-count=1 | sed '1d;q'`
    echo "$short ($long)"
  else
    svn_revision_info_out=`$SVN info "$@"`
    svn_revision_rv=$?
    echo "$svn_revision_info_out" | sed '/^Revision: /!d;s///'
    return $svn_revision_rv
  fi
}

# svn_ignore [paths]
svn_ignore()
{
  if [ $# -eq 0 ]; then  # Simply display ignore-list.
    if $git_mode; then
      test -f .gitignore && cat .gitignore
    else
      $SVN propget 'svn:ignore'
    fi
  elif [ $# -eq 1 ]; then
    b=`basename "$1"`
    d=`dirname "$1"`
    if $git_mode; then
      echo "$b" >>"$d/.gitignore"
      git add "$d/.gitignore"
      notice 'files ignored in this directory:'
      cat "$d/.gitignore"
    else
      svn_propadd 'svn:ignore' "$b" "$d"
    fi
  else                   # Add arguments in svn:ignore.
    # This part is a bit tricky:
    # For each argument, we find all the other arguments with the same dirname
    # $dname and we svn:ignore them all in $dname.
    while [ $# -ne 0 ]; do
      arg=$1
      dname=`dirname "$1"`
      files=`basename "$1"`
      shift
      j=0; argc=$#
      while [ $j -lt $argc ] && [ $# -ne 0 ]; do
        this_arg=$1
        shift
        this_dname=`dirname "$this_arg"`
        this_file=`basename "$this_arg"`
        if [ x"$dname" = x"$this_dname" ]; then
          files="$files
$this_file"
        else
          set dummy "$@" "$this_arg"
          shift
        fi
        j=$(($j + 1))
      done
      if $git_mode; then
        echo "$files" >>"$dname"/.gitignore
        git add "$dname"/.gitignore
        notice "files ignored in $dname:"
        cat "$dname"/.gitignore
      else
        svn_propadd 'svn:ignore' "$files" "$dname"
      fi
    done
  fi
}

# svn_help
svn_help()
{
  if [ $# -eq 0 ]; then
    svn_version
    $SVN help
    rv=$?
    echo '
Additionnal commands provided by svn-wrapper:
  diffstat (ds)
  diffw (dw)
  ignore
  mail
  propadd (padd, pa) -- SVN only
  proposal
  propsed (psed) -- SVN only
  revision (rev)
  touch
  selfupdate (selfup)
  version'
    return $rv
  else
    case $1 in
      commit | ci)
        $SVN help commit | sed '/^Valid options:/i\
Extra options provided by svn-wrapper:\
\  --dry-run                : do not commit, simply generate a patch with what\
\                             would have been comitted.\
\  --use-log-file FILE      : extract the ChangeLog entry from FILE.  This\
\                             entry must be formated in a similar fashion to\
\                             what svn-wrapper usually asks you to fill in.\
\                             The FILE needs to be writable and will be\
\                             removed by svn-wrapper upon success.\

' 
        ;;
      diffstat | ds)
        require_diffstat
        echo 'diffstat (ds): Display the histogram from svn diff-output.'
        $SVN help diff | sed '1d;
                              s/differences*/histogram/;
                              2,35 s/diff/diffstat/g'
        ;;
      diffw | dw)
        echo "diffw (dw): Display the differences without taking whitespaces\
 into account."
 $SVN help diff | sed '1d;
                       2,35 s/diff\([^a-z]\)/diffw\1/g;
                       /--diff-cmd/,/--no-diff-deleted/d'
        ;;
      ignore)
        what='svn:ignore property'
        $git_mode && what='.gitignore file'
        cat <<EOF
ignore: Add some files in the $what.
usage: 1. ignore [PATH]
       2. ignore FILE [FILES...]

 1. Display the value of $what on [PATH].
 2. Add some files in the $what of the directory containing them.

When adding ignores, each pattern is ignored in its own directory, e.g.:
  $bme ignore dir/file "d2/*.o"
Will put 'file' in the $what of 'dir' and '*.o' in the
$what of 'd2'

Valid options:
  None.
EOF
        ;;
      mail)
        echo 'mail: Resend the mail of a given commit.
usage: mail REV [emails]

REV must have an email file associated in +committed/REV.
REV can also be PREV or HEAD.

By default the mail is sent to same email addresses as during the original
commit unless more arguments are given.'
        ;;
      propadd | padd | pa)
        echo 'propadd (padd, pa): Add something in the value of a property.
usage: propadd PROPNAME PROPVAL PATH
This command only works in SVN mode.

PROPVAL will be appended at the end of the property PROPNAME.

Valid options:
  None.'
        ;;
      proposal)
        echo 'proposal: Alias for: commit --dry-run.
See: svn help commit.'
        ;;
      propsed | psed)
        echo 'propsed (psed): Edit a property with sed.
usage: propsed PROPNAME SED-ARGS PATH
This command only works in SVN mode.

eg: svn propsed svn:externals "s/http/https/" .

Valid options:
  None.'
        ;;
      revision | rev)
        echo 'revision (rev): Display the revision number of a local or remote item.'
        $SVN help info | sed '1d;
                              s/information/revision/g;
                              s/revision about/the revision of/g;
                              2,35 s/info/revision/g;
                              /-xml/d'
        ;;
      touch)
        echo 'touch: Touch a file and svn add it.
usage: touch FILE [FILES]...

Valid options:
  None.'
        ;;
      selfupdate | selfup | self-update | self-up)
        echo 'selfupdate (selfup): Attempt to update svn-wrapper.sh
usage: selfupdate

Valid options:
  None.'
        ;;
      version)
        echo 'version: Display the version info of svn and svn-wrapper.
usage: version

Valid options:
  None.'
        ;;
      *) $SVN help "$@";;
    esac
  fi
}

# svn_status [args...]
svn_status()
{
  if $git_mode; then
    git status "$@"
    return $?
  fi
  svn_status_out=`$SVN status "$@"`
  svn_status_rv=$?
  test -z "$svn_status_out" && return $svn_status_rv
  echo "$svn_status_out" | sed "$sed_svn_st_color"
  return $svn_status_rv
}

# svn_update [args...]
svn_update()
{
  svn_update_out=`$SVN update "$@"`
  svn_update_rv=$?
  echo "$svn_update_out" | sed "$sed_svn_up_colors"
  return $svn_update_rv
}

  # ------------------- #
  # `main' starts here. #
  # ------------------- #

# Define colors if stdout is a tty.
if test -t 1; then
  set_colors
else # stdout isn't a tty => don't print colors.
  set_nocolors
fi

# Consider this as a sed function :P.
sed_svn_st_color="
    t dummy_sed_1
    : dummy_sed_1
    s@^?\\(......\\)+@+\\1+@
    s@^?\\(......\\)\\(.*/\\)+@+\\1\\2+@
    s@^?\\(......\\),@,\\1,@
    s@^?\\(......\\)\\(.*/\\),@,\\1\\2,@
    s/^\\(.\\)C/\\1${lred}C${std}/
    t dummy_sed_2
    : dummy_sed_2
    s/^?/${lred}?${std}/;  t
    s/^M/${lgreen}M${std}/;  t
    s/^A/${lgreen}A${std}/;  t
    s/^X/${lblue}X${std}/;   t
    s/^+/${lyellow}+${std}/; t
    s/^D/${lyellow}D${std}/; t
    s/^,/${lred},${std}/;    t
    s/^C/${lred}C${std}/;    t
    s/^I/${purple}I${std}/;  t
    s/^R/${lblue}R${std}/;   t
    s/^!/${lred}!${std}/;    t
    s/^~/${lwhite}~${std}/;  t"

sed_svn_up_colors="
    t dummy_sed_1
    : dummy_sed_1
    $           q
    /^Updated/  t
    /^Fetching/ t
    /^External/ t
    s/^\\(.\\)C/\\1${lred}C${std}/
    s/^\\(.\\)U/\\1${lgreen}U${std}/
    s/^\\(.\\)D/\\1${lred}D${std}/
    t dummy_sed_2
    : dummy_sed_2
    s/^A/${lgreen}A${std}/;  t
    s/^U/${lgreen}U${std}/;  t
    s/^D/${lyellow}D${std}/; t
    s/^G/${purple}G${std}/;  t
    s/^C/${lred}C${std}/;    t"

# For dev's:
test "x$1" = x--debug && shift && set -x

test "x$1" = x--git && shift && git_mode=: && SVN=git

test "x$1" = x--no-changelog && shift && use_changelog=false

case $1 in
  # ------------------------------- #
  # Hooks for standard SVN commands #
  # ------------------------------- #
  commit | ci)
    shift
    svn_commit "$@"
    ;;
  help | \? | h)
    shift
    svn_help "$@"
    ;;
  status | stat | st)
    shift
    svn_status "$@"
    ;;
  update | up)
    shift
    svn_update "$@"
    ;;
  # -------------------- #
  # Custom SVN commands  #
  # -------------------- #
  diffstat | ds)
    shift
    if [ -d .git ]; then
      git diff --stat -C
    else
      require_diffstat && $SVN diff --no-diff-deleted "$@" | diffstat
    fi
    ;;
  diff | di)
    shift
    DIFF=$COLORDIFF
    svn_diff "$@"
    ;;
  diffw | dw)
    shift
    DIFF=$COLORDIFF
    svn_diffw "$@"
    ;;
  ignore)
    shift
    svn_ignore "$@"
    ;;
  log)
    if $git_mode; then # let Git handle log
      exec $SVN "$@"
    else # pipe svn log through PAGER by default
      exec $SVN "$@" | $PAGER
    fi
    ;;
  mail)
    shift
    svn_mail "$@"
    ;;
  propadd | padd | pa)
    shift
    svn_propadd "$@"
    ;;
  proposal)
    shift
    svn_commit --dry-run "$@"
    ;;
  propsed | psed)
    shift
    svn_propsed "$@"
    ;;
  revision | rev)
    shift
    svn_revision "$@"
    ;;
  touch)
    shift
    touch "$@" && $SVN add "$@"
    ;;
  selfupdate | selfup | self-update | self-up)
    shift
    selfupdate "$@"
    ;;
  version | -version | --version)
    shift
    set dummy '--version' "$@"
    shift
    svn_version
    exec $SVN "$@"
    ;;
  *) exec $SVN "$@"
    ;;
esac
