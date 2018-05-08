#! /bin/sh
# Script to prepare a PlaformUIAssetsBundle release

[ ! -f "bin/prepare_release.sh" ] && echo "This script has to be run the root of the bundle" && exit 1

print_usage()
{
    echo "Create a new version of PlaformUIAssetsBundle by creating a local tag"
    echo "This script MUST be run from the bundle root directory. It will create"
    echo "a tag but this tag will NOT be pushed"
    echo ""
    echo "Usage: $1 -v <version> [-b <branch>]"
    echo "-v version : where version will be used to create the tag"
    echo "-b branch : Branch you want to build, default is master"
}

VERSION=""
BUILD_BRANCH_TARGET="master"
while getopts "hb:v:" opt ; do
    case $opt in
        b ) BUILD_BRANCH_TARGET=$OPTARG ;;
        v ) VERSION=$OPTARG ;;
        h ) print_usage "$0"
            exit 0 ;;
        * ) print_usage "$0"
            exit 2 ;;
    esac
done

[ -z "$VERSION" ] && print_usage "$0" && exit 2

check_command()
{
    $1 --version 2>&1 > /dev/null
    check_process "find '$1' in the PATH, is it installed?"
}

check_process()
{
    [ $? -ne 0 ] && echo "Fail to $1" && exit 3
}

check_command "git"
check_command "bower"

VENDOR_DIR=`cat .bowerrc | grep "directory" | cut -d ':' -f 2 | sed 's/[ "]//g'`
YUI3_DIR="$VENDOR_DIR/yui3"
ALLOY_DIR="$VENDOR_DIR/alloy-editor"
ALLOY_NOTICE="$ALLOY_DIR/ALLOY_IN_PLATFORMUIASSETSBUNDLE.txt"
INTL_DIR="$VENDOR_DIR/handlebars-helper-intl"
INTL_NOTICE="$INTL_DIR/INTL_IN_PLATFORMUIASSETSBUNDLE.txt"

CURRENT_BRANCH=`git branch | grep '*' | cut -d ' ' -f 2`
TMP_BRANCH="version_$VERSION"
TAG="v$VERSION"

echo "# Switching to '$BUILD_BRANCH_TARGET' and updating"
git checkout -q $BUILD_BRANCH_TARGET > /dev/null && git pull > /dev/null
check_process "switch to '$BUILD_BRANCH_TARGET'"

echo "# Removing the assets"
[ ! -d "$VENDOR_DIR" ] && mkdir -p $VENDOR_DIR
[ -d "$VENDOR_DIR" ] && rm -rf $VENDOR_DIR/*
check_process "clean the vendor dir $VENDOR_DIR"

echo "# Bower install"
bower install
check_process "run bower"


echo "# Checkout last known YUI build given it is no longer available for download"
rm -Rf $YUI3_DIR/*
rm -f $YUI3_DIR/.gitignore $YUI3_DIR/.npmignore $YUI3_DIR/.travis.yml $YUI3_DIR/.yeti.json
git co v4.1.0 $YUI3_DIR
check_process "checkout YUI3 from v4.1.0"

echo "# Removing API docs and lib from alloy-editor"
rm -rf "$ALLOY_DIR/api" "$ALLOY_DIR/lib"
check_process "clean alloy-editor"
echo "This is a customized Alloy version." > $ALLOY_NOTICE
echo "To decrease the size of the bundle, it does not include API docs and lib" >> $ALLOY_NOTICE

echo "# Removing js maps from handlebars-helper-intl"
rm -rf $INTL_DIR/dist/*.map
check_process "clean handlebars-helper-intl"
echo "This is a customized handlebars-helper-intl version." > $INTL_NOTICE
echo "To decrease the size of the bundle, it does not include js maps" >> $INTL_NOTICE

echo "# Creating the custom branch: $TMP_BRANCH"
git checkout -q -b "$TMP_BRANCH" > /dev/null
check_process "create the branch '$TMP_BRANCH'"

echo "# Commiting"
git add -f Resources > /dev/null
git commit -q -m "Version $VERSION"
check_process "commit the assets"

echo "# Tagging $TAG"
git tag "$TAG"
check_process "to tag the version '$TAG'"

echo "# Switching back to '$CURRENT_BRANCH'"
git checkout -q "$CURRENT_BRANCH" > /dev/null
check_process "to switch back to '$CURRENT_BRANCH'"

echo "# Removing the custom branch '$TMP_BRANCH'"
git branch -D "$TMP_BRANCH" > /dev/null
check_process "to remove the branch '$TMP_BRANCH'"

echo ""
echo "The tag '$TAG' has been created, please check that everything is correct"
echo "then you can run:"
echo "  git push origin $TAG"
echo "and create the corresponding release on Github"
echo "https://github.com/ezsystems/PlatformUIAssetsBundle/releases"
