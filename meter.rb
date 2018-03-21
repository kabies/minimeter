
# usage: iostat -dC -w 1 disk0 | mruby stdin_read.rb

SDL2::Hints.set SDL2::Hints::SDL_HINT_RENDER_DRIVER, "opengl"

SDL2::init
SDL2::Video::init

W,H = 200,4
FLAGS = SDL2::Video::Window::SDL_WINDOW_OPENGL | SDL2::Video::Window::SDL_WINDOW_BORDERLESS
window = SDL2::Video::Window.new "minimeter", 0,0, W, H, FLAGS
renderer = SDL2::Video::Renderer.new window
p [:renderer, renderer.info.name]

window.draggable = true
window.on_top
window.change_transparency
# window.position = SDL2::Point.new(0,0)

cpu_history = Array.new(100)
disk_history = Array.new(100)

network_usage = (`netstat -I en0 -n -b`).lines[1].split
in_history = Array.new(100)
out_history = Array.new(100)
in_prev = network_usage[6].to_f
out_prev = network_usage[9].to_f

loop do
  l = STDIN.gets
  next if l.include? "disk0"
  next if l.include? "id"

  a = l.split
  kbyte_trans = a[0].to_f
  cpu_idle = a[5].to_i

  # Dsik Usage
  disk_history.unshift kbyte_trans
  disk_history.pop

  # CPU Usage
  cpu_usage = 100 - cpu_idle
  cpu_history.unshift cpu_usage
  cpu_history.pop

  # Network
  network_usage = (`netstat -I en0 -n -b`).lines[1].split
  in_bytes  = network_usage[6].to_f
  out_bytes = network_usage[9].to_f
  in_history.unshift( (in_bytes - in_prev).to_i )
  out_history.unshift( (out_bytes - out_prev).to_i )
  in_history.pop
  out_history.pop
  in_prev = in_bytes
  out_prev = out_bytes

  p [:cpu, cpu_usage, :disk, kbyte_trans, :in, in_history[0]/1000, :out, out_history[0]/1000 ]

  renderer.set_draw_color 0,0,0,64
  renderer.fill_rect SDL2::Rect.new(0,0,W,H)

  [in_history,out_history].each_with_index{|h,y|
    h.each_with_index{|c,i|
      if c.to_i == 0
        # nop
        next
      elsif c.to_i < 100*1000 # Green
        renderer.set_draw_color 0,0xFF,0,128
      elsif c.to_i < 1000*1000 # Yellow
        renderer.set_draw_color 0xFF,0xFF,0,128
      elsif c.to_i < 5000*1000 # Orange
        renderer.set_draw_color 0xFF,128,0,128
      else # RED
        renderer.set_draw_color 0xFF,0,0,128
      end
      renderer.draw_line SDL2::Point.new(100+i,y*2),  SDL2::Point.new(100+i,y*2+1)
    }
  }

  cpu_history.each_with_index{|c,i|
    if c.to_i < 10 # none
      # nop!
      next
    elsif c.to_i < 20 # Green
      renderer.set_draw_color 0,0xFF,0,0xff
    elsif c.to_i < 40 # Yellow
      renderer.set_draw_color 0xFF,0xFF,0,0xff
    elsif c.to_i < 60 # Orange
      renderer.set_draw_color 0xFF,128,0,0xff
    else # RED
      renderer.set_draw_color 0xFF,0,0,0xff
    end
    renderer.draw_line SDL2::Point.new(i,0),  SDL2::Point.new(i, 1)
  }

  disk_history.each_with_index{|c,i|
    if c.to_f == 0 # none
      # nop!
      next
    elsif c.to_i < 32 # Green
      renderer.set_draw_color 0,0xFF,0,0xff
    elsif c.to_i < 64 # Yellow
      renderer.set_draw_color 0xFF,0xFF,0,0xff
    elsif c.to_i < 128 # Orange
      renderer.set_draw_color 0xFF,128,0,0xff
    else # RED
      renderer.set_draw_color 0xFF,0,0,0xff
    end
    renderer.draw_line SDL2::Point.new(i,2),  SDL2::Point.new(i,3)
  }

  renderer.set_draw_color 0,0,0xFF,0xFF
  renderer.draw_line SDL2::Point.new(100,0),  SDL2::Point.new(100,3)

  renderer.present

  while ev = SDL2::Input::poll()
    case ev.type
    when SDL2::Input::SDL_QUIT
      puts "good bye."
      exit(1)
    end
  end
  SDL2::delay 500
end
