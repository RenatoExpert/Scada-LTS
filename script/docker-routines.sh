#!/usr/bin/bash

COMMAND=$1
TARGET=$2
VERSION=`git describe --abbrev=4`

build() {
	TARGET=$1
	if [ -z "$TARGET" ]
	then
		echo "Target not defined"
	else
		docker buildx build . --target $TARGET -t $TARGET	&& \
		docker create --name $TARGET $TARGET /			&& \
		FULLNAME=$TARGET-$VERSION				&& \
		docker cp $TARGET:/output/ output/$FULLNAME		&& \
		docker rm $TARGET					&& \
		tar -cf $FULLNAME.tar $FULLNAME
	fi
}

if [[ "$COMMAND" == "build" ]]; then
	build $TARGET;
else
	echo "Unknown command $COMMAND"
fi


