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



# Loop round the list of exclude files or directories and build a env var that contains everything to exclude using the correct options whether a file or directory is being requested
# If it's a directory then in the find command later we should use -path rather than -name
IFS=',' read -a excludeFilesArray <<< $EXCLUDE_FILES_PATTERN
for j in "${excludeFilesArray[@]}"
do
   :
   # check to see if a this includes a directory
     if [[ $j == *\/* ]]
     then
       echo "$j containes a directory so using -path to exclude files"
       FIND_EXCLUDE_STRING=$FIND_EXCLUDE_STRING" ! -path "*/$j""
     else
       echo "$j does not containe a directory so using -name to exlude files"
       FIND_EXCLUDE_STRING=$FIND_EXCLUDE_STRING" ! -name "$j""
     fi
done

echo "FIND_EXCLUDE_STRING=$FIND_EXCLUDE_STRING"

# Now we have a list of files to exclude, loop round all included files or directories and perform the search and replace
# Using Perl as it's easier when escaping search strings
IFS=',' read -a includeFilesArray <<< $INCLUDE_FILES_PATTERN
for i in "${includeFilesArray[@]}"
do
   :
   # check to see if a directory appears
     if [[ $i == *\/* ]]
     then
       echo "Replacing files $i, changing $FROM to $TO but  $FIND_EXCLUDE_STRING"
       perl -p -i -e 's@\Q'$FROM'@'$TO'@g' `find . -path "*/$i" $FIND_EXCLUDE_STRING`
     else
       echo "Replacing files $i, changing $FROM to $TO but  $FIND_EXCLUDE_STRING"
       perl -p -i -e 's@\Q'$FROM'@'$TO'@g' `find . -name "$i" $FIND_EXCLUDE_STRING`
     fi
done


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
