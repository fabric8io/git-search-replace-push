# git search replace push

Generic utility to replace search strings in a git repository, push changes to a branch and raise a pull request  (currently GitHub only)

This Dockerfile builds an image that will clone a git repo, search and replace string values provided via environment variables for specific file patterns, commit and push back the changes.

# Usage

Example of replacing version numbers in all the pom files from the fabric8 quickstarts project
```
docker run -ti -e BRANCH_NUMBER=1 -e GIT_REPOSITORY_URL=https://github.com/rawlingsj/quickstarts.git -e FROM="<modelVersion>4.0.0</modelVersion>" -e TO="<modelVersion>4.0.1</modelVersion>" -e GIT_USER_NAME=rawlingsj -e GIT_USER_EMAIL=a@b.com -e GIT_PASSWORD=mygitpassword -e INCLUDE_FILES_PATTERN="pom.xml" fabric8/git-search-replace-push
```

Example of changing the version number in all mark down files except Changes.md from the fabric8 project
```
docker run -ti -e BRANCH_NUMBER=1 -e GIT_REPOSITORY_URL=https://github.com/rawlingsj/fabric8.git -e FROM="2.2.5" -e TO="2.2.6" -e GIT_USER_NAME=rawlingsj -e GIT_USER_EMAIL=a@b.com -e GIT_PASSWORD=mygitpassword -e INCLUDE_FILES_PATTERN="*.md,website/src/**.*" -e EXCLUDE_FILES_PATTERN="Changes.md,docs/jube/**.*" fabric8/git-search-replace-push
```

# Configuration Variables

- `INCLUDE_FILES_PATTERN` - comma delimeted file pattern used to apply the search on
- `EXCLUDE_FILES_PATTERN` - comma delimeted file pattern to exclude from the search
- `FROM` - search text
- `TO` - replace text
- `GIT_REPOSITORY_URL` - repository to clone and commit back to
- `GIT_USER_NAME` - git username
- `GIT_USER_EMAIL` - git email address
- `GIT_PASSWORD` - git password _note: password is stored as clear text inside the docker image_
- `BRANCH_NUMBER` - a unique number in the scope of your git repository that will be appended to and form the branch name 'release$BRANCH_NUMBER'.  Typical values could be a version or build number.
# Example:

```
export $INCLUDE_FILES_PATTERN=*.md,website/src/**.*
export $EXCLUDE_FILES_PATTERN=Changes.md
export $FROM="<myversion>1.0.0</myversion>"
export $TO="<myversion>2.0.0</myversion>"

export $GIT_REPOSITORY_URL=https://github.com/rawlingsj/quickstarts.git
export $GIT_USER_NAME=joe
export $GIT_USER_EMAIL=joe.blogs@somewhere.com
export $GIT_PASSWORD=myp4ssword!

export $BRANCH_NUMBER=1.0.1
```
