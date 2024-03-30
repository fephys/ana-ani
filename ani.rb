# run-on-change % a.rb ani.sh -- ruby % -- sh ani.sh

require 'fileutils'

FileUtils::mkdir_p('out')

def step(a,b,n)
  0.upto(n) do |i|
    yield(a+(b/n)*i)
  end
end

$num=1000
def run(e,i)
  system('ruby', 'a.rb', "e:#{e}", "i:#{i}", "fn=out/x#{$num+=1}")
end

step(0,0,10) do |x|
  run(0, 0)
end

step(0,23.4,30) do |x|
  run(0,x)
end

step(0,0.0167, 30) do |x|
  run(x,23.4)
end

step(0,0,10) do |x|
  run(0.0167,23.4)
end
