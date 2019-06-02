// Title: Solar system orrery
// Version: 3.4
// Authors: Michael Horvath, http://isometricland.net
// Created: 2018/09/15
// Updated: 2019/06/02
// This file is licensed under the terms of the CC-LGPL.
// https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
// +kfi0 +kff99


#version 3.8


//------------------------------------------------------------------------------
// INCLUDES


#include "screen.inc"			// Requires the updated version available here: http://news.povray.org/povray.text.scene-files/thread/%3C581be4f1%241%40news.povray.org%3E/
#include "CIE.inc"				// http://www.ignorancia.org/en/index.php?page=Lightsys
#include "lightsys.inc"			// http://www.ignorancia.org/en/index.php?page=Lightsys
#include "math.inc"
#include "transforms.inc"
#include "rad_def.inc"


//------------------------------------------------------------------------------
// GLOBAL PARAMETERS

#declare Orrery_Scene				= 2;					// 0 = ignore this setting, 1 = inner anim, 2 = inner static, 3 = outer anim, 4 = outer static
#declare Orrery_PlanetsFocus		= 0;					// 1 to 8, or 0 to disable
#declare Orrery_PlanetsNumber		= 8;					// 8 currently
#declare Orrery_DecoMode			= 2;					// 1 = black; 2 = gray
#declare Orrery_InnerOuter			= 2;					// 1 = inner planets; 2 = outer planets
#declare Orrery_SunRadius			= 696000;				// km
#declare Orrery_AU					= 149597870.691;		// km
#declare Orrery_EccentricityMulti	= 1;					// not used currrently
#declare Orrery_InclinationMulti	= 1;					// not used currrently
#declare Orrery_Radiosity			= true;					// turn radiosity on/off
#declare Orrery_CameraMode			= 2;					// 1 = perspective; 2 = orthographic
#declare Orrery_BitmapTextures		= true;					// use bitmap textures or solid colors?
#declare Orrery_TextSize			= 0.04;					// size of on-screen text
#declare Orrery_TextFont			= "OpenSans-Regular.ttf";
#declare Orrery_Animation			= true;					// are you rendering an animation?
#declare Orrery_LightLumens			= 2;
#declare Orrery_LightTemp			= Daylight(5800);
#declare Orrery_LightColor			= Light_Color(Orrery_LightTemp,Orrery_LightLumens);
#declare Orrery_J2000_Obliquity		= 23.43928;				// deg, obliquity of Earth pole axis
#declare Orrery_J2000_Date			= 2451545.0;			// Julian days, January 1, 2000, at 12h TT
#declare Orrery_MarkerShow			= false;				// show/hide alignment markers

// inner anim
#if (Orrery_Scene = 1)
	#declare Orrery_InnerOuter			= 1;				// 1 = inner planets; 2 = outer planets
	#declare Orrery_Animation			= true;				// are you rendering an animation?
	#declare Orrery_DecoMode			= 2;				// 1 = black; 2 = gray
// inner static
#elseif (Orrery_Scene = 2)
	#declare Orrery_InnerOuter			= 1;				// 1 = inner planets; 2 = outer planets
	#declare Orrery_Animation			= false;			// are you rendering an animation?
	#declare Orrery_DecoMode			= 1;				// 1 = black; 2 = gray
// outer anim
#elseif (Orrery_Scene = 3)
	#declare Orrery_InnerOuter			= 2;				// 1 = inner planets; 2 = outer planets
	#declare Orrery_Animation			= true;				// are you rendering an animation?
	#declare Orrery_DecoMode			= 2;				// 1 = black; 2 = gray
// outer static
#elseif (Orrery_Scene = 4)
	#declare Orrery_InnerOuter			= 2;				// 1 = inner planets; 2 = outer planets
	#declare Orrery_Animation			= false;			// are you rendering an animation?
	#declare Orrery_DecoMode			= 1;				// 1 = black; 2 = gray
#end

#if (Orrery_InnerOuter = 1)
	#declare Orrery_SceneScale			= 3.5/2;															// multiplier
	#declare Orrery_RadiusMulti			= 1024;															// multiplier
	#declare Orrery_LineThickness		= 1/32;															// AU
//	#declare Orrery_LineThickness		= Orrery_SceneScale * 1/40;										// AU
//	#declare Orrery_StartDate			= 2458198.177083;												// a. Julian days, A.D. 2018 Mar 20, 16:14:60.0 UT1 (Earth vernal equinox)
//	#declare Orrery_StartDate			= 2458384.579167;												// b. Julian days, A.D. 2018 Sep 23, 01:54:00.0 UT1 (Earth autumnal equinox)
//	#declare Orrery_StartDate			= 2458290.921528;												// c. Julian days, A.D. 2018 Jun 21, 10:07:00.0 UT1 (Earth northern solstice)
	#declare Orrery_StartDate			= 2458306.199306;												// d. Julian days, A.D. 2018 Jul 06, 16:47:00.0 UT1 (Earth aphelion)
//	#declare Orrery_StopDate			= 2458384.579167;												// a. Julian days, A.D. 2018 Sep 23, 01:54:00.0 UT1 (Earth autumnal equinox, okay)
//	#declare Orrery_StopDate			= 2458563.415278;												// b. Julian days, A.D. 2019 Mar 20, 21:58:00.0 UT1 (Earth vernal equinox)
//	#declare Orrery_StopDate			= 2458474.432639;												// c. Julian days, A.D. 2018 Dec 21, 22:23:00.0 UT1 (Earth southern solstice)
	#declare Orrery_StopDate			= 2458486.722222;												// d. Julian days, A.D. 2019 Jan 03, 05:20:00.0 UT1 (Earth perihelion, very nice)
//	#declare Orrery_StopDate			= 2458383.500000;												// e. Julian days, A.D. 2018 Sep 22, 00:00:00.0 UT1 (random test day)
//	#declare Orrery_StopDate			= 2458384.579167;												// f. Julian days, A.D. 2018 Sep 23, 01:54:00.0 UT1 (Earth autumnal equinox)
//	#declare Orrery_StopDate			= 2451545.000000;												// g. Julian days, A.D. 2000 Jan 01, 12 hours TDB (J2000.0 epoch)
//	#declare Orrery_StopDate			= 2458669.424306;												// d2. Julian days, A.D. 2019 Jul 04, 22:11:00.0 UT1 (Earth aphelion)
	#declare Orrery_LightRadius			= Orrery_SunRadius/Orrery_AU * Orrery_SceneScale * 8;			// AU
	#declare Orrery_RingDistance		= 1/2;															// AU
	#declare Orrery_TrailRadius			= Orrery_SceneScale/256;										// AU
#elseif (Orrery_InnerOuter = 2)
	#declare Orrery_SceneScale			= 16 * 3/2;														// multiplier
	#declare Orrery_RadiusMulti			= 1024 * 2;														// multiplier
	#declare Orrery_LineThickness		= 1/32 * 8;														// AU
//	#declare Orrery_LineThickness		= Orrery_SceneScale * 1/40;										// AU
//	#declare Orrery_StartDate			= 2455638.782232;												// a. Julian days, A.D. 2011 Mar 18, 06:46:24.8 UT1 (Jupiter perihelion)
//	#declare Orrery_StartDate			= 2457801.804167;												// b. Julian days, A.D. 2017 Feb 17, 07:18:00.0 UT1 (Jupiter aphelion)
//	#declare Orrery_StartDate			= 2459965.987500;												// c. Julian days, A.D. 2023 Jan 21, 11:42:00.0 UT1 (Jupiter perihelion)
//	#declare Orrery_StartDate			= 2452847.187500;												// d. Julian days, A.D. 2003 Jul 26, 16:30:00.0 UT1 (Saturn perihelion)
	#declare Orrery_StartDate			= 2458225.980556;												// e. Julian days, A.D. 2018 Apr 17, 11:32:00.0 UT1 (Saturn aphelion)
//	#declare Orrery_StopDate			= 2459966.069370;												// a. Julian days, A.D. 2023 Jan 21, 13:39:53.6 UT1 (Jupiter perihelion)
//	#declare Orrery_StopDate			= 2462132.613194;												// b. Julian days, A.D. 2028 Dec 27, 02:42:60.0 UT1 (Jupiter aphelion)
//	#declare Orrery_StopDate			= 2464298.577500;												// c. Julian days, A.D. 2034 Dec 02, 01:51:36.0 UT1 (Jupiter perihelion)
//	#declare Orrery_StopDate			= 2463565.151389;												// d. Julian days, A.D. 2032 Nov 28, 15:38:00.0 UT1 (Saturn perihelion)
	#declare Orrery_StopDate			= 2468906.793056;												// e. Julian days, A.D. 2047 Jul 15, 07:02:00.0 UT1 (Saturn aphelion)
	#declare Orrery_LightRadius			= Orrery_SunRadius/Orrery_AU * Orrery_SceneScale * 8;			// AU
	#declare Orrery_RingDistance		= 4;															// AU
	#declare Orrery_TrailRadius			= Orrery_SceneScale/256;										// AU
#end

#if (Orrery_Animation = true)
	#declare Orrery_DiffDate		= Orrery_StopDate - Orrery_StartDate;								// Julian days
	#declare Orrery_StopDate		= Orrery_StartDate + clock * Orrery_DiffDate;						// Julian days
#end

#if (Orrery_DecoMode = 1)
	#declare Orrery_LightMode = 2;
#elseif (Orrery_DecoMode = 2)
	#declare Orrery_LightMode = 4;
#end

#debug "\n"
#debug concat("Orrery_StartDate = ", str(Orrery_StartDate, 0, -1), "\n")
#debug concat("Orrery_StopDate = ", str(Orrery_StopDate, 0, -1), "\n")
#debug "\n"


//------------------------------------------------------------------------------
// CAMERA


#declare Orrery_Camera_Horizontal	= -30;			// -asind(tand(30));
#declare Orrery_Camera_Vertical		= -45;			// -45;
#declare Orrery_Camera_Aspect		= image_height/image_width;
#declare Orrery_Camera_Distance		= 4;			// was 32
#declare Orrery_Camera_Rotate		= <Orrery_Camera_Horizontal,0,Orrery_Camera_Vertical>;
#declare Orrery_Camera_Translate	= <0,0,0>;
#declare Orrery_Camera_Up			= +z * 2 * Orrery_Camera_Aspect;
#declare Orrery_Camera_Right		= +x * 2;
#declare Orrery_Camera_Location		= -y * Orrery_Camera_Distance;
#declare Orrery_Camera_Direction	= +y * Orrery_Camera_Distance;
#declare Orrery_Camera_Transform = transform
{
	rotate		Orrery_Camera_Rotate
	scale		Orrery_SceneScale
	translate	Orrery_Camera_Translate
}

#if (Orrery_CameraMode = 1)
	Set_Camera_Orthographic(false)
	Set_Camera_Transform(Orrery_Camera_Transform)
	Set_Camera_Alt(Orrery_Camera_Location, Orrery_Camera_Direction, Orrery_Camera_Right, Orrery_Camera_Up)
#elseif (Orrery_CameraMode = 2)
	Set_Camera_Orthographic(true)
	Set_Camera_Transform(Orrery_Camera_Transform)
	Set_Camera_Alt(Orrery_Camera_Location, Orrery_Camera_Direction, Orrery_Camera_Right, Orrery_Camera_Up)
#end


//------------------------------------------------------------------------------
// MISC. GRAPHICAL SETTINGS


global_settings
{
	assumed_gamma	1.0
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	0
	radiosity
	{
		Rad_Settings(Radiosity_Final, off, off)
//		brightness 1/4
	}
}

#if (Orrery_DecoMode = 1)

	sky_sphere
	{
		pigment
		{
			bozo
			color_map
			{
				[0.0 color srgb 1]
				[0.2 color srgb 0]
				[1.0 color srgb 0]
			}
			scale 1e-4
		}
	}
/*
	sky_sphere
	{
		pigment
		{
			image_map
			{
				jpeg "8k_stars_milky_way.jpg"
				map_type 1
			}
		}
	}
*/
#elseif (Orrery_DecoMode = 2)
	background {color srgb 3/4}
#end


//------------------------------------------------------------------------------
// BLAH







//------------------------------------------------------------------------------
// PLANETS


#include "orrery_planet_stats.inc"

#for (Orrery_i, 0, Orrery_PlanetsNumber - 1, 1)
	#if (Orrery_ShowPlanet[Orrery_i] = true)
		Orrery_PlaceSphere(Orrery_i, Orrery_StopDate)
		#if (Orrery_ShowPaths[Orrery_i] = true)
			#if (Orrery_InnerOuter = 1)
				Orrery_TracePath(Orrery_i, Orrery_StartDate, Orrery_StopDate, 1)
			#elseif (Orrery_InnerOuter = 2)
				Orrery_TracePath(Orrery_i, Orrery_StartDate, Orrery_StopDate, 100)
			#end
		#end
	#end
#end


//------------------------------------------------------------------------------
// ECLIPTIC MARKER PLANE


#declare Orrery_Ecliptic_Pattern = union
{
	#local Orrery_Ecliptic_Steps = 128;
	#for (i, Orrery_RingDistance, Orrery_Ecliptic_Steps, Orrery_RingDistance)
		difference
		{
			cylinder {-y * 1, +y * 1, i + Orrery_LineThickness/2}
			cylinder {-y * 2, +y * 2, i - Orrery_LineThickness/2}
		}
	#end
	#local Orrery_Ecliptic_Steps = 4;
	#local Orrery_Ecliptic_Angle = 360/Orrery_Ecliptic_Steps;
	#for (i, 1, Orrery_Ecliptic_Steps)
		cylinder
		{
			0, +x * 48, Orrery_LineThickness/2
			rotate +y * i * Orrery_Ecliptic_Angle
		}
	#end
}

plane
{
	y, 0
	pigment
	{
		object
		{
			Orrery_Ecliptic_Pattern
			color srgbt <7/8,7/8,7/8,3/4>
			color srgbt <7/8,7/8,7/8,1/4>
		}
	}
	hollow
	rotate +x * 90
}


//------------------------------------------------------------------------------
// SUN


#declare Orrery_Sun_Object = sphere
{ 
	0, Orrery_LightRadius
	hollow
	material
	{
		texture
		{
			pigment {rgbt 1}
		}
		interior
		{
			media
			{
				emission Orrery_LightColor/Orrery_LightRadius
				density
				{
					spherical
					density_map
					{
						[0.0 rgb 0]
						[0.1 rgb 1]
						[1.0 rgb 1]
					}
					scale Orrery_LightRadius
				}
			}
		}
	}
	no_shadow
}

#if (Orrery_LightMode != 2)
	object {Orrery_Sun_Object}
#end

#local Orrery_SunText = text
{
	ttf Orrery_TextFont, "Sol", 0.001, <0,0>
	scale Orrery_TextSize
	#if (Orrery_DecoMode = 1)
		pigment {color srgb 3/4}
		finish {ambient 0 diffuse 0 emission 1}
	#elseif (Orrery_DecoMode = 2)
		pigment {color srgb 0}
	#end
	no_shadow
}

#local Orrery_SunCoo3D			= <0,0,0>;
#local Orrery_SunCoo2D			= Get_Screen_XY(Orrery_SunCoo3D);
#local Orrery_SunCoo2D			= Orrery_SunCoo2D/<image_width,image_height>;
#local Orrery_SunCoo2D			= <Orrery_SunCoo2D.x,1-Orrery_SunCoo2D.y>;
Screen_Object(Orrery_SunText, Orrery_SunCoo2D + <0.01,0.01>, 0, false, 0.01)


//------------------------------------------------------------------------------
// OVERLAY TEXT


#local Orrery_DayString = concat("JD ", str(Orrery_StopDate,0,1));
#local Orrery_DayText = text
{
	ttf Orrery_TextFont Orrery_DayString, 0.001, <0,0>
	scale Orrery_TextSize
	#if (Orrery_DecoMode = 1)
		pigment {color srgb 3/4}
		finish {ambient 0 diffuse 0 emission 1}
	#elseif (Orrery_DecoMode = 2)
		pigment {color srgb 0}
	#end
	no_shadow
}

Screen_Object(Orrery_DayText, <0.74,0.02>, <0.02,0.02>, false, 0.01)


//------------------------------------------------------------------------------
// LIGHTS


#switch (Orrery_LightMode)
	// area light (slow)
	#case (2)
		light_source
		{
			0
			Orrery_LightColor*2
			area_light
			x * Orrery_LightRadius * 2, y * Orrery_LightRadius * 2	// lights spread out across this distance (x * z)
			5, 5													// total number of lights in grid (4x*4z = 16 lights)
			adaptive 1												// 0,1,2,3...
			jitter													// adds random softening of light
			circular												// make the shape of the light circular
			orient													// orient light
			area_illumination on
			looks_like {Orrery_Sun_Object}
		}
	#break
	// point light (not slow)
	#case (3)
		light_source
		{
			0
			Orrery_LightColor
			looks_like {Orrery_Sun_Object}
		}
	#break
	// exterior lights
	#case (4)
		light_source
		{
			<-1,+1,+1,> * 100
			color		rgb 1
			rotate		+z * 15
			parallel
			point_at	0
//			shadowless
		}
		light_source
		{
			<-1,+1,+1,> * 100
			color		rgb 1
			rotate		-z * 270
			rotate		+z * 15
			parallel
			point_at	0
			shadowless
		}
	#break
#end


//------------------------------------------------------------------------------
// MARKERS


#if (Orrery_MarkerShow = true)
	union
	{
		cylinder
		{
			0, x * 8, 0.01
			pigment {color srgb x transmit 0}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cylinder
		{
			0, y * 8, 0.01
			pigment {color srgb y transmit 0}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cylinder
		{
			0, z * 8, 0.01
			pigment {color srgb z transmit 0}
			finish {ambient 0 diffuse 0 emission 1}
		}
		no_shadow
		no_reflection
	}
#end
