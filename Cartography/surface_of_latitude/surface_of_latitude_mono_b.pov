// The Earth is perfectly spherical. Plane cut.
// +wt11 +q11 +am2 +r4 -j
// +KFI0 +KFF48

#version 3.7

#include "functions.inc"
#include "math.inc"
#include "screen_mjh.inc"			// https://github.com/mjhorvath/POVRay-Updated-Screen-Inc
#include "ShapeGrid_macro.inc"		// https://github.com/mjhorvath/Mike-Wikipedia-Illustrations
#include "shapes3.inc"

#declare map_show_mode = 0;
#declare ring_latitude = 60;

#macro SetClock2(StartTime, EndTime)
    #local R = (clock - StartTime)/(EndTime - StartTime);
    #local S = min(max(0, R), 1);
    #local T = (1 - cos(S*pi))/2;
    T
#end

#macro GetClock(tim_beg, tim_end)
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

#declare Earth_time_spin	= SetClock2(0/3, 1/3);
#declare Earth_time_fall	= SetClock2(1/3, 2/3);
#declare Earth_time_rise	= SetClock2(2/3, 3/3);


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

background {color srgb 7/8}

light_source
{
	<-30,+30,-30,>
	color rgb	2
	rotate		x * 330
	parallel
	point_at	0
//	shadowless
}

light_source
{
	<-30,+30,-30,>
	color rgb	2
	rotate		y * 090
	parallel
	point_at	0
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


//------------------------------------------------------------------------------CSG objects


//--------------------------------------Earth

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
	0,1
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
}

#declare plane_cut = plane
{
	+x,0
	pigment {color rgbt 1}
}

#declare cone_of_intersection = plane
{
	-y,-sind(ring_latitude)
}

#declare earth_plug = intersection
{
	object {earth_surface}
	object {cone_of_intersection}
	pigment {color srgb 3/4}
}

#declare earth_socket = difference
{
	object {earth_surface}
	object {cone_of_intersection}
	pigment {color srgb 1/4}
}

object
{
	earth_socket
	translate -y/2 * Earth_time_fall
	translate +y/2 * Earth_time_rise
}
object
{
	earth_plug
	translate +y/2 * Earth_time_fall
	translate -y/2 * Earth_time_rise
}


//--------------------------------------Torus

#declare latitude_torus = torus
{
	cosd(ring_latitude),0.005
	translate y * sind(ring_latitude)
	pigment {color srgb <1,2/4,0>}
}

#declare plane_wedge = object
{
	Segment_of_CylinderRing
	(
		1, // major radius
		0, // minor radius  
		2, // height H
		360 * Earth_time_spin  // angle (in degrees)
	)
	translate -y
	pigment {color srgb <1,2/4,0>}
}

#if (Earth_time_spin > 0)
	intersection
	{
		object {plane_wedge}
		object {latitude_torus}
		translate -y/2 * Earth_time_fall
		translate +y/2 * Earth_time_rise
	}
	intersection
	{
		object {plane_wedge}
		object {latitude_torus}
		translate +y/2 * Earth_time_fall
		translate -y/2 * Earth_time_rise
	}
#end
