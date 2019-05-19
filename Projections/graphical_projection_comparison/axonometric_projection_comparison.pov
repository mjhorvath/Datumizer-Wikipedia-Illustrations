// Title: Graphical projection comparison
// Author: Michael Horvath, http://isometricland.net
// Created: 2009-11-13
// Updated: 2019-05-19
// This file is licensed under the terms of the CC-LGPL.
// +kfi0 +kff15
// -uv

#version 3.7
#include "Axes_macro.inc"	// available from the POV-Ray Object Collection
#include "functions.inc"
#include "math.inc"
#include "screen.inc"		// requires the updated version available here: http://news.povray.org/povray.text.scene-files/thread/%3C581be4f1%241%40news.povray.org%3E/

#declare show_spheres = false;		// spheres used for alignment, also some text output

//------------------------------------------------------------------------------Scenery

global_settings
{
	assumed_gamma	1.0
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	0
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
}

background {color srgb <096,144,255,>/255}

light_source
{
	<-32,+32,-32,>
	color rgb	1
	rotate		y * 330
	parallel
	shadowless
}

light_source
{
	<-32,+32,-32,>
	color rgb	1
	rotate		y * 090
	parallel
//	shadowless
}


//#local cam_view =	frame_number;
#local cam_view =	16;
#local cam_aspc =	image_width/image_height;		// obsolete. render square images only!
#local cam_dist =	8;
#local cam_move =	1/2;
#local cam_oblique_scale = 4/4;						// this is necessary because military projection uses more space typically

#switch (cam_view)
	#case (0)	// three-point perspective - angles
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area/cam_dist * cam_aspc;
		#local cam_upvc =	+y * cam_area/cam_dist;
		#local cam_tran = transform
		{
			rotate		+x * asind(tand(30))
			rotate		+y * 045
			translate	+y * cam_move
		}
	#break
	#case (1)	// elevation (orthographic)
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			translate	+y * cam_move
		}
	#break
	#case (2)	// plan (orthographic)
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			rotate		+x * 090
			translate	+y * cam_move
		}
	#break
	#case (3)	// isometric (axonometric)
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area * cam_aspc;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			rotate		+x * asind(tand(030))
			rotate		+y * 045
			translate	+y * cam_move
		}
	#break
	#case (4)	// dimetric (axonometric)
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			rotate		+x * asind(tand(15))
			rotate		+y * 045
			translate	+y * cam_move
		}
	#break
	#case (5)	// trimetric (axonometric)
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			rotate		+x * asind(tand(30))
			rotate		+y * 015
			translate	+y * cam_move
		}
	#break
	#case (6)	// military (oblique)
		#local cam_area =	2 * cam_oblique_scale;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area * sind(045);
		#local cam_tran = transform
		{
			rotate		+x * 045
			rotate		+y * 045
			#if (cam_oblique_scale = 1)
				translate	+y * cam_move/2
			#else
				translate	+y * cam_move
			#end
		}
	#break
	#case (7)	// cavalier (oblique)
		#local cam_area =	2 * cam_oblique_scale;
		#local cam_loca =	vnormalize(-z/sind(045)+y-x) * cam_dist;
		#local cam_dirc =	vnormalize(+z/sind(045)-y+x);
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			translate	+y * cam_move
		}
	#break
	#case (8)	// 8-bit video game style (oblique)
		#local cam_area =	2 * cam_oblique_scale;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area * sind(045);
		#local cam_tran = transform
		{
			rotate		+x * 045
			translate	+y * cam_move
		}
	#break
	#case (9)	// cabinet (oblique)
		#local cam_fudge =	2;
		#local cam_area =	2 * cam_oblique_scale;
		#local cam_loca =	vnormalize(-z/sind(045)*cam_fudge+y-x) * cam_dist;
		#local cam_dirc =	vnormalize(+z/sind(045)*cam_fudge-y+x);
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			translate	+y * cam_move
		}
	#break
	#case (10)	// two-point perspective - vanishing points
		#local cam_fudge =	4;
		#local cam_dist =	cam_dist/cam_fudge;
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area/cam_dist * cam_aspc;
		#local cam_upvc =	+y * cam_area/cam_dist;
		#local cam_tran = transform
		{
			rotate		+y * 025
			translate	+y * cam_move
		}
	#break
	#case (11)	// one-point perspective - vanishing points
		#local cam_fudge =	4;
		#local cam_dist =	cam_dist/cam_fudge;
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area/cam_dist * cam_aspc;
		#local cam_upvc =	+y * cam_area/cam_dist;
		#local cam_tran = transform
		{
//			rotate x * 90		// test
			translate	+y * cam_move
		}
	#break
	#case (12)	// dimetric (axonometric) - typical video games
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			rotate		+x * 030
			rotate		+y * 045
			translate	+y * cam_move
		}
	#break
	#case (13)	// trimetric (axonometric) - fallout 1 & 2
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			rotate		+x * 025.6589063
			rotate		+y * 030
			translate	+y * cam_move
		}
	#break
	#case (14)	// cavalier (oblique) - right
		#local cam_area =	2 * cam_oblique_scale;
		#local cam_loca =	vnormalize(-z/sind(045)+y+x) * cam_dist;
		#local cam_dirc =	vnormalize(+z/sind(045)-y-x);
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			translate	+y * cam_move
		}
	#break
	#case (15)	// 8-bit video game style (oblique) - short
		#local cam_fudge =	2;
		#local cam_area =	2 * cam_oblique_scale;
		#local cam_loca =	vnormalize(-z*cam_fudge+y) * cam_dist;
		#local cam_dirc =	vnormalize(+z*cam_fudge-y);
		#local cam_rgvc =	+x * cam_area;
		#local cam_upvc =	+y * cam_area;
		#local cam_tran = transform
		{
			translate	+y * cam_move
		}
	#break
	#case (16)	// three-point perspective - vanishing points
		#local cam_area =	2;
		#local cam_loca =	-z * cam_dist;
		#local cam_dirc =	+z;
		#local cam_rgvc =	+x * cam_area/cam_dist * cam_aspc;
		#local cam_upvc =	+y * cam_area/cam_dist;
		#local cam_tran = transform
		{
			rotate		+x * 045
			rotate		+y * 045
			translate	+y * cam_move
		}
	#break
#end


#switch (cam_view)
	#case (0)
	#case (10)
	#case (11)
	#case (16)
		Set_Camera_Orthographic(false)
		Set_Camera_Transform(cam_tran)
		Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)
	#break
	#else
		Set_Camera_Orthographic(true)
		Set_Camera_Transform(cam_tran)
		Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)
	#break
#end


//------------------------------------------------------------------------------CSG objects

merge
{
	intersection
	{
		plane {+x + y,0 translate +y * 3/4}
		plane {-x + y,0 translate +y * 3/4}
		box {-1,+1}
		translate	+y
		scale		1/2
	}
	box {<0,0,0,>,<+1/8,+1/1,+1/8,>}
	clipped_by
	{
		union
		{
			box {<-1/8,+0/1,-1,>,<+1/8,+1/4,+1/1,> inverse}
			plane {+y,0}
		}
	}
	hollow
	pigment {color srgbt <1/1,1/1,1/1,1/2,>}
}

// the coordinate grid and axes
Axes_Macro
(
	50,				// Axes_axesSize,	The distance from the origin to one of the grid's edges.			(float)
	1/8,			// Axes_majUnit,	The size of each large-unit square.									(float)
	10,				// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0001,			// Axes_thickRatio,	The thickness of the grid lines, as a factor of axesSize.			(float)
	show_spheres,	// Axes_aBool,		Turns the axes on/off. 												(boolian)
	off,			// Axes_mBool,		Turns the minor units on/off. 										(boolian)
	off,			// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.					(boolian)
	on,				// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.					(boolian)
	off,			// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.					(boolian)
	3/4				// Axes_color,		The color of the grid. Traditionally <3/4,3/4,3/4>.					(vector)
)

object
{
	Axes_Object
//	translate -0.000001
	// orthographic elevation needs to show the grid too
	#if (cam_view = 1)
		rotate		+x * 90
		translate	+z * 1
	#end
}

#if (show_spheres = on)
	#switch (cam_view)
		#case (0)
			#local sphere_dist = 4/8;
			#local sphere_size = 1/16;
		
			#local sphere_loc_2 = <-sphere_dist*1,+sphere_dist*0,+sphere_dist*0,>;
			sphere {sphere_loc_2, sphere_size}
			#local sphere_loc_2 = Get_Screen_XY(sphere_loc_2);
			#debug concat("\ncen_f = (", vstr(2, sphere_loc_2, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_4 = <-sphere_dist*2,+sphere_dist*0,+sphere_dist*0,>;
			sphere {sphere_loc_4, sphere_size}
			#local sphere_loc_4 = Get_Screen_XY(sphere_loc_4);
			#debug concat("\nlft_f = (", vstr(2, sphere_loc_4, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_1 = <-sphere_dist*1,+sphere_dist*0,-sphere_dist*1,>;
			sphere {sphere_loc_1, sphere_size}
			#local sphere_loc_1 = Get_Screen_XY(sphere_loc_1);
			#debug concat("\nrgt_f = (", vstr(2, sphere_loc_1, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_3 = <-sphere_dist*1,+sphere_dist*1,+sphere_dist*0,>;
			sphere {sphere_loc_3, sphere_size}
			#local sphere_loc_3 = Get_Screen_XY(sphere_loc_3);
			#debug concat("\ntop_f = (", vstr(2, sphere_loc_3, ",", 0, -1), ")\n\n")
		
		
			
			#local sphere_loc_2 = <+sphere_dist*3,+sphere_dist*0,+sphere_dist*1,>;
			sphere {sphere_loc_2, sphere_size}
			#local sphere_loc_2 = Get_Screen_XY(sphere_loc_2);
			#debug concat("\ncen_b = (", vstr(2, sphere_loc_2, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_4 = <+sphere_dist*2,+sphere_dist*0,+sphere_dist*1,>;
			sphere {sphere_loc_4, sphere_size}
			#local sphere_loc_4 = Get_Screen_XY(sphere_loc_4);
			#debug concat("\nlft_b = (", vstr(2, sphere_loc_4, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_1 = <+sphere_dist*3,+sphere_dist*0,+sphere_dist*0,>;
			sphere {sphere_loc_1, sphere_size}
			#local sphere_loc_1 = Get_Screen_XY(sphere_loc_1);
			#debug concat("\nrgt_b = (", vstr(2, sphere_loc_1, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_3 = <+sphere_dist*3,+sphere_dist*1,+sphere_dist*1,>;
			sphere {sphere_loc_3, sphere_size}
			#local sphere_loc_3 = Get_Screen_XY(sphere_loc_3);
			#debug concat("\ntop_b = (", vstr(2, sphere_loc_3, ",", 0, -1), ")\n\n")
		
		
		
			#local sphere_loc_2 = <+sphere_dist*2,+sphere_dist*0,+sphere_dist*4,>;
			sphere {sphere_loc_2, sphere_size}
			#local sphere_loc_2 = Get_Screen_XY(sphere_loc_2);
			#debug concat("\ncen_l = (", vstr(2, sphere_loc_2, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_4 = <+sphere_dist*1,+sphere_dist*0,+sphere_dist*4,>;
			sphere {sphere_loc_4, sphere_size}
			#local sphere_loc_4 = Get_Screen_XY(sphere_loc_4);
			#debug concat("\nlft_l = (", vstr(2, sphere_loc_4, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_1 = <+sphere_dist*2,+sphere_dist*0,+sphere_dist*3,>;
			sphere {sphere_loc_1, sphere_size}
			#local sphere_loc_1 = Get_Screen_XY(sphere_loc_1);
			#debug concat("\nrgt_l = (", vstr(2, sphere_loc_1, ",", 0, -1), ")\n\n")
		
			#local sphere_loc_3 = <+sphere_dist*2,+sphere_dist*1,+sphere_dist*4,>;
			sphere {sphere_loc_3, sphere_size}
			#local sphere_loc_3 = Get_Screen_XY(sphere_loc_3);
			#debug concat("\ntop_l = (", vstr(2, sphere_loc_3, ",", 0, -1), ")\n\n")
		#break
		#case (10)
		#case (11)
		#case (16)
			#local sphere_dist = 4/8;
			#local sphere_size = 1/32;
		
			#local sphere_loc_1_a = <-sphere_dist,+sphere_dist*0/4,-sphere_dist,>;
			sphere {sphere_loc_1_a, sphere_size}
			#local sphere_loc_1_a = Get_Screen_XY(sphere_loc_1_a);
			#debug concat("\n1_a = (", vstr(2, sphere_loc_1_a, ",", 0, -1), ")\n\n")

			#local sphere_loc_1_b = <-sphere_dist,+sphere_dist*3/4,-sphere_dist,>;
			sphere {sphere_loc_1_b, sphere_size}
			#local sphere_loc_1_b = Get_Screen_XY(sphere_loc_1_b);
			#debug concat("\n1_b = (", vstr(2, sphere_loc_1_b, ",", 0, -1), ")\n\n")

			#local sphere_loc_2_a = <-sphere_dist,+sphere_dist*0/4,+sphere_dist,>;
			sphere {sphere_loc_2_a, sphere_size}
			#local sphere_loc_2_a = Get_Screen_XY(sphere_loc_2_a);
			#debug concat("\n2_a = (", vstr(2, sphere_loc_2_a, ",", 0, -1), ")\n\n")

			#local sphere_loc_2_b = <-sphere_dist,+sphere_dist*3/4,+sphere_dist,>;
			sphere {sphere_loc_2_b, sphere_size}
			#local sphere_loc_2_b = Get_Screen_XY(sphere_loc_2_b);
			#debug concat("\n2_b = (", vstr(2, sphere_loc_2_b, ",", 0, -1), ")\n\n")

			#local sphere_loc_3_a = <+sphere_dist,+sphere_dist*0/4,+sphere_dist,>;
			sphere {sphere_loc_3_a, sphere_size}
			#local sphere_loc_3_a = Get_Screen_XY(sphere_loc_3_a);
			#debug concat("\n3_a = (", vstr(2, sphere_loc_3_a, ",", 0, -1), ")\n\n")

			#local sphere_loc_3_b = <+sphere_dist,+sphere_dist*3/4,+sphere_dist,>;
			sphere {sphere_loc_3_b, sphere_size}
			#local sphere_loc_3_b = Get_Screen_XY(sphere_loc_3_b);
			#debug concat("\n3_b = (", vstr(2, sphere_loc_3_b, ",", 0, -1), ")\n\n")

			#local sphere_loc_4_a = <+sphere_dist,+sphere_dist*0/4,-sphere_dist,>;
			sphere {sphere_loc_4_a, sphere_size}
			#local sphere_loc_4_a = Get_Screen_XY(sphere_loc_4_a);
			#debug concat("\n4_a = (", vstr(2, sphere_loc_4_a, ",", 0, -1), ")\n\n")

			#local sphere_loc_4_b = <+sphere_dist,+sphere_dist*3/4,-sphere_dist,>;
			sphere {sphere_loc_4_b, sphere_size}
			#local sphere_loc_4_b = Get_Screen_XY(sphere_loc_4_b);
			#debug concat("\n4_b = (", vstr(2, sphere_loc_4_b, ",", 0, -1), ")\n\n")
		#break
		#else
			#local sphere_dist = 4/8;
			#local sphere_size = 1/16;

			// black
			#local sphere_loc_1 = <+sphere_dist*1,+sphere_dist*0,+sphere_dist*1,>;
			sphere {sphere_loc_1, sphere_size pigment {color srgb 0}}
			#local sphere_loc_1 = Get_Screen_XY(sphere_loc_1);
			#debug concat("\ncen = (", vstr(2, sphere_loc_1, ",", 0, -1), ")\n\n")

			// blue
			#local sphere_loc_2 = <-sphere_dist*1,+sphere_dist*0,+sphere_dist*1,>;
			sphere {sphere_loc_2, sphere_size pigment {color srgb z}}
			#local sphere_loc_2 = Get_Screen_XY(sphere_loc_2);
			#debug concat("\nlft = (", vstr(2, sphere_loc_2, ",", 0, -1), ")\n\n")

			// red
			#local sphere_loc_3 = <+sphere_dist*1,+sphere_dist*0,-sphere_dist*1,>;
			sphere {sphere_loc_3, sphere_size pigment {color srgb x}}
			#local sphere_loc_3 = Get_Screen_XY(sphere_loc_3);
			#debug concat("\nrgt = (", vstr(2, sphere_loc_3, ",", 0, -1), ")\n\n")

			// green
			#local sphere_loc_4 = <+sphere_dist*1,+sphere_dist*2,+sphere_dist*1,>;
			sphere {sphere_loc_4, sphere_size pigment {color srgb y}}
			#local sphere_loc_4 = Get_Screen_XY(sphere_loc_4);
			#debug concat("\ntop = (", vstr(2, sphere_loc_4, ",", 0, -1), ")\n\n")
		#break
	#end
#end
