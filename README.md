# mFetch upstreams

If you have more than one project that you want to regularly keep track of, then you've been in the same tedious 
position as I to perform these *three-damn-lines* dozens of times:
 
 ```sh
 git fetch upstream
 git merge upstream/master
 git push
 ```
 
 I got really tired of it, so I made a script about it... Let's talk first about what it does. This script takes care
 all of the hassle involved with that repetitive process while also taking care to merge the *correct* branch and not
 just `master`. So for for example if you have a local branch named `tomato` it will 
 perform `git merge upstream/tomato`.
 
 ## What it needs from you
 
 In order to perform that, it needs a list of directories that your projects you wish to track are located. Mine are
 as follows:
 
 ```sh
 declare -a paths=(
   "$parent_dir/rust"
   "$parent_dir/kafka"
   "$parent_dir/storm"
   "$parent_dir/ace"
 )
 ```
 
 For clarity reasons I suggest you put one directory per line, the script will loop through all of them, no problem. Oh
 and finally it needs your credentials, typed only once as they are cached through `git`'s credential helper for 15
 minutes. That's it basically...