#!/bin/bash

for file in `git status | grep -E 'modifié|modified' | cut -c 2- | awk '{print $2 }'`; do
    seperator.bash ;
    git diff $file | head -n 30;
    echo
    read -p "What will be the comment for this file?  " msg
    git commit "$file" -m "$msg"
done

echo "Not doing git push for sanity reason"
