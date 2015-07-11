#!/bin/bash

IFS='/' read -a myarray <<< $GIT_REPOSITORY_URL

GIT_BRANCH="release$BRANCH_NUMBER"
# work out the repository and project name from the GIT URL
GIT_REPOSITORY_NAME=${myarray[3]}
GIT_PROJECT_NAME="$( cut -d '.' -f 1 <<< "${myarray[4]}")";

function gclonecd(){
  # clone repo and cd to git repo but removing the '.git' from the directory name
  dirname=$(basename $1)
  len=${#dirname}-4
  git clone $1 && cd $(echo "${dirname:0:$len}")
}

gclonecd $GIT_REPOSITORY_URL

git checkout -b $GIT_BRANCH

# Iterate through a possible list of files or directories to include.  If it's a directory then use -path rather than -name
IFS=',' read -a excludeFilesArray <<< $EXCLUDE_FILES_PATTERN
for j in "${excludeFilesArray[@]}"
do
   :
   # check to see if a this includes a directory
     if [[ $j == *\/* ]]
     then
       echo "$j seems to be a directory, adapting find command"
       FIND_EXCLUDE_STRING=$FIND_EXCLUDE_STRING' ! -path "*/'$j'"'
     else
       FIND_EXCLUDE_STRING=$FIND_EXCLUDE_STRING' ! -name "'$j'"'
     fi
done

# I'm sure there's a better way and reuse the similar code above but duplicateing for now
IFS=',' read -a includeFilesArray <<< $INCLUDE_FILES_PATTERN
for i in "${includeFilesArray[@]}"
do
   :
   # check to see if a directory appears
     if [[ $i == *\/* ]]
     then
       echo "$i seems to be a directory, adapting find command"
       FIND_INCLUDE_STRING=$FIND_INCLUDE_STRING'find -path "*/'$i'"' $FIND_EXCLUDE_STRING
     else
       FIND_INCLUDE_STRING=$FIND_INCLUDE_STRING'find -name "'$i'"' $FIND_EXCLUDE_STRING
     fi
done



echo "Find command will be: find $FIND_INCLUDE_STRING $FIND_EXCLUDE_STRING"

# use sed to search and replace
# using '@' as the delimeter so to avoid a clash when searching for pom versions, e.g. <version>1.0.0</version>
# using '\' to escape search string and avoid matching '.' as metachars
perl -p -i -e 's@\Q'$FROM'@'$TO'@g' `find $FIND_INCLUDE_STRING $FIND_EXCLUDE_STRING`

# if no changes have been made exit
git status | grep 'nothing to commit' &> /dev/null
if [ $? == 0 ]; then
   echo "nothing has changed after string replace, please check FROM and TO values: $FROM -> $TO"
   exit -1
fi

git config --global push.default simple
git config --global user.email $GIT_USER_EMAIL
git config --global user.name  $GIT_USER_NAME

cat > ~/.netrc <<EOF
machine github.com
       login $GIT_USER_NAME
       password $GIT_PASSWORD
EOF

git commit -a -m "string replace for $FILE_PATTERN update from $FROM to $TO"
git push $GIT_REPOSITORY_URL $GIT_BRANCH

curl -X POST -u $GIT_USER_NAME:$GIT_PASSWORD -k -d '{"title": "string replace for '$FILE_PATTERN' update from '$FROM' to '$TO'","head": "'$GIT_REPOSITORY_NAME':'$GIT_BRANCH'","base": "master"}' https://api.github.com/repos/$GIT_REPOSITORY_NAME/$GIT_PROJECT_NAME/pulls
