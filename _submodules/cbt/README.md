# C/C++ build support tools - cbt 

Because cbt is utilizing submodules we recommend to use git aliases
 
```bash
# Aliases to better interact with submodules
#
git config --global alias.ll "log --pretty='format:%h %<(12,trunc)%ce %cd %s' --date=short"
git config --global alias.wd "diff --color-words='[A-z_][A-z0-9_]*'"
git config --global alias.scheckout '!sh -c "git checkout $1 $2 $3 $4 $5 $6 && git submodule sync --recursive && git submodule update --init"' -
git config --global alias.spull '!git pull --rebase && git submodule sync --recursive && git submodule update --init --rebase --recursive'
git config --global alias.spush 'push --recurse-submodules=on-demand'

# Useful settings
#
git config --global push.default simple
git config --global pull.rebase true
```
