# mFetch upstreams v2.0

If you have more than one project that you want to regularly keep track of, then you've 
been in the same tedious position as I to perform these *three-damn-lines* dozens of times:
 
 ```sh
 git fetch upstream
 git merge upstream/master
 git push
 ```
 
I got really tired of it, so I made a script about it... Let's talk first about what it does. 
This script takes care all of the hassle involved with that repetitive process while also taking 
care to merge the *correct* branch and not just `master`. So for for example if you have a local 
branch named `tomato` it will perform `git merge upstream/tomato`.

Additionally, for clarity reasons when configuring the script I suggest you put one directory per 
line as the script will loop through all of them, no problem. Oh, and finally it needs your 
credentials, typed only once as they are cached through `git`'s credential helper for 15 minutes. 
 
## What it needs from you
 
This version is a little bit more sophisticated, so it needs one more information when entering the 
repo -- it's `upstream` repo link. This can be handy for example if you just cloned a repository which
does not have a current `upmstream` branch an din the previous version had to be both cloned and
configured manually. Thankfully, this now happens automatically.
 
 ```sh
 declare -a paths=(
  "rust;rust-lang"
  "num;rust-num"
  "kafka;apache"
  "storm;apache"
 )
 ```
 
 ## Fresh clones
 
 When you first run the script you need to configure the `$my_user` and `repo_host_link`; due to github
 preference I assume the link structure will be of the following format:
 
 ```
 repo_host_link/my_user/repo_name
 ```
 
 If you are using github, this will not be a major pain but if you are using another service you may
 need to adjust the links slightly. Other than that, this should be plug an play, it will fork the repo
 from *your* remote fork, setup the upstream to the original repository and perform a merge in order
 to update it as well.
 
 ## Existing clones
 
 If the repository already exists, then first of all we check if the `upstream` repo is set, if not
 we set it to the supplied value and then it is updated/merged to the latest commit from the upstream repo.