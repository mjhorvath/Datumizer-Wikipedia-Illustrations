// Title: RBG Spotlights on Wall (isosurface version)
// Authors: Michael Horvath, http://isometricland.net
// Created: 2019-05-27
// Updated: 2019-05-28
// License: CC BY-SA 4.0


#version 3.7
#include "functions.inc"
#include "math.inc"
#declare my_seed = seed(320987832);
#declare my_ambient = 1/64;

//------------------------------------------------------------------------------Environment

#local p_start		=	64/image_width;
#local p_end		=	4/image_width;
#local smooth_eb	=	0.50;
#local smooth_count	=	75;
#local final_eb		=	0.1875;
#local final_count	=	smooth_count * smooth_eb * smooth_eb / final_eb / final_eb;

global_settings
{
	assumed_gamma	1.0
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	0

	radiosity
	{
		pretrace_start	p_start
		pretrace_end	p_end
		count			final_count
		nearest_count	10
		error_bound		final_eb
		recursion_limit	3
		normal			on
		brightness		0.8
		always_sample	yes
		gray_threshold	0.8
		media			on
	}

}

sphere
{
	0, 1e+6
	inverse
	texture
	{
		pigment {color srgb my_ambient}
		finish {emission 1}
	}
	no_image
}

light_source
{
	-z * 32
	color rgb	my_ambient
	rotate		+x * 60
	rotate		+y * 60
	parallel
	point_at	0
	shadowless
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
#local cam_tran = transform
{
	rotate		<rand(my_seed)-1/2,rand(my_seed)-1/2,rand(my_seed)-1/2>
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

// BRICKS
// http://news.povray.org/povray.binaries.images/thread/%3C4458a6b4%40news.povray.org%3E/
#declare N_SCALE = 1/225/4;		//Texture scale
#declare M =  10.0/225/4;		//Mortar width and height
#declare G =   1.0/225/4;		//Mortar depth
#declare W = 215.0/225/4;		//Brick width
#declare D = 102.5/225/4;		//Brick depth
#declare H =  65.0/225/4;		//Brick height
#declare ROUGH = 0.45/16;		//Bump height
#declare BUSY = 0.40/2;			//Bump period
#declare OFFSET = D;			//Distance away from scene center

union
{
	#for (ix, -8, +8)
		#for (iy, -8, +8)
			#local TRANS = (rand(my_seed)-1/2);
			#local RANDX = (rand(my_seed)-1/2)*M/2;
			#local RANDY = (rand(my_seed)-1/2)*M/2;
			#local RANDZ = (rand(my_seed)-1/2)*G/2;
			#undef f_Height
			#local f_Height = function {f_wrinkles(x*(BUSY+TRANS), y*(BUSY+TRANS), z*(BUSY+TRANS)) * 1.2}
			isosurface
			{
				function
				{
					max
					(
						abs(x)-(W-ROUGH*f_Height(x, y, z)),
						abs(y)-(H-ROUGH*f_Height(x, y, z)),
						abs(z)-(D-ROUGH*f_Height(x, y, z)/2)
					)
				}
				contained_by
				{
					box{<-W, -H, -D>, <+W, +H, +D>}
				}
				max_gradient 1.3
				accuracy 1e-5
				//all_intersections
				translate +x * (RANDX + ix * (W*2+M))
				translate +y * (RANDY + iy * (H*2+M))
				translate +z * (RANDZ + OFFSET)
				#if (mod(iy,2) != 0)
					translate +x * (1/2 * (W*2+M))
				#end
			}
		#end
	#end
	texture
	{
		pigment {color srgb 1}
//		finish {diffuse 1}
		normal {granite 0.05 scale 0.005*N_SCALE}
		finish {phong 0.1 phong_size 4*N_SCALE}
	}
}

// MORTAR AROUND AND BEHIND THE BRICKS
#declare N_SCALE = N_SCALE;	//Texture scale
#declare M = M;				//Mortar width and height
#declare G = G*3;			//Mortar depth
#declare W = W*16;			//Brick width
#declare D = D-G;			//Brick depth
#declare H = H*16;			//Brick height
#declare ROUGH = ROUGH;		//Bump height
#declare BUSY = BUSY;		//Bump period
#declare OFFSET = OFFSET;	//Distance away from scene center
#undef f_Height
#local f_Height = function {f_wrinkles(x*BUSY, y*BUSY, z*BUSY) * 1.2}

isosurface
{
	function
	{
		max
		(
			abs(x)-(W-ROUGH*f_Height(x, y, z)),
			abs(y)-(H-ROUGH*f_Height(x, y, z)),
			abs(z)-(D-ROUGH*f_Height(x, y, z)/2)
		)
	}
	contained_by
	{
		box{<-W, -H, -D>, <+W, +H, +D>}
	}
	max_gradient 1.3
	accuracy 1e-5
	//all_intersections
	translate +z * OFFSET
	texture
	{
		pigment {color srgb 1/2}
//		finish {diffuse 1}
		normal {granite 0.1 scale 0.005*N_SCALE}
		finish {phong 0.1 phong_size 4*N_SCALE}
	}
}
