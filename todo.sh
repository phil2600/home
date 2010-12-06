#!/bin/sh
## todo.sh for todomaker in ~/Projets/scripts

f_skin()
{
    # please define your skin here
    default=$darkcyan
    comment=$darkblue
    not_done=$darkred
    working=$darkyellow
    done=$darkgreen
    ask=$darkpurple
    title=$darkgreen
    stopped=$darkpurple
}

f_help()
{
    echo "${darkyellow}Usage: colortodo.sh from any directory$std"
    echo "Looks in .. recursively until it finds a TODO file, and prints it"
    echo "$darkyellow OPTIONS$std"
    echo "	-l ${std}: LAZY  : do not print done and comment lines"
    echo "	-t ${std}: TITLE : only prints title lines"
    echo "	-h ${std}: help"
    echo "$darkyellow NORM$std (lines can be grepped with${std}: )"
    echo "	+ : ${done}done$std"
    echo "	> : ${working}working$std"
    echo "	- : ${not_done}not done$std"
    echo "	# : ${comment}comment$std"
    echo "	? : ${ask}don't know yet$std"
    echo "	X : ${stopped}stopped$std"
    echo "	~ : ${default}incomplete, needs testing (default)$std"
    echo "   [...%] : ${title}title$std"
    echo "	none of these : ${default}default color$std"
}

f_print()
{
# yay
    if [ $mode -eq 0 ] ; then
	echo $status $line
    else
	if [ $print -ge $mode ] ; then
	    echo $status $line
	fi
    fi
}

f_color()
{

    OLDIFS=$IFS
    IFS="
"
for line in `cat $TODO` ; do
# tests
    status=$default
    print=0
    echo $line | grep "^\([[:space:]]\)*-" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$not_done
	print=1
	f_print
	continue
    fi
    echo $line | grep "^\([[:space:]]\)*>" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$working
	print=1
	f_print
	continue
    fi
    echo $line | grep "^\([[:space:]]\)*+" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$done
	print=0
	f_print
	continue
    fi
    echo $line | grep "^\([[:space:]]\)*?" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$ask
	print=1
	f_print
	continue
    fi
    echo $line | grep "^\([[:space:]]\)*#" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$comment
	print=0
	f_print
	continue
    fi
    echo $line | grep "^\([[:space:]]\)*\[" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$title
	print=2
	f_print
	continue
    fi
    echo $line | grep "^\([[:space:]]\)*X" > /dev/null
    if [ $? -eq 0 ] ; then
	status=$stopped
	print=1
	f_print
	continue
    fi
    status=$default
    print=1
    f_print
done
}

f_getcolors()
{
    # colors
    darkred='[0;31m'	   red='[1;31m'
    darkgreen='[0;32m'   green='[1;32m'
    darkyellow='[0;33m'  yellow='[1;33m'
    darkblue='[0;34m'    blue='[1;34m'
    darkpurple='[0;35m'  purple='[1;35m'
    darkcyan='[0;36m'    cyan='[1;36m'
    darkgrey='[0;37m'    grey='[1;37m'
    darkwhite='[0;38m'   white='[1;38m'
    black='[1;30m'       std='[m'
    f_skin
}

f_init()
{
    f_getcolors
    # find TODO file
    cd $PWD
    TODO="TODO"
#    while [ ! -r $TODO ] ; do
#	TODO="../$TODO"
#    done
}

f_close()
{
    echo $std
#    cd -
}


mode=0
while [ x$1 != "x" ] ; do
case $1 in
    "-h")
	f_getcolors
	f_help
	exit 0
	;;
    "-l")
	mode=1
	shift
	;;
    "-t")
	mode=2
	shift
	;;
    *)
	f_getcolors
	f_help
	exit 1
	;;
esac
done
f_init
f_color
f_close
