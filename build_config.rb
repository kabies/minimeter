MRuby::Build.new do |conf|
  toolchain :gcc

  conf.gem github:'mruby-sdl2/mruby-sdl2' do |g|
    g.cc.include_paths << "#{ENV['FRAMEWORKS_PATH']}/SDL2.framework/Headers/"
  end

  conf.gem github: 'mruby-sdl2/mruby-sdl2-cocoa' do |g|
    g.objc.include_paths << "#{ENV['FRAMEWORKS_PATH']}/SDL2.framework/Headers/"
  end

  conf.gem :core => 'mruby-io'
  conf.gem :core => 'mruby-exit'

  conf.gembox 'default'

  conf.cc do |cc|
    cc.defines += %w(MRB_UTF8_STRING MRB_32BIT)
  end

  conf.objc do |cc|
    cc.defines += %w(MRB_UTF8_STRING)
  end

  conf.linker do |linker|
    linker.flags << "-F#{ENV['FRAMEWORKS_PATH']}"
    linker.flags << "-framework SDL2"
  end
end
