#!/usr/bin/env ruby
require "fileutils"

MIT=<<EOS
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
EOS

MRUBY_IO=<<EOS
Copyright (c) 2013 Internet Initiative Japan Inc.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
EOS

class License
  attr_accessor :gemname, :license, :author
end

licenses = []
license = nil
File.read("mruby/build/host/LEGAL").each_line{|l|
  l = l.strip
  if l.empty?
    license = nil
  elsif license == nil and l.start_with? "GEM:"
    license = License.new
    l = l.gsub "GEM: ", ""
    license.gemname = l
    licenses << license
  elsif license and l.start_with? "Copyright"
    license.author = l
  elsif license and l.start_with? "License: "
    license.license = l
  end
}

bundled_gems = licenses.select{|l| l.author.end_with? "mruby developers" }

f = File.open("LICENSES.txt","w")

f.puts "# minimeter\n" + File.read("LICENSE")
f.puts "----"

f.puts "# mruby and mrbgems"
f.puts bundled_gems.each_slice(4).map{|l|
  l.map{|a| a.gemname }.join(",")
}.join(",\n")
f.puts "\n#{bundled_gems.first.author}\n\n"
f.puts MIT
f.puts "----"

licenses.reject{|l| l.author.end_with? "mruby developers" }.each do |license|
  license_file = "mruby/build/mrbgems/#{license.gemname}/LICENSE"
  if File.exist? license_file
    f.puts "# #{license.gemname}\n"
    f.puts File.read(license_file)
    f.puts "----"
  elsif license.gemname = "mruby-io"
    f.puts "# #{license.gemname}"
    f.puts MRUBY_IO
    f.puts "----"
  end
end

`rm minimeter.zip; zip minimeter.zip -r minimeter.app LICENSES.txt -x "*.DS_Store"`
