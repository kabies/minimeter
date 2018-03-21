#!/bin/sh

tmp="$0"
tmp=`dirname "$tmp"`
tmp=`dirname "$tmp"`
bundle=`dirname "$tmp"`
bundle_contents="$bundle"/Contents
bundle_res="$bundle_contents"/Resources

MRUBY="$bundle_contents/MacOS/mruby"
entry_script="$bundle_res/meter.rb"

cd $bundle_res
iostat -dC -w 1 disk0 | "$MRUBY" "$entry_script"
