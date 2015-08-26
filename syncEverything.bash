git pull
git pull --recurse-submodules && git submodule update --recursive
#git submodule foreach --recursive git checkout master
#git submodule foreach --recursive git pull origin master
git-branch-status.bash
git submodule foreach --recursive git-branch-status.bash
