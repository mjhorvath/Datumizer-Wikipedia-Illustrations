#include "colors.inc"
#include "math.inc"
#include "rand.inc"
#include "finish.inc"

#declare A = sqrt(3);
#declare truncoct = intersection
{
	box   {<-2,-2,-2,>, <+2,+2,+2,>}
	plane {<+1,+1,+1,>, A}
	plane {<+1,+1,-1,>, A}
	plane {<+1,-1,+1,>, A}
	plane {<+1,-1,-1,>, A}
	plane {<-1,+1,+1,>, A}
	plane {<-1,+1,-1,>, A}
	plane {<-1,-1,+1,>, A}
	plane {<-1,-1,-1,>, A}
}

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

background {color White}

#declare LX = 60;
#declare LZ = 100;
light_source {<+LX,-LX,+LZ,> color White parallel}
light_source {<+LX,+LX,+LZ,> color White parallel}

#declare extent = 3;
#declare i = -extent;
#while (i <= extent)
	#declare j = -extent;
	#while (j <= extent)
		#declare k = -extent;
		#while (k <= extent)
			#if (even(i + j) & even(i + k) & (i + j + 2 * k < 3 * extent) & Prob(0.95, RdmD))
				#declare RCOLOUR = rgbt <rand(RdmA),rand(RdmA),rand(RdmA),0,>;
				object
				{
					truncoct
					scale 0.48
					translate <i,j,k,>
					texture
					{
						pigment {color RCOLOUR}
						finish {Phong_Glossy}
					}
				}
			#end
			#declare k = k + 1;
		#end
		#declare j = j + 1;
	#end
	#declare i = i + 1;
#end

camera
{
	location	+y * 28
	direction	-y
	up		+z * 0.4
	right		+x * 0.4
	rotate		+x * 20
	rotate		-z * 30
	translate	-z * 0.5
	focal_point	vaxis_rotate(vaxis_rotate(+y * 6, +x, 20), -z, 30) - z * 0.5
	aperture	1
	blur_samples	20
}

plane
{
	z, -4
	pigment {color White}
	finish {Phong_Glossy}
}
