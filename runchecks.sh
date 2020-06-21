#!/bin/bash

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "The GITHUB_TOKEN is required."
	exit 1
fi

EVENT_PATH=$(jq -r '.pull_request._links.self.href' "$GITHUB_EVENT_PATH")
FILES_LINK=${EVENT_PATH}/files
echo "Files = $FILES_LINK"

curl $FILES_LINK > files.json
FILES_URLS_STRING=`jq -r '.[].raw_url' files.json`

readarray -t URLS <<<"$FILES_URLS_STRING"

echo "File names: $URLS"

mkdir files
cd files
for i in "${URLS[@]}"
do
   echo "Downloading $i"
   curl -LOs --remote-name $i 
done

echo "Files downloaded!"

FILES_TO_CHECK=$(echo *.{c,h,cpp,hpp,C,cc,CPP,c++,cp,cxx})

echo "clang-tidy checks"
clang-tidy --version
clang-tidy ${FILES_TO_CHECK} > clang-tidy-report.txt
echo "clang-format checks"
clang-format --version
clang-format -i ${FILES_TO_CHECK} > clang-format-report.txt

COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)

OUTPUT=$'** clang-format **:\n'
OUTPUT+=$(cat clang-format-report.txt)
OUTPUT+=$'** clang-tidy **:\n'
OUTPUT+=$(cat clang-tidy-report.txt)

echo $COMMENTS_URL

PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')

curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
