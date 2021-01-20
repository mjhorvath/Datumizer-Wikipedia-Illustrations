// Video game sprites collection for POV-Ray
// *****************************************
// Author: Michael Horvath
// Website: http://isometricland.com/povray/povray.php
// This file is licensed under the terms of the CC-LGPL.

// Notes: Sprite dimesions are set to match those
// used by Jagged Alliance 2.

#include "strings"
#include "math"

#declare GSprites_North			= on;
#declare GSprites_East			= off;
#declare GSprites_South			= on;
#declare GSprites_West			= off;

//#declare GSprites_Width			= 40*sind(45);
//#declare GSprites_Height		= 50/cosd(30);
//#declare GSprites_Thick			= GSprites_Width/5;

#declare GSprites_Width			= 32;
#declare GSprites_Height		= 48;
#declare GSprites_Thick			= 4;

#local light_horizontal			= atan2d(50/40/cosd(30)/sind(45),1);
#declare GSprites_Lights_Rotate		= <light_horizontal,240,000>;
#declare GSprites_Camera_Rotate		= <030,315,000>;
#declare GSprites_Show_Ground_Plane	= off;


#include "GSprites_Scene_settings.inc"			// Source of the camera and lighting code
#include "GSprites_Walls_prototypes.inc"		// Source of the wall object components
#include "GSprites_Floors_prototypes.inc"		// Source of the floor object components


// -------------------------------------------------------------


#declare this_wall = object
{
	GSprites_Restaraunt_Wall_Object(GSprites_North,GSprites_East,GSprites_South,GSprites_West,GSprites_Width,GSprites_Height,GSprites_Thick)
	#if (GSprites_East + GSprites_West + GSprites_North + GSprites_South = 2)
		#if (GSprites_East + GSprites_West = 2)
//			translate -z * GSprites_Thick * 2
		#else
//			translate -x * GSprites_Thick * 2
		#end
	#end
}

#declare this_floor = object
{
	GSprites_Hardwood_Floor_Object_C(GSprites_Width)
}

union
{
	object {this_wall}
	object {this_floor}
	// delete the following when rendering the actual sprite
//	plane
//	{
//		y,-0.0001
//		pigment {color rgb 1}
//	}
//	translate	GSprites_Up_Vector * 3/4
//	translate	GSprites_Left_Vector * 1/4
}


#debug concat("minext = ", VStr(min_extent(this_wall)), "\n")
#debug concat("maxext = ", VStr(max_extent(this_wall)), "\n")
#debug concat("width = ", Str(GSprites_Width), "\n")
#debug concat("height = ", Str(GSprites_Height), "\n")
#debug concat("angle = ", Str(light_horizontal), "\n")
