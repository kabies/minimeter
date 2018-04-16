#!/usr/bin/env ruby

def build_mruby
  repository="https://github.com/mruby/mruby.git"
  dir="mruby"
  mruby_config="../build_config.rb"
  frameworks_path="$HOME/Library/Frameworks"

  `git clone -b 1.4.0 #{repository} #{dir}`

  Dir.chdir(dir) do
    system "env FRAMEWORKS_PATH=#{frameworks_path} MRUBY_CONFIG=#{mruby_config} ruby minirake -v all"
  end
end

def build_macos
  Dir.chdir ROOT_DIR
  app_name = "minimeter"
  dir = "#{app_name}.app"

  `mkdir -p #{dir}/Contents/MacOS`
  `mkdir -p #{dir}/Contents/Resources`
  `mkdir -p #{dir}/Contents/Frameworks`

  # Info.plist
  `cp Info.plist #{dir}/Contents/Info.plist`

  # executable
  `cp launch.sh #{dir}/Contents/MacOS/`
  `chmod 755 #{dir}/Contents/MacOS/launch.sh`

  # icon
  unless File.exists? "icon.icns"
    `mkdir -p icon.iconset`

    original_icon = "icon.png"

    [
      ["16 16","16x16"],
      ["32 32","16x16@2x"],
      ["32 32","32x32"],
      ["64 64","32x32@2x"],
      ["128 128","128x128"],
      ["256 256","128x128@2x"],
      ["256 256","256x256"],
      ["512 512","256x256@2x"],
      ["512 512","512x512"],
      ["1024 1024","512x512@2x"],
    ].each{|size,name|
      `sips -z #{size} #{original_icon} --out icon.iconset/icon_#{name}.png`
    }
    `iconutil -c icns icon.iconset`
  end

  `cp -R icon.icns #{dir}/Contents/Resources/AppIcon.icns`
  # resources
  `cp -R mruby/build/host/bin/mruby #{dir}/Contents/MacOS/mruby`
  `cp meter.rb #{dir}/Contents/Resources`
  # Frameworks
  [
    'SDL2',
    # 'SDL2_image',
    # 'SDL2_ttf',
    # 'SDL2_mixer'
  ].each{|f|
    unless File.exists? "#{dir}/Contents/Frameworks/#{f}.framework"
      `cp -R #{FRAMEWORKS_PATH}/#{f}.framework #{dir}/Contents/Frameworks`
    end
    original_path = "@rpath/#{f}.framework/Versions/A/#{f}"
    bundled_path = "@executable_path/../Frameworks/#{f}.framework/Versions/A/#{f}"
    `install_name_tool -change #{original_path} #{bundled_path} #{dir}/Contents/MacOS/mruby`
  }
  puts `otool -L #{dir}/Contents/MacOS/mruby`
end

if $0==__FILE__
  FRAMEWORKS_PATH = "~/Library/Frameworks"
  ROOT_DIR = File.expand_path("./")
  build_mruby
  build_macos
end
