gcd ;

for file in `git status --porcelain  | grep " M" | cut -d ' ' -f 3 ` ;  do
    headline.bash "$file" ;
    git diff $file ;
    echo ;
    read -e -r -p "Git comment: " gitComment
    set -x
    git commit  $file  -m "$gitComment"
    set +x
    echo
done
