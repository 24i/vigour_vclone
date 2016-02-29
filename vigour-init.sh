#!/bin/bash

# NPM config: use localized folder to link everything
NPM_CONFIG_prefix="$PWD/linked_modules"
NPM_CONFIG_link=true
NPMRC="prefix=\"$NPM_CONFIG_prefix\"\nlink=$NPM_CONFIG_link"

print_msg() {
	printf "\e[32m[init]\e[0m $*\n"
}

throw_error () {
  printf "\n\n"
  print_msg "\e[31mERROR:\e[0m $*"
  printf "\n"
  exit 1
}
# git@github.com:vigour-io/
git_clone() {
	git clone "git@github.com:vigour-io/$1" && \
	cd $1 && \
	git fetch origin $2 && \
	git checkout $2
}

prep_dep() {
	git_clone $1 $2 && \
	printf "$NPMRC" > .npmrc && \
	npm link && \
	cd ..
}

bail_check() {
	if (( $1 != 0 )) ; then
  	throw_error $2
	fi
}

print_msg "read PROJECT and CLONED_DEPENDENCIES info from .conf file"
CONFPATH="$PWD/vigour-init.conf"
declare -A CLONED_DEPENDENCIES
source $CONFPATH
P_REPO=${PROJECT[0]}
P_BRANCH=${PROJECT[1]}

print_msg "clone and npm link dependencies"
for REPO in "${!CLONED_DEPENDENCIES[@]}"; do
	BRANCH=${CLONED_DEPENDENCIES["$REPO"]}
	print_msg "clone $REPO branch $BRANCH"
	prep_dep $REPO $BRANCH
	bail_check $? "failed to prep dependency $REPO on branch $BRANCH"
done

print_msg "clone project"
git_clone $P_REPO $P_BRANCH && \
printf "$NPMRC" > .npmrc && \
npm install

print_msg "done"