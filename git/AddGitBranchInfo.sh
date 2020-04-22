#!/bin/bash
function GetCurrentGitBranch {
   branch="`git symbolic-ref --short -q HEAD 2>/dev/null`"
   if [ "${branch}" != "" ];then
       if [ "${branch}" = "(no branch)" ];then
           branch="(`git rev-parse --short HEAD`...)"
       fi
       echo " ($branch)"
   fi
}

export PS1='\u@\h \[\033[01;36m\]\W\[\033[01;32m\]$(GetCurrentGitBranch)\[\033[00m\] \$ '
