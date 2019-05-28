// Title: RBG Spotlights on Wall (flat surface version)
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

background {color srgb 0}

light_source
{
	-z * 32
	color rgb	1/32
	parallel
	point_at	0
	rotate		+x * 60
	rotate		+y * 60
}

light_source
{
	-z/2
	color rgb	x
	spotlight
	radius		30
	falloff		45
	tightness	0
	fade_distance 1
	fade_power	3
	point_at	0
	rotate		+x * 060
	translate	-y/4
	rotate		+z * 000
	rotate		<rand(my_seed)*30-15,rand(my_seed)*30-15,rand(my_seed)*30-15>
}

light_source
{
	-z/2
	color rgb	y
	spotlight
	radius		30
	falloff		45
	tightness	0
	fade_distance 1
	fade_power	3
	point_at	0
	rotate		+x * 060
	translate	-y/4
	rotate		+z * 120
	rotate		<rand(my_seed)*30-15,rand(my_seed)*30-15,rand(my_seed)*30-15>
}

light_source
{
	-z/2
	color rgb	z
	spotlight
	radius		30
	falloff		45
	tightness	0
	fade_distance 1
	fade_power	3
	point_at	0
	rotate		+x * 060
	translate	-y/4
	rotate		+z * 240
	rotate		<rand(my_seed)*30-15,rand(my_seed)*30-15,rand(my_seed)*30-15>
}

#local cam_aspc = image_width/image_height;		// obsolete. render square images only!
#local cam_dist = 16;
#local cam_area = 2;
#local cam_loca = -z * cam_dist;
#local cam_dirc = +z * cam_dist;
#local cam_rgvc = +x * cam_area * cam_aspc;
#local cam_upvc = +y * cam_area;
#local cam_tran = transform {}

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

#declare W = 215.0/225/4;		//Brick width
#declare D = 102.5/225/4;		//Brick depth
#declare H =  65.0/225/4;		//Brick height
#declare M =  10.0/225/4;		//Mortar width and height
#declare OFFSET = D;			//Distance away from scene center

#for (ix, -8, +8)
	#for (iy, -8, +8)
		box
		{
			<-W, -H, -D>,
			<+W, +H, +D>
			texture
			{
				pigment {color srgb 1}
				finish {diffuse 1}
			}
			translate +x * (ix * (W*2+M))
			translate +y * (iy * (H*2+M))
			translate +z * (OFFSET)
			#if (mod(iy,2) != 0)
				translate +x * (1/2 * (W*2+M))
			#end
		}
	#end
#end

#declare W = W*16;			//Brick width
#declare D = D-1/32;		//Brick depth
#declare H = H*16;			//Brick height
#declare M = M;				//Mortar width and height
#declare OFFSET = OFFSET;	//Distance away from scene center

box
{
	<-W, -H, -D>,
	<+W, +H, +D>
	texture
	{
		pigment {color srgb 1/2}
		finish {diffuse 1}
	}
	translate +z * OFFSET
}
