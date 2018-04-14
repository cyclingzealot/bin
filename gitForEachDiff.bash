cd `git rev-parse --show-toplevel` ;

set -x
fileList=`git status --porcelain  | grep " M" | cut -d ' ' -f 3 `
fileCount=`git status --porcelain | grep " M" | wc -l `
set +x
i=0

for file in $fileList; do
    let i++
    headline.bash "$file" ;
    git diff $file ;
    echo ;
    read -e -r -p "Git comment: ($i/$fileCount) " gitComment
    set -x
    git commit  $file  -m "$gitComment"
    set +x
    echo
done
