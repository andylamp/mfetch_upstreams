#!/bin/bash

#
# Nifty little tool that I crafted to keep my repositories up to date
# with their upstream branches as I was really frustrated having to
# type everything over and over again.
#
# if you want to give me beer or flame; you'll easily find a way
# am sure.
#
# Author: Andrew Grammenos (andreas.grammenos@gmail.com)
#
# License: GPLv3.
#

## globals
hmsg="Script halted,"
vmsg="Valid path in"
smsg="Not valid, skipping path:"
parent_dir="~/Desktop"
current_dir="$(pwd)"

## beautiful and tidy way to expand tilde (~) by C. Duffy.
expandPath() {
  case $1 in
    ~[+-]*)
      local content content_q
      printf -v content_q '%q' "${1:2}"
      eval "content=${1:0:2}${content_q}"
      printf '%s\n' "$content"
      ;;
    ~*)
      local content content_q
      printf -v content_q '%q' "${1:1}"
      eval "content=~${content_q}"
      printf '%s\n' "$content"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

## now get the correct path
parent_dir=$(expandPath $parent_dir)

## here put your paths relative to the parent directory
## stored above that you want to keep track of; or
## other paths that are not relative to that one...
declare -a paths=(
  "$parent_dir/rust"
  "$parent_dir/kafka"
  "$parent_dir/storm"
  "$parent_dir/ace"
)

## check paths
check_path() {
  if [[ ! -d $1 ]]; then
    echo "$smsg $1";
    return 0
  else
    echo "$vmsg $1";
    return 1
  fi
}

## get the current branch
fetch_and_merge() {
  # get inside the directory
  cd $1
  # get the git branch
  branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
  # now fetch the remote
  git fetch upstream
  # now merge
  git merge upstream/${branch}
  # push back to git
  git push --q
  # now go back to parent dir
  cd $parent_dir
}

## firstly though, just use the git credential helper
## cache to store our credentials for this session
set_git_cache() {
  # NOTE: They are stored **in-memory**
  #       and for the default duration of
  #       15 minutes.
  git config --global credential.helper cache
}

## now fetch updates
probe_paths() {
  set_git_cache
  # now loop through the array
  for p in "${paths[@]}"; do
    # check the path
    check_path $p
    if [[ $? = 1 ]]; then
      fetch_and_merge $p
    fi
  done
  # after finishing, go back
  # to original directory
  cd $current_dir
}

## now fire up the paths
probe_paths