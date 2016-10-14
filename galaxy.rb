#Galactic Garden
#A galaxy generator by Joel Forster, @takenbymood
#Feel free to distribute, modify and learn from this without giving me credit!
#Just don't make money off it without permission and we're all good <3

require 'rmagick'
include Magick

class Galaxy
	@stars=0
	@r0=0
	
	def initialize
		
	end

	def randFactor
		#ugly method for returning a number between 0 and 1 (which is never 0)
		return (Random.rand(10000000)+1)*0.0000001
	end

	def gaussianrand()
		#uses the fast box muller method to generate gaussian randomness
		w = 10.0
		u = 0
		v = 0
		while w>=1.0 
			u = 2*randFactor - 1.0
			v = 2*randFactor - 1.0
			w = u*u + v*v
		end
		w = Math.sqrt((-2.0*Math.log(w))/w);
        y1 = u*w;
        y2 = v*w;
		return y1
	end

	def generate(stars,r0)
		imagescale=1/(r0*0.02)
		image = Image.new(600,600)
		image.color_reset!("black")
		@stars = stars
		pixelscale = (1/imagescale)
		
		#r0 is the characteristic radius of the galaxy
		@r0 = r0
		print "new galaxy with ", @stars, " stars, and radius ", @r0,"\n"
		print "each pixel is ", pixelscale.round , " light years across\n"

			#stellar distribution parameters
			gB = randFactor()
			gN = 50*randFactor()
			gA = 1
			print "A",gA,"\n"
			print "B",gB,"\n"
			print "N",gN,"\n"

			#random galactic orientation
			oOffset = Math::PI*randFactor()

			#brightness factor (determines how faint the stars will appear)
			bf = (500/pixelscale)
			bf = bf*bf
			print "star brightness factor ", bf, "\n"

		for i in 0..@stars

			#reverse sampling the galactic distribution equation for polar radius
			n = randFactor()
			r = -r0*Math.log(n)

			o=0
			if r<(4*r0 + Random.rand(r0))
				#calculate polar angle from the equation provided in https://arxiv.org/abs/0908.0892
				o = (2*gN)*Math.atan((1/gB)*Math::E**(gA/(r/r0))) + oOffset + Random.rand(2)*Math::PI
			else
				#if the stars are distant, simply randomise them
				o = Random.rand(62832)*0.0001
			end

			#calculate perfect x and y postions

			x = r*Math.cos(o)
			y = r*Math.sin(o)
			ro = Math::PI*2*randFactor()

			#calculate noise on star position according to normal distribution
			noise=0
			noise = 0.75*gaussianrand() + 0.25*randFactor() - 0.125

			#calculate resultant noise in cartesians
			rr = r0*noise
			rx = rr*Math.cos(ro)
			ry = rr*Math.sin(ro)

			#apply noise
			x+=rx
			y+=ry

			#pixel position of star, group stars together if they're close
			ix = (x*imagescale+image.columns*0.5).round
			iy = (y*imagescale+image.rows*0.5).round

			#big mess working out star brightness
			sc = Pixel.new(65535*bf,65535*bf,65535*bf,0)
			cc = image.pixel_color(ix,iy)
			nr = 0
			ng = 0 
			nb = 0
			if cc.red+sc.red > 65535
				nr = 65535
			else
				nr = cc.red+sc.red
			end

			if cc.green+sc.green > 65535
				ng = 65535
			else
				ng = cc.green+sc.green
			end

			if cc.blue+sc.blue > 65535
				nb = 65535
			else
				nb = cc.blue+sc.blue
			end
			newcolor = Pixel.new(nr,ng,nb,0)

			#apply star to canvas
			image.pixel_color(ix,iy,newcolor)

		end
		#write image
		image.write("g.png")
	end
end

g = Galaxy.new()
nstars = Random.rand(100000)+75000
radius = Random.rand(50000)+75000
g.generate(nstars,radius)