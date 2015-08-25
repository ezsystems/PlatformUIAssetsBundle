#! /bin/sh
# Script to prepare a PlaformUIAssetsBundle release

[ ! -f "bin/prepare_release.sh" ] && echo "This script has to be run the root of the bundle" && exit 1

print_usage()
{
    echo "Create a new version of PlaformUIAssetsBundle by creating a local tag"
    echo "This script MUST be run from the bundle root directory. It will create"
    echo "a tag but this tag will NOT be pushed"
    echo ""
    echo "Usage: $1 -v <version>"
    echo "-v version : where version will be used to create the tag"
}

VERSION=""
while getopts "hv:" opt ; do
    case $opt in
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
YUI3_NOTICE="$YUI3_DIR/YUI3_IN_PLATFORMUIASSETSBUNDLE.txt"

CURRENT_BRANCH=`git branch | grep '*' | cut -d ' ' -f 2`
TMP_BRANCH="version_$VERSION"
TAG="v$VERSION"

echo "# Switching to master and updating"
git checkout -q master > /dev/null && git pull > /dev/null
check_process "switch to master"

echo "# Removing the assets"
[ ! -d "$VENDOR_DIR" ] && mkdir -p $VENDOR_DIR
[ -d "$VENDOR_DIR" ] && rm -rf "$VENDOR_DIR/*"
check_process "clean the vendor dir $VENDOR_DIR"

echo "# Bower install"
bower install
check_process "run bower"

echo "# Removing, docs, API docs and tests from YUI"
rm -rf "$YUI3_DIR/api" "$YUI3_DIR/docs" "$YUI3_DIR/tests"
check_process "clean YUI"
echo "This is a customized YUI3 version." > $YUI3_NOTICE
echo "To decrease the size of the bundle, it does not include the API docs," >> $YUI3_NOTICE
echo "the documentation and the unit tests" >> $YUI3_NOTICE

echo "# Creating the custom branch: $TMP_BRANCH"
git checkout -q -b "$TMP_BRANCH" > /dev/null
check_process "create the branch '$TMP_BRANCH'"

echo "# Commiting"
git add Resources > /dev/null
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
