#!/bin/bash

FILES_TO_CHECK=$(find . -name *.cpp -o -name *.hpp -o -name *.c -o -name *.h})

if [ -z "${FILES_TO_CHECK}" ]; then
    echo "No files to be checked"
    OUTPUT="No C/C++ files changed"
else
    echo "Files to be checked: ${FILES_TO_CHECK}"
    echo "clang-format checks"
    clang-format-$1 --version
    clang-format-$1 -n -Werror ${FILES_TO_CHECK}
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi
