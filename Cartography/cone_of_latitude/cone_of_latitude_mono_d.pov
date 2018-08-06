// The Earth texture is scaled vertically from perfectly spherical. The graticule uses ellipsoidal coordinates, and the shapes produced by latitude are hyperboloids.

#version 3.7

#include "functions.inc"
#include "math.inc"
#include "screen.inc"			// http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/
#include "ShapeGrid_macro.inc"	// http://lib.povray.org/searchcollection/index2.php?objectName=ShapeGrid&version=1.16&contributorTag=SharkD
#include "shapes3.inc"

#declare map_show_mode = 0;
#declare sphere_scale = sind(45);
#declare ring_latitude = 60;

//------------------------------------------------------------------------------Scenery

global_settings
{
	assumed_gamma	1.0
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
/*
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
*/
	ambient_light	2
}

background {color srgb 3/4}

light_source
{
	<-30,+30,-30,>
	color rgb	2
	rotate		x * 330
	parallel
//	shadowless
}

light_source
{
	<-30,+30,-30,>
	color rgb	2
	rotate		y * 090
	parallel
//	shadowless
}

#local cam_aspc =	image_width/image_height;		// obsolete. render square images only!
#local cam_dist =	5/2;
#local cam_area =	1;
#local cam_loca =	-z * cam_dist;
#local cam_dirc =	+z;
#local cam_rgvc =	+x * cam_area;
#local cam_upvc =	+y * cam_area;
#local cam_tran = transform
{
	rotate		+x * atand(sind(45))
//	rotate		+x * 45
	rotate		-y * 150
//	rotate		-y * 90
}

Set_Camera_Orthographic(false)
Set_Camera_Transform(cam_tran)
Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)


#macro get_time(tim_beg, tim_end)
	#local time_adj = -1;
	#switch (clock)
		#range (0, tim_beg)
			#local time_adj = 0;
		#break
		#range (tim_beg, tim_end)
			#local t1 = clock - tim_beg;
			#local t2 = tim_end - tim_beg;
			#local time_adj = t1/t2;
		#break
		#range (tim_end, 1)
			#local time_adj = 1;
		#break
		#else
			// Do nothing
		#break
	#end
	time_adj
#end

//------------------------------------------------------------------------------CSG objects

#declare earthpigment = pigment
{
	image_map
	{
		// https://commons.wikimedia.org/wiki/File:World_location_map_mono.svg
		png "World_location_map_mono.png" map_type 1 interpolate 4
	}
}

#declare gridpigment = pigment
{
	object
	{
		SGrid_Sphere_Macro(3,24,12,1,0,0.01,off,off,)
		color srgbt <0,0,0,4/4>
		color srgbt <0,0,0,3/4>
	}
}

#declare earth_surface = sphere
{
	0, 1
	#if ((map_show_mode = 0) | (map_show_mode = 1))
		texture
		{
			pigment {earthpigment}
		}
	#end
	#if ((map_show_mode = 0) | (map_show_mode = 2))
		texture
		{
			pigment {gridpigment}
		}
	#end
	scale y * sphere_scale
}

#declare plane_cut = plane
{
	+x, 0
	pigment {color rgbt 1}
}

#declare	focal_distance = cosd(asind(sphere_scale));
#declare	H = 1e-4;
#declare	horz = cosd(ring_latitude) * focal_distance;
#declare	a_sq = pow(horz,2);
#declare	c_sq = pow(focal_distance,2);
#undef		func_hyperboloid
#declare	func_hyperboloid = function(x,y,z) {pow(x,2)/a_sq-pow(y,2)/(c_sq-a_sq)+pow(z,2)/a_sq-1}
#undef		func_gradient_magnitude
#declare	func_gradient_magnitude = MakeGradientMagnitudeFunction_3b(func_hyperboloid, H)
#undef		func_normalized
#declare	func_normalized = function(x,y,z) {func_hyperboloid(x,y,z)/func_gradient_magnitude(x,y,z)}

#local hyperbola_iso = isosurface
{
	function {func_normalized(x,y,z)}
	accuracy		0.001
	max_gradient	4
	all_intersections
	//evaluate P0, P1, min (P2, 1)
	contained_by {sphere {0, 1}}
}

#local shape_of_intersection = intersection
{
	object {hyperbola_iso}
	plane {-y, 0}
}

//#declare shape_of_intersection = box {-1, +1}

#declare earth_plug = intersection
{
	object {earth_surface}
	object {shape_of_intersection}
	pigment {color srgb 3/4}
}

#declare earth_socket = difference
{
	object {earth_surface}
	object {shape_of_intersection}
	pigment {color srgb 1/4}
}

#declare spheredrop_time = get_time(1/2, 1);
object {earth_plug		translate +y * spheredrop_time * 1/4}
object {earth_socket	translate -y * spheredrop_time * 3/4}
//object {shape_of_intersection}
//object {earth_surface}

/*
intersection
{
	object {earth_surface}
	object {plane_cut}
}
*/

//--------------------------------------Torus

#declare latitude_torus = torus
{
	cosd(ring_latitude),0.005
	translate y * sind(ring_latitude) * sphere_scale
	pigment {color srgb <1,2/4,0>}
}

#declare circlearc_time = get_time(0, 1/2);
#declare plane_wedge = object
{
	Segment_of_CylinderRing
	(
		1, // major radius
		0, // minor radius  
		2, // height H
		360 * circlearc_time  // angle (in degrees)
	)
	translate -y
	pigment {color srgb <1,2/4,0>}
}

#if (circlearc_time > 0)
	intersection
	{
		object {plane_wedge}
		object {latitude_torus}
		translate +y * spheredrop_time * 1/4
	}
#end
