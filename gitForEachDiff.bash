gcd ; for file in `git status --porcelain  | grep " M" | cut -d ' ' -f 3 ` ;  do headline.bash "$file" ; git diff $file ; done
