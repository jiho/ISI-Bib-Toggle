#!/bin/sh
#
#	Get journal names from ISI Web of Science
# 		http://images.isiknowledge.com/WOK45/help/WOS/
#
#	(c) Copyright 2009 Jean-Olivier Irisson. GNU General Public License
#
#------------------------------------------------------------


# current directory, in which the result will be copied
here=`pwd`

# safely create a temporary directory
tmpDir=`mktemp -d /tmp/foo.XXX`
# echo $tmpDir
if [[ ! -d $tmpDir ]]; then
	echo "Could not create temporary directory"
	exit 1
fi

for letter in "0-9" A B C D E F G H I J K L M N O P Q R S T U V W X Y Z; do
	echo $letter
	# get each page from the internet
	curl "http://images.isiknowledge.com/WOK45/help/WOS/"$letter"_abrvjt.html" > $tmpDir/$letter.html (The link has vanished)
done

cd $tmpDir

# consolidate the journals in one list file
grep -A 1 "</[A-B]><DT>" *.html > list.txt

# remove stray <D> at end of lines
cat list.txt \
   | sed 's/ *<D>//' \
   > list-out.txt && mv list-out.txt list.txt

# remove the HTML bits
# remove -- that grep includes to separate results from the different files
# TODO using sed instead of grep above would make this unnecessary but sed *.html does not seem to work
# remove blank lines
# convert to lower case
cat list.txt \
   | awk -F ">" '{print $NF}' \
   | sed '/^--$/d' \
   | sed '/^$/d' \
   | tr [:upper:] [:lower:] \
   > list-out.txt && mv list-out.txt list.txt

# initial caps of words
# TODO this needs to be made more clever about small words (and, of etc.), cf John Gruber's title case perl script
# TODO A dash (-) as to be considered as a word boundary in some jounals
cat list.txt \
   | perl -ane ' foreach $wrd( @F ) { print ucfirst($wrd)." "; } print "\n" ; ' \
   > list-out.txt && mv list-out.txt list.txt

# deal with some of the small words
cat list.txt \
   | sed 's/ A / a /g' \
   | sed 's/ An / an /g' \
   | sed 's/ And / and /g' \
   | sed 's/ As / as /g' \
   | sed 's/ At / at /g' \
   | sed 's/ But / but /g' \
   | sed 's/ By / by /g' \
   | sed 's/ En / en /g' \
   | sed 's/ For / for /g' \
   | sed 's/ If / if /g' \
   | sed 's/ In / in /g' \
   | sed 's/ Of / of /g' \
   | sed 's/ On / on /g' \
   | sed 's/ Or / or /g' \
   | sed 's/ The / the /g' \
   | sed 's/ To / to /g' \
   | sed 's/ Via / via /g' \
   | sed 's/ Vs / vs /g' \
   > list-out.txt && mv list-out.txt list.txt

# add dots at end of abbreviations
# TODO This would need to be made more clever also: do not add dots to words that are identical in the original name and in the abbreviation: they are probably the same
cat list.txt \
   | sed 'n;s/ /. /g' \
   > list-out.txt && mv list-out.txt list.txt

# trim line endings
# join two consecutive lines in the form: full journal name = abbreviation
cat list.txt \
   | sed 's/ *$//' \
   | sed 'N; s/\n/ = /' \
   > list-out.txt && mv list-out.txt list.txt

# copy the file to current directory
cp list.txt "$here"/isi_journal_abbreviations.txt

# append a personal list of journals
cd "$here"
cat personal_abbreviations.txt >> isi_journal_abbreviations.txt

# TODO even after this, some journal names are incorrect, because they are incorrect in the list. They would therefore need to be changed

rm -Rf $tmpDir

exit 0
