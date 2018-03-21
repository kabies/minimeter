#!/bin/sh

iostat -dC -w 1 disk0 | ./mruby/bin/mruby meter.rb
