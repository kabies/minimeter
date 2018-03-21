#!/bin/sh

REPOSITORY="https://github.com/mruby/mruby.git"
DIR="mruby"
MRUBY_CONFIG="../build_config.rb"
FRAMEWORKS_PATH="$HOME/Library/Frameworks"

echo "MRUBY_CONFIG=$MRUBY_CONFIG"
echo "FRAMEWORKS_PATH=$FRAMEWORKS_PATH"

git clone -b 1.4.0 $REPOSITORY $DIR

cd $DIR
env FRAMEWORKS_PATH=$FRAMEWORKS_PATH MRUBY_CONFIG=$MRUBY_CONFIG ruby minirake -v all
