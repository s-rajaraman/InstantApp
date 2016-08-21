#!/bin/bash
url=$1
name=$2
platform=$3
arch=$4
uuid=$5
dir=../dist/

tmpdir=../tmp/$uuid/
resource=../resource

defaultUrl='https://www.example.com/'
defaultName='your-app'

if curl --output /dev/null --silent --head --fail "$url"; then
  mkdir -p $tmpdir
  cp -r $resource/* $tmpdir/
  sed -i -e "s,$defaultUrl,$url,g" $tmpdir/main.js
  sed -i -e "s,$defaultName,$name,g" $tmpdir/package.json
  electron-packager $tmpdir $name --platform=$platform --arch=$arch --out=$dir --version=1.3.3 --overwrite
  rm -r $tmpdir
else
  echo '1'
  exit 1
fi

if [ ! -d $dir/$name-$platform-$arch ]; then
  echo '2'
  exit 2
fi
echo '3'
exit 0
