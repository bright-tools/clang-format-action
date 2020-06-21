#!/bin/bash

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "The GITHUB_TOKEN is required."
	exit 1
fi

FILES_LINK=`jq -r '.pull_request._links.self.href' "$GITHUB_EVENT_PATH"`/files
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
   curl -LOk --remote-name $i 
done

echo "Files downloaded!"
echo "Performing checkup:"
clang-tidy --version
clang-tidy *.c *.h *.cpp *.hpp *.C *.cc *.CPP *.c++ *.cp *.cxx > clang-tidy-report.txt

clang-format -i *.c *.h *.cpp *.hpp *.C *.cc *.CPP *.c++ *.cp *.cxx > clang-format-report.txt

COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)

OUTPUT=$'** clang-format **:\n'
OUTPUT+=`cat clang-format-report.txt`
OUTPUT+=$'** clang-tidy **:\n'
OUTPUT+=`cat clang-tidy-report.txt`

echo $COMMENTS_URL

PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')

curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
