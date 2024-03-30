#!/usr/bin/ruby

# run-on-change % -- ruby % -- cat ana.data

# rmin = a*(1-e); rmax = a*(1+e)
# meaning the on the major axis of length 2 the sun is e units off the center.

include Math

def dpn(n,d)
  n.to_s[0..d]
end


par={ 'e' => 0.0167, 'i' => 23.4, 'fn' => 'ana' }

ARGV.each do |a|
  if a =~ %r{\A([a-z]+):}
    par[$1]=$'.to_f
  elsif a =~ %r{\A([a-z]+)=}
    par[$1]=$'.chomp
  else
    puts "Wat? #{a.inspect}?"
    exit 1
  end
end

e=par['e']
inc=par['i']

puts e.inspect
b=sqrt(1-e*e)

TAU=2*PI

a=0
ta=b*PI

i=0.0
INC=0.00001
nn=0
nl=[]
lx=1-e
ly=0
lf=0
while i < 1.0-INC/2
  i+=INC
  f=TAU*i
  x=cos(f)-e
  y=b*sin(f)

  da=(lx*y-x*ly)/2.0
  a+=da

  if a > nn
    nl.push(f)
    nn+=ta/67.0
    #puts (f-lf)*67
    lf=f
  end

  lx=x
  ly=y
end
nl.push(TAU)

puts b*PI-a

# nl: array with true sun angle for constant intervals.

#puts nl.inspect

def ang(f,nl)
  s=nl.size-1
  x=(f/TAU)*s
  i=x.to_i
  f=x-i
  a=i/s
  i=i%s
 #puts "#{x} #{i} #{f} #{a}"
  nl[i]+f*(nl[i+1]-nl[i])+a*TAU
end

def d2r(x)
  PI*x/180.0
end

def r2d(x)
  180.0*x/PI
end

class V3
  attr_accessor :x, :y, :z

  def initialize(x,y,z)
    @x=x
    @y=y
    @z=z
  end

  def rot_y(a)
    si=sin(a)
    co=cos(a)
    V3.new(co*x+si*z, y, co*z-si*x)
  end

  def rot_z(a)
    si=sin(a)
    co=cos(a)
    V3.new(co*x+si*y, co*y-si*x, z)
  end

end

EQUI=TAU*((20+29+21)/365.0)

File.open("ana.data", 'w') do |of|

  0.upto 52 do |i|
    f=i/52.0*TAU         # Position in the year
    df=(ang(f,nl)-f)     # Ecliptical offset of the sun
    puts "#{r2d(f)} #{r2d(df)}"
    # puts ang(f,nl)

    # Ecliptic direction vector to the sun. (right, up, out)
    ev=V3.new(sin(f+df), 0, cos(f+df))

    # Position on celestial sphere.
    qv=ev.rot_y(EQUI).rot_z(d2r(inc)).rot_y(-EQUI)                       # MISSING: offset to spring equinoxe!

    # Rotate back for noon position.
    vv=qv.rot_y(-f)
    puts "                                        #{vv.x} #{vv.y} #{vv.z}"

    nx=r2d(atan2(vv.x, vv.z))
    ny=r2d(atan2(vv.y, vv.z))

    of.puts("#{nx} #{ny}")
  
  end
end

# Ok, the above says how much the sun is sideways off noon due
# to the excentric orbit.

# And this angle is on the ecliptic, meaning it's a little closer to
# the celestial equator when off noon.

# Now, the height.


IO.popen("gnuplot","w") do |f|
    f.puts "set terminal png size 768,768"
    f.puts "set title \"analemma\" tc rgb'green'"

    f.puts "set output \"#{par['fn']}.png\""

    # f.puts "set xtics scale 0.6"
    f.puts "set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb'#002200' behind"
    f.puts "set border lc rgb'gray'"
    f.puts "set xtics tc rgb'gray'"
    f.puts "set ytics tc rgb'gray'"
    f.puts "set key tc rgb'gray'"
#   ## f.puts "set y2tics autofreq nomirror"
#   f.puts "set timefmt \"%s\""
#   if v > 7000
#     f.puts "set format x \"%d.%m\""
#   else
#     f.puts "set format x \"%d.%m %H\""
#   end
#   f.puts "set xdata time"
    f.puts "set key horizontal below"
    f.puts "set xrange [\"-7\":\"7\"]"
    f.puts "set yrange [\"-25\":\"25\"]"
#   f.puts "set xrange [\"#{to-(r == 7 ? 5400 : r == 0 ? 86400/3 : r*86400)}\":\"#{to}\"]"
    f.puts "set grid"
    f.puts "set style line 1 lw 4"
    # f.puts "set logscale xy"
    f.puts "plot \"ana.data\" using 1:2 with lines ls 1 title \"e: #{dpn e, 6}, i: #{dpn inc, 3}\""
    # f.puts "plot \"blafase\" using 1:2 with lines title \"a\""
  end
