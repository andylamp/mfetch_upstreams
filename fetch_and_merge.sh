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
# License: MIT.
#

## globals
hmsg="Script halted,"
vmsg="Valid path in:"
smsg="Not valid, cloning from remote to:"
parent_dir="~/Desktop"
repo_host_link="https://github.com"
my_user="andylamp"
current_dir="$(pwd)"
let "cnt=0"

## beautiful and tidy way to expand tilde (~) by C. Duffy.
expand_path() {
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
parent_dir=$(expand_path $parent_dir)

## here put your paths relative to the parent directory
## stored above that you want to keep track of; or
## other paths that are not relative to that one...
declare -a paths=(
  "rust;rust-lang"
  "num;rust-num"
  "kafka;apache"
  "storm;apache"
  "ace;ajaxorg"
  "snap;snap-stanford"
  "snap-dev-64;snap-stanford"
  "flink;apache"
  "streaminer;mayconbordin"
  "unlocker;DrDonk"
  "mxnet-the-straight-dope;zackchase"
  "mxnet-slides;zackchase"
  "vimrc;amix"
  "SlideMenuControllerSwift;dekatotoro"
  "linguist;github"
  "ouimeaux;iancmcc"
  "intellij-rust;intellij-rust"
  "uber-juno;JunoLab"
  "TuringLearnDraft.jl;tlienart"
  "AnalyticalEngine.jl;tlienart"
  "Format-Preserving-Encryption;0NG"
  "wmsketch;stanford-futuredata"
  "tsfresh;blue-yonder"
  "fmtl;gingsmith"
  "buddy-malloc;evanw"
  "cyclades;amplab"
  "rbuild;akritid"
  "api-compiler;googleapis"
  "learn-julia-the-hard-way;chrisvoncsefalvay"
  "Gdbinit;gdbinit"
  "acmart;borisveytsman"
  "tlsf;akritid"
  "AzurePublicDataset;Azure"
  "sgx-lkl;lsds"
  # my repos
  "fetch_my_key;andylamp"
  "dotfiles;andylamp"
  "bg_run;andylamp"
  "c89_parser;andylamp"
  "BPlusTree;andylamp"
  "linhash;andylamp"
  "hashy_table;andylamp"
  "csv_to_csvs;andylamp"
  "c-various;andylamp"
  "c-primitives;andylamp"
  "moses;andylamp"
  "mfetch_upstreams;andylamp"
)

## check paths
check_path() {
  echo "Probing path: $1"
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
  cd $parent_dir/$1
  # expand the remote link
  plink="$repo_host_link/$2/$1"
  # get the git branch
  branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
  # check if we have an upstream, if not add the one
  # on file
  if [[ ! $(git remote -v) =~ .*upstream.*$plink.* ]]; then
    echo "No valid remote present for: $1, adding: $plink"
    git remote remove upstream
    git remote add upstream $plink
  else
    echo "Valid upstream present (set at: $plink)"
  fi
  # pull changes first
  echo "Pulling latest changes from repo"
  git pull
  # now fetch the remote
  echo "Fetching upstream"
  git fetch upstream
  # now merge
  git merge --no-edit upstream/${branch}
  # push back to git
  git push --q
  # now go back to parent dir
  cd $parent_dir
  # increment counter
  let "cnt++"
}

## get the repo store to that path and
## register the upstream
fetch_and_register() {
  # ensure we are into the correct directory
  cd $parent_dir
  myrepolink="$repo_host_link/$my_user/$1"
  remlink="$repo_host_link/$2/$1"
  # try to clone
  git clone $myrepolink
  if [[ $? -ne 0 ]]; then
    # could not clone
    echo "Failed to clone repo from $myrepolink, skipping"
    return
  fi
  echo "Cloned repo from $myrepolink to $parent_dir/$1"
  # register remote
  echo "Adding remote upstream to repo $1 with value $remlink"
  # go to repo
  cd $parent_dir/$1
  # add the remote
  git remote add upstream $remlink
  echo "Repository $1 configured successfully!"
  # finally fetch and merge
  fetch_and_merge $1 $2
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
  # enable git credential cache
  set_git_cache
  # now loop through the array
  printf "Probing ${#paths[@]} repositories...\n\n"
  for p in "${paths[@]}"; do
    p=(${p//;/ })
    path="$parent_dir/${p[0]}"
    repo=${p[0]}
    powner=${p[1]}
    printf "Trying repository: $repo (original owner: $powner)\n"
    #echo "Path $path, Remote $gh_link/$powner/$repo"
    # check the path
    check_path $path
    if [[ $? = 1 ]]; then
      fetch_and_merge $repo $powner
    else
      fetch_and_register $repo $powner
    fi
    echo ""
  done
  # after finishing, go back
  # to original directory
  cd $current_dir
  printf "All done, processed successfully $cnt out of ${#paths[@]} repositories\n"
}

## now fire up the paths
probe_paths
