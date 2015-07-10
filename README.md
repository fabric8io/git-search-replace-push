# git search replace push

This Dockerfile builds an image that will clone a git repo, search and replace string values provided via environment variables for specific file patterns, commit and push back the changes.

# Usage

```
docker run -ti -e BRANCH_NUMBER=13 -e GIT_REPOSITORY_URL=https://github.com/rawlingsj/quickstarts.git -e FROM="<modelVersion>4.0.0</modelVersion>" -e TO="<modelVersion>4.0.1</modelVersion>" -e GIT_USER_NAME=rawlingsj -e GIT_USER_EMAIL=a@b.com -e GIT_PASSWORD=mygitpassword -e FILE_PATTERN=pom.xml rawlingsj/git-search-replace-push
```

# Configuration Variables

- `FILE_PATTERN` - file pattern used to apply the search on
- `FROM` - search text
- `TO` - replace text
- `GIT_REPOSITORY_URL` - repository to clone and commit back to
- `GIT_USER_NAME` - git username
- `GIT_USER_EMAIL` - git email address
- `GIT_PASSWORD` - git password _note: password is stored as clear text inside the docker image_
- `BRANCH_NUMBER` - a unique number in the scope of your git repository that will be appended to and form the branch name 'release$BRANCH_NUMBER'.  Typical values could be a version or build number.
# Example:

```
export $FILE_PATTERN=pom.xml
export $FROM="<myversion>1.0.0</myversion>"
export $TO="<myversion>2.0.0</myversion>"

export $GIT_REPOSITORY_URL=https://github.com/rawlingsj/quickstarts.git
export $GIT_USER_NAME=joe
export $GIT_USER_EMAIL=joe.blogs@somewhere.com
export $GIT_PASSWORD=myp4ssword!

export $BRANCH_NUMBER=1.0.1
```
