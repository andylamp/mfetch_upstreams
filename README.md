# mFetch upstreams v2.0

If you have more than one project that you want to regularly keep track of, then you've been in the same tedious position as I to perform these *three-damn-lines* dozens of times:
 
 ```sh
 git fetch upstream
 git merge upstream/master
 git push
 ```
 
I got really tired of it, so I made a batch script about it... but let's start by explaining what it *actually* does. 
This script is meant to take care all of the hassle involved with the aforementioned repetitive process while also merging the *correct* branch and not just `master`. 
Concretely, let us assume that you have a local branch named `tomato` then it be smart enough to perform `git merge upstream/tomato`.

Additionally, for clarity reasons, when configuring the script I suggest you put one directory per line as the script will loop through all of them -- no problem. 
Oh, and finally it needs your credentials, typed only once as they are cached through `git`'s credential helper for 15 minutes (in Linux distros & Windows); MacOS users will enjoy the joy of having `keychain`. 
 
## What it needs from you
 
This version (v2) is a little bit more sophisticated; as it provides the ability to *clone* the repo if not present or set its `remote` but to do this now it needs one more bit of extra information when entering the repo -- it's `upstream` repo link. 
This can be handy for example if you just `clone`d a repository which does not have a current `upstream` branch; this was a pain as it had to be done (once) for each repository... but now fear not, it's been taken care of! 
 
 ```sh
 declare -a paths=(
  "rust;rust-lang"
  "num;rust-num"
  "kafka;apache"
  "storm;apache"
 )
 ```
 
 ## Fresh clones
 
 When you first run the script you need to configure the `${my_user}` and `${repo_host_link}` -- please note that due (my) github preference I assume the link structure will be of the following format:
 
 ```
 repo_host_link/my_user/repo_name
 ```
 
 If you are using github, this will not be a major pain but if you are using another service (e.g. GitLab, BitBucket) you may need to adjust the links slightly. 
 Other than that, this should be a plug an play affair; it will fork the repo from *your* remote fork, setup the `upstream` to the original repository and perform a merge in order to update it as well.
 
 ## Existing clones
 
 If the repository already exists, then first of all we check if the `upstream` repo is set, if not we set it to the supplied value and then it is updated/merged to the latest commit from the upstream repo.
