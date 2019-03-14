#!/bin/sh

rm -f message.txt
touch message.txt
for i in `seq 1 4`;
do
  wget -q -O - "https://maps.amsterdam.nl/open_geodata/excel.php?KAARTLAAG=BOMEN&THEMA=bomen$i" |csvformat -d ';' -D ',' |sed '1s/^\xEF\xBB\xBF//;${/^$/d;}' >"bomen$i.csv"
  echo "Bomen $i" >>message.txt
  csv-diff "bomen$i-old.csv" "bomen$i.csv" --key=Boomnummer >>message.txt
  cp -f "bomen$i.csv" "bomen$i-old.csv"
  git add "bomen$i.csv"
done

git config --global user.email "treebot@bje.dds.nl"
git config --global user.name "Treebot Amsterdam"
git commit -F message.txt && \
              git push https://${GITHUB_PERSONAL_TOKEN}@github.com/openstate/amsterdam-bomen.git master \
              || true
