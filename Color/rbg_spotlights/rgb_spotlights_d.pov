// Title: RBG Spotlights on Wall (meshrelief version, needs work)
// Authors: Michael Horvath, http://isometricland.net
// Created: 2019-05-27
// Updated: 2021-01-30
// License: CC BY-SA 4.0


#version 3.7
#include "functions.inc"
#include "math.inc"
#include "meshrelief.inc"		// http://www.infradead.org/~wmp/macro_meshrelief.html
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
/*
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
*/

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

// http://news.povray.org/povray.binaries.images/thread/%3C4458a6b4%40news.povray.org%3E/
#declare N_SCALE	= 1/225/4;				//Brick scale
#declare M			=  10.0 * N_SCALE;		//Mortar width and height
#declare G			=   1.0 * N_SCALE;		//Mortar depth
#declare W			= 215.0 * N_SCALE;		//Brick width
#declare H			=  65.0 * N_SCALE;		//Brick height
#declare D			= 102.5 * N_SCALE;		//Brick depth
#declare R			=   8.0 * N_SCALE;		//Brick corner radius
#declare P			=   2.0 * N_SCALE;		//Brick surface displacement depth
#declare A			= 1;					//Brick max rotation angle
#declare ROUGH		= 0.45/16;				//Bump height
#declare BUSY		= 0.40/2;				//Bump period
#declare OFFSET		= D;					//Distance away from scene center
#declare BOXMAX		= 4;
#declare BOXOBJS	= array[BOXMAX];
#declare BOXTEX = texture
{
	pigment {color srgb 1}
	finish {diffuse 1 phong 0.5 phong_size 40}
//	normal {granite 1 scale M}
}
#declare GOUTEX = texture
{
	pigment {color srgb 1}
	finish {diffuse 1 phong 0.5 phong_size 40}
//	normal {granite 1 scale M}
}

#for (ia, 0, BOXMAX-1)
	#debug concat("ia = ",str(ia,0,0),"\n")
	#local ROTATX1 = rand(my_seed)*360;
	#local ROTATY1 = rand(my_seed)*360;
	#local ROTATZ1 = rand(my_seed)*360;
	#local TRANSX1 = (rand(my_seed)*2-1)*W*16;
	#local TRANSY1 = (rand(my_seed)*2-1)*H*01;
	#local TRANSZ1 = (rand(my_seed)*2-1)*D*16;
	#local ISOPIG = pigment
	{
		granite
		color_map
		{
			[0.0 rgb 0.2]
			[0.4 rgb 0.0]
			[1.0 rgb 1.0]
		}
		scale N_SCALE * 100
		rotate +x * ROTATX1
		rotate +y * ROTATX1
		rotate +z * ROTATX1
		translate +x * (TRANSX1)
		translate +y * (TRANSY1)
		translate +z * (TRANSZ1)
	}
	// Weathered_Box(p1, p2, edge, res, pig, dep, smoothed, sav, nam)
	//   p1, p2 = vectors - diagonal corners of box
	//   edge = float - radius of curvature of edges
	//   res = integer - resolution of mesh
	//   pig = pigment identifier - pigment for surface displacement function
	//   dep = float - depth of surface displacement (-ve produces raised displacement)
	//   smoothed = yes/no - smoothed triangles
	//   sav = yes/no - saving .inc file
	//   nam = string/string identifier - name of resulting mesh / .inc file
	#local BOXOBJ = object
	{
		Weathered_Box(<-W,-H,-D>, <+W,+H,+D>, R, 320, ISOPIG, P, yes, no, "")
		texture {BOXTEX}
	}
	#declare BOXOBJS[ia] = BOXOBJ;
#end


union
{
	#for (ix, -8, +8)
//		#debug concat("ix = ",str(ix,0,0),"\n")
		#for (iy, -8, +8)
//			#debug concat("  iy = ",str(iy,0,0),"\n")
			#local ROTATX2 = (rand(my_seed)-1/2)*A;
			#local ROTATY2 = (rand(my_seed)-1/2)*A;
			#local ROTATZ2 = (rand(my_seed)-1/2)*A;
			#local TRANSX2 = (rand(my_seed)-1/2)*M/2;
			#local TRANSY2 = (rand(my_seed)-1/2)*M/2;
			#local TRANSZ2 = (rand(my_seed)-1/2)*G/2;
			#local BOXNUM = floor(rand(my_seed) * BOXMAX);
			object
			{
				BOXOBJS[BOXNUM]
				#if (rand(my_seed) < 0.5)
					rotate +x * 180
				#end
				#if (rand(my_seed) < 0.5)
					rotate +y * 180
				#end
				#if (rand(my_seed) < 0.5)
					rotate +z * 180
				#end
				rotate +x * ROTATX2
				rotate +y * ROTATX2
				rotate +z * ROTATX2
				translate +x * (TRANSX2 + ix * (W*2+M))
				translate +y * (TRANSY2 + iy * (H*2+M))
				translate +z * (TRANSZ2 + OFFSET)
				#if (mod(iy,2) != 0)
					translate +x * (1/2 * (W*2+M))
				#end
			}
		#end
	#end
}


// MORTAR AROUND AND BEHIND THE BRICKS
#declare N_SCALE = N_SCALE;	//Texture scale
#declare M = M;				//Mortar width and height
#declare G = G;				//Mortar depth
#declare W = W*16-G;		//Brick width
#declare H = H*16-G;		//Brick height
#declare D = D*01-G;		//Brick depth
#declare ROUGH = ROUGH;		//Bump height
#declare BUSY = BUSY;		//Bump period
#declare OFFSET = OFFSET;	//Distance away from scene center
#undef f_Height
#declare f_Height = function {f_wrinkles(x*BUSY, y*BUSY, z*BUSY) * 2}

isosurface
{
	function
	{
		max
		(
			abs(x)-(W-ROUGH*f_Height(x, y, z)),
			abs(y)-(H-ROUGH*f_Height(x, y, z)),
			abs(z)-(D-ROUGH*f_Height(x, y, z))
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
	texture {GOUTEX}
}
