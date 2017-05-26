#!/usr/bin/env bash

set -euf -o pipefail

# reset state
echo "[0/4]: resetting"
rm -fr hacklily-lilypond-dist-osx dist/hacklily-lilypond-dist-osx.* tmp
mkdir tmp
mkdir hacklily-lilypond-dist-osx
cat << "PROFILE_SCRIPT" > hacklily-lilypond-dist-osx/.profile
SELFDIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
cd $SELFDIR
export HOME=$SELFDIR
PROFILE_SCRIPT

# here we go!
echo "[1/4]: fetching lyp"
curl -L https://github.com/noteflakes/lyp/releases/download/v1.3.4/lyp-1.3.4-osx.tar.gz > tmp/lyp-1.3.4-osx.tar.gz
shasum -a 256 -c ./MAC.INTEGRITY
pushd tmp
tar -xf lyp-1.3.4-osx.tar.gz
popd

echo "[2/4]: init lyp"
export HOME=$(pwd)/hacklily-lilypond-dist-osx
tmp/lyp-1.3.4-osx/bin/lyp install self
source hacklily-lilypond-dist-osx/.profile
lyp install lilypond
lyp install lys

# Patch lys for RCE vuln
echo "[3/4]: patch lys"
pushd .lyp/packages/lys@0.1.0
git remote add hacklily-lys https://github.com/hacklily/lys.git
git fetch hacklily-lys
git checkout hacklily-lys/master
popd

cd .. # back to root
echo "[4/4]: bundling and cleaning up"
mkdir -p dist
cp ./resources/start.ly ./resources/start.sh ./hacklily-lilypond-dist-osx/
tar -cf dist/hacklily-lilypond-dist-osx.tar ./hacklily-lilypond-dist-osx
gzip -f dist/hacklily-lilypond-dist-osx.tar
rm -fr hacklily-lilypond-dist-osx tmp

echo
echo "IT WORKED."
