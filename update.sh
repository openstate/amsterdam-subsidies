#!/bin/sh

git pull https://${GITHUB_PERSONAL_TOKEN}@github.com/openstate/amsterdam-subsidies.git master

rm -f message.txt
touch message.txt
wget -q -O tmp-subsidies2.csv "https://api.data.amsterdam.nl/dcatd/datasets/yvlbMxqPKn1ULw/purls/1"
if [ `file tmp-subsidies2.csv |grep Zip |wc -l` -gt 0 ];
then
  mv tmp-subsidies2.csv tmp-subsidies2.zip
  unzip -p tmp-subsidies2.zip >tmp-subsidies.csv
else
  cp tmp-subsidies2.csv tmp-subsidies.csv
fi
csvformat -d ';' -D ',' -e iso-8859-1 tmp-subsidies.csv >tmp-subsidies2.csv
csvcut -c 1-12 tmp-subsidies2.csv >tmp-subsidies3.csv
sed '1s/^\xEF\xBB\xBF//;${/^$/d;}' tmp-subsidies3.csv >"subsidies.csv"
csv-diff subsidies-old.csv subsidies.csv --key=DOSSIERNUMMER >>message.txt
cp -f subsidies.csv subsidies-old.csv
git add subsidies.csv

git config --global user.email "subsidiebot@bje.dds.nl"
git config --global user.name "Subsidiebot Amsterdam"
git commit -F message.txt && \
              git push -q https://${GITHUB_PERSONAL_TOKEN}@github.com/openstate/amsterdam-subsidies.git master \
              || true
