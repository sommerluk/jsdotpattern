#!/bin/bash
# ------------------------------------------------------------
#    assembles svg code from symbol files into json
# ------------------------------------------------------------

SYMBOLS="forest bforest scrub scrub2 grass grass_tall dot dash dash_thin pixel vpixel tree_s1 tree_s2 tree_a1 tree_a2 tree_as1 tree_as2 tree tree2 mangrove trees1 trees2 trees3 trees4 trees5 tree_pair marsh reed bog scree rock wood wood_s wood1 wood2 wood2a quarry1 quarry2"

for SYM in `find "symbols" -maxdepth 1 -name "*.svg" | sort` ; do
	SYM_NAME=`basename $SYM .svg`
	if ! echo "$SYMBOLS" | grep "$SYM_NAME" > /dev/null ; then
		SYMBOLS="$SYMBOLS $SYM_NAME"
	fi
done

for SYM in `find "symbols" -mindepth 1 -type d | sort` ; do
	SYM_NAME=`basename $SYM`
	if ! echo "$SYMBOLS" | grep "$SYM_NAME" > /dev/null ; then
		SYMBOLS="$SYMBOLS $SYM_NAME"
	fi
done

echo "// Symbol library for jsdotpattern
// nontrivial symbols are licensed under CC0
// generated by symbols_json.sh

var SelSyms = [" > "symbols.js"

FIRST=1

for SYM in $SYMBOLS ; do
	SYM_NAME=`echo "$SYM" | sed "s?_? ?g"`
	echo "$SYM_NAME"
	if [ -d "symbols/$SYM" ] ; then
			touch "symbols/$SYM"
		if [ -z "$FIRST" ] ; then
			echo "," >> "symbols.js"
		else
			FIRST=
		fi
		echo "  { \"name\":\"$SYM_NAME\", \"svg\":[" >> "symbols.js"
		SUB_FIRST=1
		for SUB_SYM in `find "symbols/$SYM" -name "*.svg" | cut -d "/" -f 3- | sort -n` ; do
			if [ -z "$SUB_FIRST" ] ; then
				echo "," >> "symbols.js"
			else
				SUB_FIRST=
			fi
			SYM_CODE=`cat "symbols/$SYM/$SUB_SYM" | tr "\n\t" " " | sed 's/<?xml[^>]*>//;s/<svg[^>]*>//;s?</svg>??;s?^ [ ]*??g;s?>[ ]*<?><?g;s? [ ]*? ?g;s?[ ]*$??g;s?\"?\\\"?g'`
			echo -n "    \"$SYM_CODE\"" >> "symbols.js"
		done
		echo "" >> "symbols.js"
		echo -n "  ] }" >> "symbols.js"
	elif [ -r "symbols/$SYM.svg" ] ; then
		if [ -z "$FIRST" ] ; then
			echo "," >> "symbols.js"
		else
			FIRST=
		fi
		SYM_CODE=`cat "symbols/$SYM.svg" | tr "\n\t" " " | sed 's/<?xml[^>]*>//;s/<svg[^>]*>//;s?</svg>??;s?^[ ]*??g;s?>[ ]*<?><?g;s? [ ]*? ?g;s?[ ]*$??g;s?\"?\\\"?g'`
		echo -n "  { \"name\":\"$SYM_NAME\", \"svg\":\"$SYM_CODE\" }" >> "symbols.js"
	else
		echo "Error: symbol $SYM not found - skipping."
	fi
done

echo "" >> "symbols.js"
echo "];" >> "symbols.js"
