#!/bin/bash
#
# Call Javascript Interpreter with given input and options, respecting line endings 
# Line endings are given as 3rd parameter: LR, CR or CRLF
#
# author: Mario Fischer www.chipwreck.de
#
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG="en_US.UTF-8"

if [ $3 == 'LF' ] ; then
	CR=$'\r'
elif [ $3 == 'CR' ] ; then
	CR=$'\n'
else
	CR=$'\r\n'
fi

IFS=$'\n\r'
a=1
while read -r line ; do
	if [ $a == 1 ] ; then
		my="${line}"
	else
		my="${my}${CR}${line}"
	fi
	let a=a+1
done

my="${my}${CR}${line}"

# execute and retranslate
if [ $3 == 'LF' ] ; then
	/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc "$1" -- "$my" "$2" | tr '\r' '\n' | iconv -s -f UTF-8 -t ISO8859-1 --
elif [ $3 == 'CR' ] ; then
	/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc "$1" -- "$my" "$2" | tr '\n' '\r' | iconv -s -f UTF-8 -t ISO8859-1 --
else
	/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc "$1" -- "$my" "$2" | perl -p -e 's/\n/\r\n/g' | iconv -s -f UTF-8 -t ISO8859-1 --
fi

unset IFS