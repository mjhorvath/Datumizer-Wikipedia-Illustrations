// This file is licensed under the terms of the CC-LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html


#version 3.8


//------------------------------------------------------------------------------
// INCLUDES


#include "math.inc"
#include "transforms.inc"


//------------------------------------------------------------------------------
// GLOBAL PARAMETERS


#declare Orrery_Planet_Select = 2;
#declare Orrery_Marker_Length = 1.5;
#declare Orrery_Marker_Radius = 0.01;
#declare Orrery_Marker_ArrLen = Orrery_Marker_Length * 1.125;


//------------------------------------------------------------------------------
// CAMERA


#declare Orrery_Camera_Horizontal	= -90;			// asind(tand(30));
#declare Orrery_Camera_Vertical		= 0;			// 45;
#declare Orrery_Camera_Aspect		= image_height/image_width;
#declare Orrery_Camera_Distance		= 4;			// was 32
#declare Orrery_Camera_Rotate		= <Orrery_Camera_Horizontal,0,Orrery_Camera_Vertical>;
#declare Orrery_Camera_Scale		= 2;
#declare Orrery_Camera_Translate	= <0,0,0>;
#declare Orrery_Camera_Up			= +z * 2 * Orrery_Camera_Aspect;
#declare Orrery_Camera_Right		= +x * 2;
#declare Orrery_Camera_Location		= -y * Orrery_Camera_Distance;
#declare Orrery_Camera_Direction	= +y * Orrery_Camera_Distance;
#declare Orrery_Camera_Transform = transform
{
	rotate		Orrery_Camera_Rotate
	scale		Orrery_Camera_Scale
	translate	Orrery_Camera_Translate
}

camera
{
	location Orrery_Camera_Location
	direction Orrery_Camera_Direction
	up Orrery_Camera_Up
	right Orrery_Camera_Right
	transform {Orrery_Camera_Transform}
}


//------------------------------------------------------------------------------
// LIGHTS


light_source
{
	<+1,+1,+1,> * 100
	color rgb	1
	parallel
	point_at 0
//	shadowless
}
light_source
{
	<+1,+1,+1,> * 100
	color rgb	1
	rotate +z * 270
	parallel
	point_at 0
	shadowless
}


//------------------------------------------------------------------------------
// MISC. GRAPHICAL SETTINGS


global_settings
{
	radiosity
	{
		always_sample	off
		brightness		0.3
	}
	ambient_light	0.01
	charset			utf8
	assumed_gamma	1
}

background {color srgb 3/4}


//------------------------------------------------------------------------------
// TEST AREA


#declare obliquity = 23.43928;					// deg, obliquity of Earth pole axis
#declare d = 2458383.500000;					// Julian day, A.D. 2018 Sep 22, 00:00:00.0
#declare T = d / 36525;							// Julian century

#switch (Orrery_Planet_Select)
	#case (2)
		// Earth
		#declare alpha_0 = 0.00 - 0.641 * T;			// deg, right ascension
		#declare delta_0 = 90.00 - 0.557 * T;			// deg, declination
		#declare W = 190.147 + 360.9856235 * d;			// deg, prime meridian orientation
	#break
	#case (3)
		// Mars
		#declare alpha_0 = 317.68143 - 0.1061 * T;
		#declare delta_0 = 52.88650 - 0.0609 * T;
		#declare W = 176.630 + 350.89198226 * d;
	#break
	#case (5)
		// Saturn
		#declare alpha_0 = 40.589 - 0.036 * T;
		#declare delta_0 = 83.537 - 0.004 * T;
		#declare W = 38.90 + 810.7939024 * d;
	#break
	#case (6)
		// Uranus
		#declare alpha_0 = 257.311;
		#declare delta_0 = -15.175;
		#declare W = 203.81 - 501.1600928 * d;
	#break
	#case (7)
		// Neptune
		#declare N = 357.85 + 52.316 * T;
		#declare alpha_0 = 299.36 + 0.70 * sind(N);
		#declare delta_0 = 43.46 - 0.51 * cosd(N);
		#declare W = 253.18 + 536.3128492 * d - 0.48 * sind(N);
	#break
#end

#debug "\n"
#debug concat("90+alpha_0 = ", str(90+alpha_0,0,-1), "\n")
#debug concat("90-delta_0 = ", str(90-delta_0,0,-1), "\n")
#debug concat("W = ", str(W,0,-1), "\n")
#debug concat("mod(W,360) = ", str(mod(W,360),0,-1), "\n")
#debug "\n"

#macro rotate_around_x(coo, ang)
	#local new_x = +coo.x;
	#local new_y = +coo.y * cosd(ang) + coo.z * sind(ang);
	#local new_z = -coo.y * sind(ang) + coo.z * cosd(ang);
	(<new_x,new_y,new_z>)
#end
#macro rotate_around_y(coo, ang)
	#local new_x = +coo.x * cosd(ang) - coo.z * sind(ang);
	#local new_y = +coo.y;
	#local new_z = +coo.x * sind(ang) + coo.z * cosd(ang);
	(<new_x,new_y,new_z>)
#end
#macro rotate_around_z(coo, ang)
	#local new_x = +coo.x * cosd(ang) + coo.y * sind(ang);
	#local new_y = -coo.x * sind(ang) + coo.y * cosd(ang);
	#local new_z = +coo.z;
	(<new_x,new_y,new_z>)
#end

#macro rotate_around_x_alt(coo, ang)
	#local new_x = +coo.x;
	#local new_y = +coo.y * cosd(ang) - coo.z * sind(ang);
	#local new_z = +coo.y * sind(ang) + coo.z * cosd(ang);
	(<new_x,new_y,new_z>)
#end
#macro rotate_around_y_alt(coo, ang)
	#local new_x = +coo.x * cosd(ang) + coo.z * sind(ang);
	#local new_y = +coo.y;
	#local new_z = -coo.x * sind(ang) + coo.z * cosd(ang);
	(<new_x,new_y,new_z>)
#end
#macro rotate_around_z_alt(coo, ang)
	#local new_x = +coo.x * cosd(ang) - coo.y * sind(ang);
	#local new_y = +coo.x * sind(ang) + coo.y * cosd(ang);
	#local new_z = +coo.z;
	(<new_x,new_y,new_z>)
#end

// Returns a vector containing the input vector's X and Y Euler angles, relative to the Z-axis.
// To reproduce the original vector, rotate a point located on the Z-axis by these angles.
#macro vanglesXY(tVec2)
    #local fSgnX = 1;
	#local fSgnY = 1;
	#local tPrjB1 = vnormalize(<tVec2.x, 0, tVec2.z>);
    #if (tPrjB1.x != 0)
        #local fSgnX = tPrjB1.x/abs(tPrjB1.x) * -1;
    #end
    #local tPrjB1 = <tPrjB1.x,tPrjB1.y,max(min(tPrjB1.z,1),-1)>;
    #local fAngY = acosd(tPrjB1.z) * fSgnX;
    #local tPrjB2 = vnormalize(vrotate(tVec2, <0, fAngY, 0>));
    #if (tPrjB2.y != 0)
        #local fSgnY = tPrjB2.y/abs(tPrjB2.y);
    #end
    #local tPrjB2 = <tPrjB2.x,tPrjB2.y,max(min(tPrjB2.z,1),-1)>;
    #local fAngX = acosd(tPrjB2.z) * fSgnY;
    (<fAngX * -1, fAngY * -1, 0>)
#end

// Supposed to return X and Z rotation angles relative to the Y axis, but currently only returns the Z angle.
#macro vanglesZX(tVec2)
	#local newV = vnormalize(tVec2);
//	#local angZ = atand(newV.y/newV.x) - 90;
	#local angZ = atand(newV.y/newV.x) + 90;
	(<0,0,angZ>)
#end


//#declare sphere_coo = <0,0,1>;
//#declare sphere_coo = rotate_around_z(sphere_coo, (W));
//#declare sphere_coo = rotate_around_x(sphere_coo, (90-delta_0));
//#declare sphere_coo = rotate_around_z(sphere_coo, (90+alpha_0));
//#declare sphere_coo = rotate_around_x(sphere_coo, (-obliquity));
//#declare sphere_coo = sphere_coo * <1,-1,1>;
//#declare sphere_coo = rotate_around_z(sphere_coo, 90);

#declare sphere_coo = <0,0,1>;
#declare sphere_coo = vrotate(sphere_coo, +z * (W));
#declare sphere_coo = vrotate(sphere_coo, +x * (90-delta_0));
#declare sphere_coo = vrotate(sphere_coo, +z * (90+alpha_0));
#declare sphere_coo = vrotate(sphere_coo, +x * (-obliquity));

// default
#declare sphere_trans = transform
{
	#if (Orrery_Planet_Select = 2)
		rotate +z * -31
	#end
	rotate +z * (W)
	rotate +x * (90-delta_0)
	rotate +z * (90+alpha_0)
	rotate +x * (-obliquity)
	#if (Orrery_Planet_Select = 2)
		rotate +z * 100
	#end
}
/*
// saturn
#declare sphere_trans = transform
{
	rotate -z * (W-90)
	rotate +x * (90-delta_0)
	rotate +z * (90+alpha_0)
	rotate +x * (-obliquity)
}
// uranus
#declare sphere_trans = transform
{
	rotate -z * (W-90)
	rotate +x * (90-delta_0+180)
	rotate +z * (90+alpha_0)
	rotate +x * (-obliquity)
}
*/


#declare fudge_trans = transform
{
//	rotate +z * 90
}

// transformed objects
union
{
	// planet body
	sphere
	{
		0, 1
		pigment
		{
			image_map
			{
				#switch (Orrery_Planet_Select)
					#case (2)
						jpeg "2k_earth_daymap.jpg"
					#break
					#case (3)
						jpeg "2k_mars.jpg"
					#break
					#case (5)
						jpeg "2k_saturn.jpg"
					#break
					#case (6)
						jpeg "2k_uranus.jpg"
					#break
					#case (7)
						jpeg "2k_neptune.jpg"
					#break
				#end
				map_type 1
			}
			scale <-1,1,1>
			rotate +x * 90
		}
	}
	// body frame markers
	union
	{
		cylinder
		{
			0, x * Orrery_Marker_Length, Orrery_Marker_Radius
			pigment {color srgb x}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cone
		{
			x * Orrery_Marker_Length, Orrery_Marker_Radius * 3, x * Orrery_Marker_ArrLen, 0
			pigment {color srgb x}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cylinder
		{
			0, y * Orrery_Marker_Length, Orrery_Marker_Radius
			pigment {color srgb y}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cone
		{
			y * Orrery_Marker_Length, Orrery_Marker_Radius * 3, y * Orrery_Marker_ArrLen, 0
			pigment {color srgb y}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cylinder
		{
			0, z * Orrery_Marker_Length, Orrery_Marker_Radius
			pigment {color srgb z}
			finish {ambient 0 diffuse 0 emission 1}
		}
		cone
		{
			z * Orrery_Marker_Length, Orrery_Marker_Radius * 3, z * Orrery_Marker_ArrLen, 0
			pigment {color srgb z}
			finish {ambient 0 diffuse 0 emission 1}
		}
		no_shadow
	}
	transform {sphere_trans}
	transform {fudge_trans}
}

// calculated positions
sphere
{
	+sphere_coo, 0.02
	pigment {color srgb x+y}
	finish {ambient 0 diffuse 1 emission 1/2}
	transform {fudge_trans}
}
sphere
{
	-sphere_coo, 0.02
	pigment {color srgb x+y}
	finish {ambient 0 diffuse 1 emission 1/2}
	transform {fudge_trans}
}

// ecliptic frame markers
union
{
	cylinder
	{
		0, x * Orrery_Marker_Length, Orrery_Marker_Radius
		pigment {color srgb x/4}
		finish {ambient 0 diffuse 0 emission 1}
	}
	cone
	{
		x * Orrery_Marker_Length, Orrery_Marker_Radius * 3, x * Orrery_Marker_ArrLen, 0
		pigment {color srgb x/4}
		finish {ambient 0 diffuse 0 emission 1}
	}
	cylinder
	{
		0, y * Orrery_Marker_Length, Orrery_Marker_Radius
		pigment {color srgb y/4}
		finish {ambient 0 diffuse 0 emission 1}
	}
	cone
	{
		y * Orrery_Marker_Length, Orrery_Marker_Radius * 3, y * Orrery_Marker_ArrLen, 0
		pigment {color srgb y/4}
		finish {ambient 0 diffuse 0 emission 1}
	}
	cylinder
	{
		0, z * Orrery_Marker_Length, Orrery_Marker_Radius
		pigment {color srgb z/4}
		finish {ambient 0 diffuse 0 emission 1}
	}
	cone
	{
		z * Orrery_Marker_Length, Orrery_Marker_Radius * 3, z * Orrery_Marker_ArrLen, 0
		pigment {color srgb z/4}
		finish {ambient 0 diffuse 0 emission 1}
	}
	no_shadow
}
