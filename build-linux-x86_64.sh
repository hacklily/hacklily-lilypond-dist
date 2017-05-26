#!/usr/bin/env bash

set -euf -o pipefail

# reset state
echo "[0/4]: resetting"
rm -fr hacklily-lilypond-dist-linux-x86_64 dist/hacklily-lilypond-dist-linux-x86_64.* tmp
mkdir tmp
mkdir hacklily-lilypond-dist-linux-x86_64
cat << "PROFILE_SCRIPT" > hacklily-lilypond-dist-linux-x86_64/.profile
SELFDIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
cd $SELFDIR
export HOME=$SELFDIR
PROFILE_SCRIPT

# here we go!
echo "[1/4]: fetching lyp"
curl -L https://github.com/noteflakes/lyp/releases/download/v1.3.4/lyp-1.3.4-linux-x86_64.tar.gz > tmp/lyp-1.3.4-linux-x86_64.tar.gz
shasum -a 256 -c ./LINUX_X86_64.INTEGRITY
pushd tmp
tar -xf lyp-1.3.4-linux-x86_64.tar.gz
popd

echo "[2/4]: init lyp"
export HOME=$(pwd)/hacklily-lilypond-dist-linux-x86_64
tmp/lyp-1.3.4-linux-x86_64/bin/lyp install self
source hacklily-lilypond-dist-linux-x86_64/.profile
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
cp ./resources/start.ly ./resources/start.sh ./hacklily-lilypond-dist-linux-x86_64/
tar -cf dist/hacklily-lilypond-dist-linux-x86_64.tar ./hacklily-lilypond-dist-linux-x86_64
gzip -f dist/hacklily-lilypond-dist-linux-x86_64.tar
rm -fr hacklily-lilypond-dist-linux-x86_64 tmp

echo
echo "IT WORKED."
