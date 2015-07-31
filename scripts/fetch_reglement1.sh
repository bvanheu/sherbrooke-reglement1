#!/bin/zsh

BASE_URL="http://www.ville.sherbrooke.qc.ca/"
TODAY=$(date +"%Y_%m_%d")
REGLEMENT1_URL=$(curl "http://www.ville.sherbrooke.qc.ca/services-municipaux/service-des-affaires-juridiques/reglements/" 2> /dev/null | grep -ioh 'fileadmin[a-zA-Z\/\._ 0-9-]*reglement[ _]n[a-zA-Z\/\._ 0-9-]*')
REGLEMENT1_FULL_URL="$BASE_URL/$REGLEMENT1_URL"
REGLEMENT1_FILENAME=$(basename "$REGLEMENT1_FULL_URL")
SED_LINE='s/’/ /g ; s/[0-9]\{2\}-[0-9]\{2\}-[0-9]\{4\}//g ; s/[0-9]\/[0-9]\/[0-9]\{2\}//g ; s/^[ ]*[0-9]\+$/ /g'

touch latest_sha1sum.txt

# Download the reglement 1
echo $REGLEMENT1_FULL_URL
curl -o "$REGLEMENT1_FILENAME" "$REGLEMENT1_FULL_URL" &> /dev/null

if [ ! -f "$REGLEMENT1_FILENAME" ]; then
    echo "Unable to fetch ${REGLEMENT1_FULL_URL}"
    exit 1
fi

# Compute sha1sum
SHA1SUM=$(sha1sum "$REGLEMENT1_FILENAME" | cut -d ' ' -f 1)

# Compare new sha1sum
NEW_REGLEMENT1=$(grep $SHA1SUM latest_sha1sum.txt)
if [ $? -eq 1 ] ; then
    echo $SHA1SUM > latest_sha1sum.txt
    echo "New reglement1: $SHA1SUM"
    # Got a new reglement
    cd ./git_repo
    # Go into master branch
    git checkout master
    mkdir -p "pdf/$TODAY"
    mv ../$REGLEMENT1_FILENAME "pdf/$TODAY/"
    # Skip annexes
    PAGE_NUMBER=$(pdfgrep -n "ANNEXES DU RÈGLEMENT" "pdf/$TODAY/$REGLEMENT1_FILENAME" | cut -d ':' -f 1)
    # Go to the git directory
    # Add the PDF
    git add "pdf/$TODAY/$REGLEMENT1_FILENAME"
    # Generate textfile
    pdftotext -l $((PAGE_NUMBER-1)) -nopgbrk -layout "pdf/$TODAY/$REGLEMENT1_FILENAME" - | sed $SED_LINE | uniq > texte/sherbrooke_reglement1.txt
    # Add the text
    git add texte/sherbrooke_reglement1.txt
    # Commit
    git commit -m "Updated to $TODAY"

    # Udate gh-pages
    git diff --ignore-blank-lines -a -b -w --word-diff --color=always HEAD~ texte/sherbrooke_reglement1.txt | ../ansi2html.sh --palette=dark > ../${TODAY}_sherbrooke_reglement1.txt
    git checkout gh-pages
    mkdir -p diff
    mv ../${TODAY}_sherbrooke_reglement1.txt ./diff/${TODAY}_sherbrooke_reglement1.html
    git add ./diff/${TODAY}_sherbrooke_reglement1.html
    echo "<p><a href=\"diff/${TODAY}_sherbrooke_reglement1.html\">${TODAY} - sherbrooke reglement 1</a></p>" >> ./index.html
    git add index.html
    git commit -m "Updated to $TODAY"
    echo "All done, please 'git push' manually"
else
    # Not a new reglement, destroy.
    rm "$REGLEMENT1_FILENAME"
    echo "Not new $SHA1SUM"
fi

