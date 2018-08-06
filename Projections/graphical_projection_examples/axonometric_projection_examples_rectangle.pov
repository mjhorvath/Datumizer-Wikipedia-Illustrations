// Title: Graphical projection examples
// Author: Michael Horvath
// Webiste: http://isometricland.net
// Created: 2017-05-02
// Updated: 2017-05-14
// This file is licensed under the terms of the CC-LGPL.
// Render this scene at 640x480px.
// +kfi0 +kff3
// -uv

#version 3.7;
#include "Axes_macro.inc"	// available from the POV-Ray Object Collection
#include "functions.inc"
#include "math.inc"
#include "screen.inc"		// requires the updated version available here: http://news.povray.org/povray.text.scene-files/thread/%3C581be4f1%241%40news.povray.org%3E/
#include "strings.inc"

#declare proj_type	= 2;		// integer: type of projection being demonstrated; 0 = multiview, 1 = isometric, 2 = oblique, 3 = perspective
#declare floor_drop	= 2;		// float: distance of floor from center
#declare trans_zamt	= 2;		// float
#declare cam_view	= 2;		// integer: camera perspective; 0 = perspective pictorial, 1 = orthographic top, 2 = orthographic front
#declare pane_size	= <2,2,0>;	// vector
#declare base_size	= <3,0,4>;	// vector
#declare cube_scale	= 1/2;		// float

//------------------------------------------------------------------------------Scenery

global_settings
{
	assumed_gamma	1.0
	adc_bailout	0.005
	max_trace_level	50
	charset		utf8
/*
	ambient_light	0
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
*/
}

background {color srgb <096,144,255,>/255}

light_source
{
	<-30,+30,-30,>
	color rgb	1
	rotate		y * 330
	parallel
	point_at	0
	shadowless
}

light_source
{
	<0,+30,0,>
	color rgb	1
	parallel
	point_at	0
//	shadowless
}


#switch (cam_view)
	// perspective pictorial
	#case (0)
		#local cam_aspc		= image_width/image_height;		// obsolete. render square images only!
		#local cam_dist		= 8;
		#local cam_move		= -y * 1/3;
		#local cam_scale	= 4;
		#local cam_area		= 2*1;
		#local cam_loca		= -z * cam_dist;
		#local cam_dirc		= +z;
		#local cam_rgvc		= +x * cam_area/cam_dist * cam_aspc;
		#local cam_upvc		= +y * cam_area/cam_dist;
		#local cam_tran = transform
		{
			rotate		+x * 30
			rotate		+y * 60
			translate	cam_move
			scale		cam_scale
		}
		Set_Camera_Orthographic(false)
		Set_Camera_Transform(cam_tran)
		Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)
	#break
	// orthographic top
	#case (1)
		#local cam_aspc		= image_width/image_height;		// obsolete. render square images only!
		#local cam_dist		= 8;
		#local cam_move		= -y * 1/3;
		#local cam_scale	= 48;
		#local cam_area		= 2*1;
		#local cam_loca		= -z * cam_dist;
		#local cam_dirc		= +z;
		#local cam_rgvc		= +x * cam_area/cam_dist;
		#local cam_upvc		= +y * cam_area/cam_dist;
		#local cam_tran = transform
		{
			rotate		+x * 90
			translate	cam_move
			scale		cam_scale
		}
		Set_Camera_Orthographic(true)
		Set_Camera_Transform(cam_tran)
		Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)
	#break
	// orthographic front
	#case (2)
		#local cam_aspc		= image_width/image_height;		// obsolete. render square images only!
		#local cam_dist		= 8;
		#local cam_move		= 0;
		#local cam_scale	= 48;
		#local cam_area		= 2*1;
		#local cam_loca		= -z * cam_dist;
		#local cam_dirc		= +z;
		#local cam_rgvc		= +x * cam_area/cam_dist * cam_aspc;
		#local cam_upvc		= +y * cam_area/cam_dist;
		#local cam_tran = transform
		{
//			rotate		+x * 90
			translate	cam_move
			scale		cam_scale
		}
		Set_Camera_Orthographic(true)
		Set_Camera_Transform(cam_tran)
		Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)
	#break
#end


//------------------------------------------------------------------------------CSG objects

#switch (proj_type)
	// multiview
	#case (0)
		#local cube_tran = transform
		{
			scale cube_scale
			translate +z * trans_zamt
		}
		#local pane_tran = transform
		{
			scale 1
			translate -z * trans_zamt
		}
		#local base_tran = transform
		{
			translate -y * floor_drop
		}
		#local cube_cent = vtransform(<0,0,0>, cube_tran);
		#local pane_cent = vtransform(<0,0,0>, pane_tran);
		#local proj_vect = pane_cent - cube_cent;
		#local atan_angl = atan2d(proj_vect.z, proj_vect.x);
	#break
	// isometric
	#case (1)
		#local cube_tran = transform
		{
			scale cube_scale
			rotate +y * 45
			rotate -x * atand(sind(45))
			translate +z * trans_zamt
		}
		#local pane_tran = transform
		{
			scale 1
			translate -z * trans_zamt
		}
		#local base_tran = transform
		{
			translate -y * floor_drop
		}
		#local cube_cent = vtransform(<0,0,0>, cube_tran);
		#local pane_cent = vtransform(<0,0,0>, pane_tran);
		#local proj_vect = pane_cent - cube_cent;
		#local atan_angl = atan2d(proj_vect.z, proj_vect.x);
	#break
	// oblique
	#case (2)
		#local cube_tran = transform
		{
			scale cube_scale
			translate -x * sqrt(2)
			translate -y * sqrt(2)
			translate +z * trans_zamt
		}
		#local pane_tran = transform
		{
			scale 1
			translate -z * trans_zamt
		}
		#local base_tran = transform
		{
			translate -y * floor_drop
		}
		#local cube_cent = vtransform(<0,0,0>, cube_tran);
		#local pane_cent = vtransform(<0,0,0>, pane_tran);
		#local proj_vect = pane_cent - cube_cent;
		#local atan_angl = atan2d(proj_vect.z, proj_vect.x);
	#break
	// perspective
	#case (3)
		#local cube_tran = transform
		{
			scale cube_scale
			translate -x * sqrt(2)
			translate -y * sqrt(2)
			translate +z * trans_zamt
		}
		#local pane_tran = transform
		{
			scale 1
			translate -z * trans_zamt
		}
		#local base_tran = transform
		{
			translate -y * floor_drop
		}
		#local cube_cent = vtransform(<0,0,0>, cube_tran);
		#local pane_cent = vtransform(<0,0,0>, pane_tran);
		#local proj_vect = pane_cent - cube_cent;
		#local atan_angl = atan2d(proj_vect.z, proj_vect.x);
	#break
#end

box
{
	-1,+1
	transform {cube_tran}
	pigment {color srgbt <1/1,1/1,1/1,1/2,>}
}

// projection plane object
polygon
{
	4, <-1,-1,0>, <-1,+1,0>, <+1,+1,0>, <+1,-1,0>
	scale pane_size
	transform {pane_tran}
	pigment {color srgbt <1/1,1/1,1/1,1/2,>}
}
// floor plane object
polygon
{
	4, <-1,0,-1>, <-1,0,+1>, <+1,0,+1>, <+1,0,-1>
	scale base_size
	transform {base_tran}
	pigment {color srgb 1/2}
}
// projection plane
#local proj_plane = plane
{
	-z, 0
	transform {pane_tran}
}
// floor plane
#local floor_plane = plane
{
	+y, 0
	transform {base_tran}
}


#local sphere_radius = 1/16;
#local screen_scale = <image_width,image_height>;
#macro write_points_a(in_coo, in_txt, in_suffx, in_color)
//	#debug concat(in_txt, in_suffx, "\t", vstr(2, Get_Screen_XY(in_coo)/screen_scale, "\t", 0, -1), "\n")
//	#debug concat(in_txt, in_suffx, " = (", vstr(2, Get_Screen_XY(in_coo)/screen_scale, ",", 0, -1), ")\n")
	#local screen_coo = Get_Screen_XY(in_coo)/screen_scale;
	#local screen_coo = <screen_coo.x,1-screen_coo.y>;
	#debug concat("[\"", in_txt, in_suffx, "\", [", vstr(2, screen_coo, ",", 0, -1), "], [", vstr(3, in_color, ",", 0, -1), "]],\n")
#end
#macro place_cube_point(in_coo, in_txt)
	#if (proj_type = 3)
		#local view_cent = cube_cent + proj_vect * 2;
		#local cube_real = vtransform(in_coo, cube_tran);
		#local proj_vect = view_cent - cube_real;
		sphere {cube_real, sphere_radius pigment {color rgb x}}
		#local cube_proj = trace(proj_plane, cube_real, proj_vect);
		sphere {cube_proj, sphere_radius pigment {color rgb y}}
		cylinder {cube_real, view_cent, sphere_radius/4 pigment {color rgb x+y}}
		#local cube_shad = trace(floor_plane, cube_real, -y);
		sphere {cube_shad sphere_radius pigment {color rgb z}}
		write_points_a(cube_real, "cube_", in_txt, x)
		write_points_a(cube_proj, "proj_", in_txt, y)
		write_points_a(cube_shad, "shad_", in_txt, z)
	#else
		#local cube_real = vtransform(in_coo, cube_tran);
		sphere {cube_real, sphere_radius pigment {color rgb x}}
		#local cube_proj = trace(proj_plane, cube_real, proj_vect);
		sphere {cube_proj, sphere_radius pigment {color rgb y}}
		cylinder {cube_real, cube_proj, sphere_radius/4 pigment {color rgb x+y}}
		#local cube_shad = trace(floor_plane, cube_real, -y);
		sphere {cube_shad sphere_radius pigment {color rgb z}}
		write_points_a(cube_real, "cube_", in_txt, x)
		write_points_a(cube_proj, "proj_", in_txt, y)
		write_points_a(cube_shad, "shad_", in_txt, z)
	#end
#end
#macro place_pane_point(in_coo, in_txt)
	#local pane_real = vtransform(in_coo, pane_tran);
	sphere {pane_real, sphere_radius}
	write_points_a(pane_real, "pane_", in_txt, <0,0,0>)
#end
#macro place_base_point(in_coo, in_txt)
	#local base_real = vtransform(in_coo, base_tran);
	sphere {base_real, sphere_radius}
	write_points_a(base_real, "base_", in_txt, <0,0,0>)
#end
#macro place_cent_point()
	#local view_cent = cube_cent + proj_vect * 2;
	write_points_a(view_cent, "cent_", "X", <0,0,0>)	// this should be the same for every point
#end

place_cube_point(<-1,-1,-1>, "A")
place_cube_point(<+1,-1,-1>, "B")
place_cube_point(<+1,+1,-1>, "C")
place_cube_point(<-1,+1,-1>, "D")
place_cube_point(<-1,-1,+1>, "E")
place_cube_point(<+1,-1,+1>, "F")
place_cube_point(<+1,+1,+1>, "G")
place_cube_point(<-1,+1,+1>, "H")

place_pane_point(<-1,-1,+0> * pane_size, "A")
place_pane_point(<+1,-1,+0> * pane_size, "B")
place_pane_point(<+1,+1,+0> * pane_size, "C")
place_pane_point(<-1,+1,+0> * pane_size, "D")

place_base_point(<-1,+0,-1> * base_size, "A")
place_base_point(<+1,+0,-1> * base_size, "B")
place_base_point(<+1,+0,+1> * base_size, "C")
place_base_point(<-1,+0,+1> * base_size, "D")

place_cent_point()

// the coordinate grid and axes
Axes_Macro
(
	50,		// Axes_axesSize,	The distance from the origin to one of the grid's edges.		(float)
	1,		// Axes_majUnit,	The size of each large-unit square.					(float)
	8,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0001,		// Axes_thickRatio,	The thickness of the grid lines, as a factor of axesSize.		(float)
	on,	// Axes_aBool,		Turns the axes on/off. 							(boolian)
	on,		// Axes_mBool,		Turns the minor units on/off. 						(boolian)
	off,		// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.			(boolian)
	on,		// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.			(boolian)
	off		// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.			(boolian)
)

object
{
	Axes_Object
	scale 4
	translate -y * 0.0001
	transform {base_tran}
}

#debug concat("atan2d = ", str(atan_angl, 0, -1), "\n")
