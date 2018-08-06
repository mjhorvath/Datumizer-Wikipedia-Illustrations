// Title: CIE Basic Scene Settings
// Authors: Michael Horvath, Christoph Lipka
// Website: http://isometricland.net
// Created: 2017-03-07
// Updated: 2017-03-27
// This file is licensed under the terms of the CC-GNU LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html
// Illuminant =  D65
// Observer   =  2° (1931)
// +kfi0 +kff191 +kc
// +k0.25

#version 3.7;
#include "math.inc"
//#include "cie.inc"			// http://www.ignorancia.org/en/index.php?page=Lightsys
//#include "lightsys.inc"			// http://www.ignorancia.org/en/index.php?page=Lightsys
//#include "lightsys_constants.inc"	// http://www.ignorancia.org/en/index.php?page=Lightsys

global_settings
{
	assumed_gamma	1.0
	adc_bailout	0.005
	max_trace_level	50
	ambient_light	1/3
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


camera
{
//	#declare cie_cam_distance	= 44;	// render at 8192x8192
//	#declare cie_cam_planesize	= 4.4;	// render at 8192x8192
//	#declare cie_cam_distance	= 22;	// render at 4096x4096
//	#declare cie_cam_planesize	= 2.2;	// render at 4096x4096
//	#declare cie_cam_distance	= 17;
//	#declare cie_cam_planesize	= 1.7;
//	orthographic
	location	-z * cie_cam_distance
	direction	+z * cie_cam_distance
	right		+x * cie_cam_planesize
	up		+y * cie_cam_planesize/cie_cam_aspectratio
	rotate		+x * asind(tand(30))
	scale		cie_ScaleAmount
}

#declare old_lights = union
{
	// 330 - 360 = -30
	// -30 * -1 = 30
	// 30 + 15 = 45
	// 45 + 30 = 75
	light_source
	{
		<-32,+32,-32,>
		color		rgb 1
		rotate		-y * (330-360)		// was 330
		parallel
		point_at	0
		shadowless
	}
	// 90 - 360 = -270
	// -270 * -1 = 270
	// 270 + 15 = 285
	// 285 + 30 = 315
	light_source
	{
		<-32,+32,-32,>
		color		rgb 1
		rotate		-y * (090-360)		// was 90
		parallel
		point_at	0
		shadowless	// was disabled originally
	}
/*
	light_source
	{
		<-32,+32,-32,>
		color		rgb 1
		rotate		+y * (180-360)		// was 150
		parallel
		point_at	0
		shadowless	// was disabled originally
	}
*/
	rotate	+y * 15
	rotate	+y * cie_RotateAmount
	scale	cie_ScaleAmount
}
/*
#declare new_lights = union
{
	#declare light_lumens		= 2;					// float
	#declare light_temp		= Daylight(6500);			// float
	#declare light_color		= Light_Color(light_temp,light_lumens);
	#declare light_distance		= 320;
	//#declare light_color		= 1;
	#declare light_location		= vrotate(<0,0,-light_distance>, <+60,+90,+00>);

	light_source
	{
		light_location
		color		rgb light_color
		parallel
		point_at	<0,0,0>
//		fade_distance	light_distance
//		fade_power	1
		shadowless
		scale		cie_ScaleAmount
	}

	light_source
	{
		light_location
		color		rgb light_color
		parallel
		point_at	<0,0,0>
	//	fade_distance	light_distance
	//	fade_power	1
	//	shadowless
		rotate		y * 90
		scale		cie_ScaleAmount
	}

}
*/
object {old_lights}

#declare cie_pigmentCyl = pigment
{
	cylindrical
	color_map
	{
		[ 0/20 color rgbt 10/10]
		[ 1/20 color rgbt 10/10]
		[ 1/20 color rgbt  9/10]
		[20/20 color rgbt  9/10]
	}
	frequency 5
	scale 1.0001
}
#declare cie_pigmentGradY = pigment
{
	gradient y
	pigment_map
	{
		[ 0/20 cie_pigmentCyl]
		[ 1/20 cie_pigmentCyl]
		[ 1/20 color rgbt  9/10]
		[20/20 color rgbt  9/10]
	}
	frequency 5
	scale 1.0001
}

#declare cie_boxShape = box
{
	0, 1
//	hollow
}

#declare cie_cylShape = cylinder
{
	0, y, 1/2
//	hollow
}

#declare cie_sphShape = sphere
{
	0, 1
//	hollow
}

#declare cie_axesShape = union
{
	cylinder
	{
		0, x, 0.005
		pigment {color srgb x}
	}
	cylinder
	{
		0, y, 0.005
		pigment {color srgb y}
	}
	cylinder
	{
		0, z, 0.005
		pigment {color srgb z}
	}
	sphere
	{
		0, 0.005
		pigment {color srgb 1/2}
	}
}

#declare cie_isoFinish = finish
{
	emission 0.3
	diffuse 1
}

#declare cie_boxFinish = finish
{
	// experiment by setting this to 1, default valure is 0.6
	diffuse 1
}
#default
{
	finish {diffuse 1}
}

background {srgb 1}
