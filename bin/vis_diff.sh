#!/bin/bash

# Taken from https://github.com/madworm/KiCad-Stuff
# with minor changes (name of files to include sources so layer names are understandable
# not sure why temporaries are required for the layer files, need to see
# if original files can be used as well

shopt -s nocasematch

#
# Check if all tools are available
#
if [[ ! -e `which gerbv` ]]
then
	echo -e "\nPlease install 'gerbv'\n"
	EXIT=1
fi

if [[ $# -ne 2 ]]
then
	echo -e "\nUsage: $0 FILE1 FILE2" 
	EXIT=1
fi

if [[ $EXIT -eq 1 ]]
then
	echo -e "\nBYE!\n"
	exit
fi

#
# do a simple check for image-(like) file formats
#
if [[ $1 =~ ^.*\.(g[a-z]{2}|drl|oln|gm1)$ && ! $1 =~ ^.*.gvp$ ]]
then
    B1=$(basename $1)
    B2=$(basename $2)
	TMPFILE0=`mktemp --suffix=_git`
	TMPFILE1=`mktemp --suffix=$B1`
	TMPFILE2=`mktemp --suffix=$B2`

	cp $1 $TMPFILE1
	cp $2 $TMPFILE2

	GERBV_TEMPLATE="(gerbv-file-version! \"2.0A\")\n
	(define-layer! 1 (cons 'filename \"${TMPFILE1}\")(cons 'visible #t)(cons 'color #(65535 0 3050)))\n
	(define-layer! 0 (cons 'filename \"${TMPFILE2}\")(cons 'visible #t)(cons 'color #(8188 65535 0)))\n
	(set-render-type! 1)"

	echo -e $GERBV_TEMPLATE > $TMPFILE0
	gerbv -p $TMPFILE0

	rm $TMPFILE0
	rm $TMPFILE1
	rm $TMPFILE2
else
	# unsupported file format
	diff -u $1 $2 |less
fi
