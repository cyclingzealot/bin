git pull
git pull --recurse-submodules && git submodule update --recursive
git submodule foreach git checkout master
git submodule foreach git pull origin master
git-branch-status.bash
git submodule foreach git-branch-status.bash
