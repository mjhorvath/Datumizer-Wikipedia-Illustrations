#include "colors.inc"
#include "math.inc"
#include "rand.inc"
#include "finish.inc"

#declare A = sqrt(2);
#declare R = 0.025;

#declare rhombdod = intersection
{
	box   {<-2,-2,-2>, <+2,+2,+2>}
	plane {<+1,+1,+0>, A} 
	plane {<+1,-1,+0>, A}
	plane {<-1,+1,+0>, A}
	plane {<-1,-1,+0>, A}
	plane {<+1,+0,+1>, A}
	plane {<+1,+0,-1>, A}
	plane {<-1,+0,+1>, A}
	plane {<-1,+0,-1>, A}
	plane {<+0,+1,+1>, A}
	plane {<+0,+1,-1>, A}
	plane {<+0,-1,+1>, A}
	plane {<+0,-1,-1>, A}
}

#declare tripod = union
{
	cylinder {<+2,+0,+0>, <+1,+1,+1>, R}
	cylinder {<+0,+2,+0>, <+1,+1,+1>, R}
	cylinder {<+0,+0,+2>, <+1,+1,+1>, R}
	sphere   {<+1,+1,+1>, R}
}

#declare rhombdodedges = union
{
	object {tripod}
	object {tripod rotate 090 * z}
	object {tripod rotate 180 * z}
	object {tripod rotate 270 * z}
	object {tripod rotate 180 * x}
	object {tripod rotate 180 * x rotate 090 * z}
	object {tripod rotate 180 * x rotate 180 * z}
	object {tripod rotate 180 * x rotate 270 * z}
	sphere {<+2,+0,+0 >, R}
	sphere {<-2,+0,+0 >, R}
	sphere {<+0,+2,+0 >, R}
	sphere {<+0,-2,+0 >, R}
	sphere {<+0,+0,+2 >, R}
	sphere {<+0,+0,-2 >, R}
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

#declare extent = 2;
#declare i = -extent;
#while (i <= extent)
	#declare j = -extent;
	#while (j <= extent)
		#declare k = -extent;
		#while (k <= extent)
			#if (even(i + j + k) & (i + j + 2 * k < 3 * extent) & Prob(0.95, RdmD))
				#declare RCOLOUR = rgbt <rand(RdmA),rand(RdmA),rand(RdmA),0,>;
				object
				{
					rhombdod
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
	location	+y * 20
	direction	-y
	up		+z * 0.4
	right		+x * 0.4
	rotate		+x * 20
	rotate		-z * 10
	focal_point	vaxis_rotate(vaxis_rotate(+y * 4, +x, 20), -z, 10)
	aperture	1
	blur_samples	20
}

plane
{
	z, -3
	pigment {color White}
	finish {Phong_Glossy}
}
