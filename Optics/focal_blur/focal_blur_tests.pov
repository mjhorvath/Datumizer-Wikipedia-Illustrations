// Title: Camera focal blur example - part one
// Author: Michael Horvath, http://isometricland.net
// Created: 2016-11-10
// Updated: 2016-11-11
// This file is licensed under the terms of the GFDL.
// +kfi0 +kff18 +a0.0
// +kfi0 +kff32 for logmode
// +kfi0 +kff30 for tanmode
// +K0.5

#version 3.7

#include "functions.inc"
#include "math.inc"
#include "rad_def.inc"
#declare LogMode = false;		// log mode or tan mode
#declare ObjTrans = 6;
#declare tempclock = 0.5;

global_settings
{
	assumed_gamma	1.0
//	ambient_light	0.0
//	radiosity
//	{
//		Rad_Settings(Radiosity_Normal,off,off)
//	}
}

light_source
{
	<-32,+32,-32,>
	color		rgb 1.1
	parallel
	point_at	0
}

light_source
{
	<-32,+32,-32,>
	color		rgb 1.1
	rotate		y * 090
	parallel
	point_at	0
}

/*
#local CameraScale			= 1;
#local CameraTranslate		= <5,5,5>;
#local CameraDistance		= 16;
#local CameraWidth		= 16;
#local CameraAspectRatio	= image_width/image_height;
#local CameraAperture		= tand(tempclock * 90) * 8;		// not sure if 8 is best
#local CameraFStop			= CameraDistance/CameraAperture;
#local CameraLocation		= -z * CameraDistance/CameraScale;
#local CameraDirection		= +z * CameraDistance/CameraScale;
#local CameraRight			= +x * CameraWidth/CameraScale * CameraAspectRatio;
#local CameraUp				= +y * CameraWidth/CameraScale;
#local CameraFocalPoint		= -1 * CameraLocation * (CameraScale - 1);
#local CameraSamples		= 32;
#local CameraTransform = transform
{
	scale			CameraScale
	rotate			+x * asind(tand(30))
	rotate			-y * 030
	translate		CameraTranslate
}
*/

#local CameraScale			= 3;
#local CameraTranslate		= <0,1,0>;
#local CameraDistance		= 16;
#local CameraWidth			= 16;
#local CameraAspectRatio	= image_width/image_height;
#local CameraAperture		= tand(tempclock * 90) * 8 * CameraScale;		// not sure if 8 is best
#local CameraFStop			= CameraDistance/CameraAperture;
#local CameraLocation		= -z * CameraDistance;
#local CameraDirection		= +z * CameraDistance;
#local CameraLookAt			= CameraLocation + CameraDirection;
#local CameraRight			= +x * CameraWidth * CameraAspectRatio;
#local CameraUp				= +y * CameraWidth;
#local CameraFocalPoint		= CameraLookAt + CameraDirection * (CameraScale - 1) + CameraTranslate;
#local CameraSamples		= 32;
#local CameraTransform = transform
{
	scale			CameraScale
	rotate			+x * asind(tand(30))
//	rotate			+x * 90
	rotate			-y * 030
	translate		CameraTranslate
}



camera
{
	location		CameraLocation
	direction		CameraDirection
	right			CameraRight
	up				CameraUp

//	transform {CameraTransform}

	focal_point		CameraFocalPoint
	aperture		CameraAperture
	blur_samples	CameraSamples

	transform {CameraTransform}
}

#if (frame_number = 0)
	#if (LogMode = false)
		#debug concat("Frame\tClock\tDist\tApert\tFStop\n")
	#else
		#debug concat("Frame\tDist\tAV\tApert\tFStop\n")
	#end
#end

#if (LogMode = false)
	#debug concat(str(frame_number,0,0), "\t", str(clock,0,3), "\t", str(CameraDistance,0,3), "\t", str(CameraAperture,0,3), "\t", str(CameraFStop,0,3), "\n")
#else
	#debug concat(str(frame_number,0,0), "\t", str(CameraDistance,0,3), "\t", str(CameraApertureValue,0,1), "\t", str(CameraAperture,0,3), "\t", str(CameraFStop,0,3), "\n")
#end

sky_sphere
{
	pigment
	{
		gradient y
		color_map
		{
			[0 srgb 1]
			[1 srgb 3/4]
		}
	}
}


plane
{
	+y, 0
	pigment
	{
		checker
		color srgb 3/4, color srgb 1
		scale	1/4
	}
	translate	-y * 0.000001
}

isosurface
{
	function {abs(x)-1+y}
	contained_by {box {-2,+2}}
	max_gradient	2
	translate	+y*2
	scale		7/8
	scale		1/2
	translate	-z * ObjTrans
	pigment {color srgb x+y}
}

isosurface
{
	function {abs(x)+abs(y)+abs(z)-2}
	contained_by {box {-2,+2}}
	max_gradient	2
	translate	+y*2
	scale		1/2
	translate	+z * ObjTrans
	pigment {color srgb z}
}

sphere
{
	+y, 1
	pigment {color srgb x}
	translate	-x * ObjTrans
}

box
{
	-1, +1
	translate	+y
	scale		3/4
	pigment {color srgb y}
	translate	+x * ObjTrans
}

box
{
	-1, +1
	pigment
	{
		checker
		color srgb 0, color srgb 1
		scale	1
	}
	translate	+y
}
