#version 3.7

#include "axes_macro.inc"		// http://lib.povray.org/searchcollection/index2.php?objectName=AxesAndGridMacro&contributorTag=SharkD
#include "functions.inc"
#include "math.inc"
#include "screen.inc"			// requires the updated version available here: http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/

#declare sRadius = 1;
#declare sCenter = 0;
#declare MarkersScale = 6/5;
#declare OuterRadius = 3 * MarkersScale;
#declare InnerRadius = 0.02 * MarkersScale;
#declare ArrowRadius = 0.05 * MarkersScale;
#declare ArrowLength = 0.3 * MarkersScale;
#declare RotateVert = 45;
#declare RotateHorz = 30;

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
	<-30,+30,-30,>
	color srgb	1
	rotate		y * 330
	parallel
	shadowless
}

light_source
{
	<-30,+30,-30,>
	color srgb	1
	rotate		y * 090
	parallel
	shadowless
}

#local cam_aspc =	image_width/image_height;		// obsolete. render square images only!
#local cam_dist =	8;
#local cam_area =	10/8;							// was 3/2
#local cam_loca =	-z * cam_dist;
#local cam_dirc =	+z;
#local cam_rgvc =	+x * cam_area;
#local cam_upvc =	+y * cam_area;
#local cam_tran = transform
{
	rotate		+x * RotateHorz
	rotate		+y * (RotateVert+180)
	scale		sqrt(2)
}

Set_Camera_Orthographic(true)
Set_Camera_Transform(cam_tran)
Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)

/*
sky_sphere
{
	pigment
	{
		gradient y
		color_map {[0.0 srgb <0.6,0.7,1.0>][0.7 srgb <0.0,0.1,0.8>]}
	}
}
*/

//------------------------------------------------------------------------------CSG objects

box
{
	sCenter, sRadius
	pigment {color srgbt <1,1,1,1/2>}
//	hollow
//	no_shadow
}

// the coordinate grid and axes
Axes_Macro
(
	8,		// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
	0.125,	// Axes_majUnit,	The size of each large-unit square.	(float)
	8,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0005,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).	(float)
	on,		// Axes_aBool,		Turns the axes on/off. (boolian)
	off,	// Axes_mBool,		Turns the minor units on/off. (boolian)
	off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.	(boolian)
	on,		// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.	(boolian)
	off		// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.	(boolian)
)

object
{
	Axes_Object
	translate -0.0001
//	no_shadow
}
/*
cylinder
{
	+z * 3 * MarkersScale, 0, InnerRadius
	pigment {color srgbt <0,0,1,0>}
	rotate		-x * RotateHorz
	rotate		+y * RotateVert
}

sphere
{
	+z * 3 * MarkersScale, ArrowRadius
	pigment {color srgbt <0,0,1,0>}
	rotate		-x * RotateHorz
	rotate		+y * RotateVert
}

polygon
{
	4, <0,1>, <1,1>, <1,0>, <0,0>
	pigment
	{
		image_map {png "rotation_y_45_degrees_line_color.png"}
	}
	translate	<-1/2,-1/2,0>
	translate	-z * 0.0001
	scale		8 * MarkersScale
	rotate		x * 90
	rotate		y * 90
	no_shadow
}

polygon
{
	4, <0,1>, <1,1>, <1,0>, <0,0>
	pigment
	{
		image_map {png "rotation_x_30_degrees_line_color.png"}
	}
	translate	<-1/2,-1/2,0>
	translate	-z * 0.0001
	scale		8 * MarkersScale
	rotate		y * 135
	no_shadow
}
*/

/*
		#local sphere_siz = 1;
		#local sphere_sca = <image_width,image_height>;
		#local sphere_tra = <image_width,image_height> * -1/2;

		#local sphere_loc_real = <+sphere_siz*1,-sphere_siz*0,+sphere_siz*1,>;
		sphere {sphere_loc_real, 1/32 pigment {color srgb z}}
		#local sphere_loc_proj = Get_Screen_XY(sphere_loc_real) + sphere_tra;
		#debug concat("\n\nblu = (", vstr(2, sphere_loc_proj, ",", 0, 5), ")\n")
		
		#local sphere_loc_real = <+sphere_siz*1/2,+sphere_siz*0,+sphere_siz*3/2,>;
		sphere {sphere_loc_real, 1/32 pigment {color srgb x}}
		#local sphere_loc_proj = Get_Screen_XY(sphere_loc_real) + sphere_tra;
		#debug concat("\n\nred = (", vstr(2, sphere_loc_proj, ",", 0, 5), ")\n")
		
		#local sphere_loc_real = <+sphere_siz*0,+sphere_siz*0,+sphere_siz*1,>;
		sphere {sphere_loc_real, 1/32 pigment {color srgb y}}
		#local sphere_loc_proj = Get_Screen_XY(sphere_loc_real) + sphere_tra;
		#debug concat("\n\ngrn = (", vstr(2, sphere_loc_proj, ",", 0, 5), ")\n")

		#local sphere_loc_real = <+sphere_siz*1,+sphere_siz*1,+sphere_siz*1,>;
		sphere {sphere_loc_real, 1/32 pigment {color srgb x+z}}
		#local sphere_loc_proj = Get_Screen_XY(sphere_loc_real) + sphere_tra;
		#debug concat("\n\nmag = (", vstr(2, sphere_loc_proj, ",", 0, 5), ")\n")

		#local sphere_loc_real = <+sphere_siz*1/2,+sphere_siz*1,+sphere_siz*1,>;
		sphere {sphere_loc_real, 1/32 pigment {color srgb x+y}}
		#local sphere_loc_proj = Get_Screen_XY(sphere_loc_real) + sphere_tra;
		#debug concat("\n\nyel = (", vstr(2, sphere_loc_proj, ",", 0, 5), ")\n")

		#local sphere_loc_real = <+sphere_siz*1,+sphere_siz*1,+sphere_siz*1/2,>;
		sphere {sphere_loc_real, 1/32 pigment {color srgb y+z}}
		#local sphere_loc_proj = Get_Screen_XY(sphere_loc_real) + sphere_tra;
		#debug concat("\n\ncyn = (", vstr(2, sphere_loc_proj, ",", 0, 5), ")\n")
*/
