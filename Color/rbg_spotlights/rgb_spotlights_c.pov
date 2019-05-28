// Title: RBG Spotlights on Wall (height field version, needs work)
// Authors: Michael Horvath, http://isometricland.net
// Created: 2019-05-27
// Updated: 2019-05-28
// License: CC BY-SA 4.0


#version 3.7
#include "functions.inc"
#include "math.inc"
#declare my_seed = seed(320987832);

//------------------------------------------------------------------------------Environment

global_settings
{
	assumed_gamma	1.0
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	0
/*
	radiosity
	{
		pretrace_start	0.08
		pretrace_end	0.01
		count			50
		error_bound		0.1
		recursion_limit	1
		normal			on
		brightness		0.8
		always_sample	yes
		gray_threshold	0.8
		media			on
	}
*/
}

background {color srgb 14}

light_source
{
	-z * 32
	color rgb	1/1
	rotate		+x * 60
	rotate		+y * 60
	parallel
	point_at	0
}

light_source
{
	-z * 32
	color rgb	1/1
	rotate		+x * 30
	rotate		-y * 60
	parallel
	point_at	0
	shadowless
}

/*
light_source
{
	-z/2
	color rgb	x * 2
	spotlight
	radius		45/2
	falloff		45
	tightness	0
	point_at	0
	rotate		+x * 060
	translate	-y/4
	rotate		+z * 000
	rotate		<rand(my_seed)*30-15,rand(my_seed)*30-15,rand(my_seed)*30-15>
}

light_source
{
	-z/2
	color rgb	y * 2
	spotlight
	radius		45/2
	falloff		45
	tightness	0
	point_at	0
	rotate		+x * 060
	translate	-y/4
	rotate		+z * 120
	rotate		<rand(my_seed)*30-15,rand(my_seed)*30-15,rand(my_seed)*30-15>
}

light_source
{
	-z/2
	color rgb	z * 2
	spotlight
	radius		45/2
	falloff		45
	tightness	0
	point_at	0
	rotate		+x * 060
	translate	-y/4
	rotate		+z * 240
	rotate		<rand(my_seed)*30-15,rand(my_seed)*30-15,rand(my_seed)*30-15>
}
*/
#local cam_aspc = image_width/image_height;		// obsolete. render square images only!
#local cam_dist = 16;
#local cam_area = 2;
#local cam_loca = -z * cam_dist;
#local cam_dirc = +z * cam_dist;
#local cam_rgvc = +x * cam_area * cam_aspc;
#local cam_upvc = +y * cam_area;
#local cam_tran = transform
{
	rotate +x * 30
	rotate -y * 45
}

camera
{
	orthographic
	location	cam_loca				// position
	direction	cam_dirc				// direction of view
	right		cam_rgvc				// horizontal size of view
	up			cam_upvc				// vertical size of view
	transform {cam_tran}				// transforms
}

//------------------------------------------------------------------------------Objects
/*
plane
{
	-z, 0
	pigment {color srgb 1}
	finish {diffuse 1}
}
*/

#declare HF_Scale = 4;

// http://news.povray.org/povray.binaries.images/thread/%3C4458a6b4%40news.povray.org%3E/
#declare W = 215.0/225/4;		//Width
#declare D = 102.5/225/4;		//Depth
#declare H =  65.0/225/4;		//Height
#declare M =  10.0/225/4;		//Mortar
#declare ROUGH = 0.45/8;	//Bump height
#declare BUSY = 0.40/2;		//Bump period

#for (ix, -8, +8)
	#for (iy, -8, +8)
		#local TRANS = rand(my_seed)-1/2;
		#undef f_Height
		#local f_Height = function {f_wrinkles(x*(BUSY+TRANS), y*(BUSY+TRANS), z*(BUSY+TRANS))}
		#undef f_What
		#local f_What = function
		{
			max
			(
				abs(x)-(1-ROUGH*f_Height(x, y, z)),
				abs(y)-(1-ROUGH*f_Height(x, y, z)),
				abs(z)-(1-ROUGH*f_Height(x, y, z))
			)
		}
		height_field
		{
			function  32, 32 {f_What(x,y,z)}
			smooth 
			texture
			{
				pigment{color srgb <0.6,0.55,0.5>}
//				normal {bumps 0.1 scale 0.005}
//				finish {phong 0.1 phong_size 400}
			}
//			rotate z * 90
//			scale <+W, +H, +D> * 2
//			scale 1/2
		}
	#end
#end
/*
#declare FACT = 31/32;		//Mortar shrink
#declare W = W*10;			//Width
#declare D = D*FACT;		//Depth
#declare H = H*10;			//Height
#declare M = M;				//Mortar
#declare ROUGH = 0.45/8;	//Bump height
#declare BUSY = 0.40/2;		//Bump period
#undef f_Height
#local f_Height = function {f_wrinkles(x*BUSY, y*BUSY, z*BUSY)}
isosurface
{
	function
	{
		max
		(
			abs(x)-(W-ROUGH*f_Height(x, y, z)),
			abs(y)-(H-ROUGH*f_Height(x, y, z)),
			abs(z)-(D-ROUGH*f_Height(x, y, z)/4)
		)
	}
	contained_by
	{
		box{<-W, -H, -D>, <+W, +H, +D>}
	}
	max_gradient 1.3
	accuracy 1e-5
	//all_intersections
	texture
	{
		pigment {color srgb 1}
		finish {diffuse 1}
//		normal {granite 0.1 scale 0.005*HF_Scale}
//		finish {phong 0.1 phong_size 4 diffuse 1}
	}
	translate +z * D/FACT
}
*/
