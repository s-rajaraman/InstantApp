#!/bin/bash

url=$1
name=$2
platform=$3
arch=$4
dir=../dist/
uuid=$(uuid -v 4)
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
  exit 1
fi

if [ ! -d $dir/$name-$platform-$arch ]; then
  exit 2
fi

exit 0
