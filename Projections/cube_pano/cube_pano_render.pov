// +kfi0 +kff5
// render as a square image, 6 frames

#include "functions.inc"
#include "math.inc"

global_settings
{
	assumed_gamma	1.8
	adc_bailout	0.005
	max_trace_level	50
	radiosity
	{
		pretrace_start	0.08
		pretrace_end	0.01
		count		50
		error_bound	0.1
		recursion_limit	1
		normal		on
		brightness	0.8
		always_sample	yes
		gray_threshold	0.8
		media		on
	}
}

light_source
{
	<-30,+30,-30,>
	color rgb	<1,1,1,>
	parallel
}

light_source
{
	<-30,+30,-30,>
	color rgb	<1,1,1,>
	rotate		y * 090
	parallel
}

camera
{
	location	0
	direction	+z
	right		+x*2
	up		+y*2

	focal_point	+z * 4
	aperture	1/16
	blur_samples	20

	#switch (frame_number)
		#case (0)
			rotate	+y * 000
		#break
		#case (1)
			rotate	+y * 090
		#break
		#case (2)
			rotate	+y * 180
		#break
		#case (3)
			rotate	+y * 270
		#break
		#case (4)
			rotate	+x * 090
		#break
		#case (5)
			rotate	-x * 090
		#break
	#end

	translate	+y
}

sky_sphere
{
	pigment
	{
		gradient y
		color_map
		{
			[0 rgb 1]
			[1 rgb 3/4]
		}
	}
}


plane
{
	y,0
	pigment
	{
		checker
		color rgb 3/4, color rgb 1
		scale	1/4
	}
	translate	-y * 0.000001
}

isosurface
{
	function {abs(x)-1+y}
	contained_by {box {-2,+2}}
	translate	+y * 2
	scale		7/8
	scale		1/2
	translate	-z * 4
	pigment {color rgb x+y}
}

isosurface
{
	function {abs(x)+abs(y)+abs(z)-2}
	contained_by {box {-2,+2}}
	max_gradient	2
	translate	+y * 2
	scale		1/2
	translate	+z * 4
	pigment {color rgb z}
}

sphere
{
	y, 1
	pigment {color rgb x}
	translate	-x * 4
}

box
{
	-1,+1
	translate	+y
	scale		3/4
	pigment {color rgb y}
	translate	+x * 4
}
