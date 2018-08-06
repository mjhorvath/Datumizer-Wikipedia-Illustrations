// POV-Ray scene for achieving the Fallout and Fallout 2 camera angles.
// Render at 512x512px.

#version 3.7
#include "stdinc.inc"
#include "transforms.inc"
#include "screen.inc"		// requires the updated version available here: http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/

global_settings
{
	assumed_gamma	1
}

#local cornerangle	= asind(cosd(30)/2);
#local opposite		= 16;
#local hypotenuse	= 1/cosd(30);
#local adjacent		= cosd(cornerangle) * hypotenuse;
#local verticalstep	= sind(cornerangle)/adjacent;

#local tile_width	= 1;
#local tile_length	= hypotenuse;
#local tile_height	= hypotenuse/2/cosd(cornerangle) * sind(cornerangle);

#debug concat("\nt_h = ", str(tile_height, 0, -1), "\n\n")

#local cam_dist	= 1024;
#local cam_area	= 16;
#local cam_loca	= -z * cam_dist;
#local cam_dirc	= +z;
#local cam_rgvc	= +x * cam_area;
#local cam_upvc	= +y * cam_area;
#local cam_tran = transform
{
	rotate		+x * cornerangle
	rotate		+y * 30
	translate	+y * verticalstep * 8
}
#declare Camera_Orthographic = true;
Set_Camera_Transform(cam_tran)
Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)

#local sun_angle_x = 50;	// guesstimate
#local sun_angle_y = 37;	// guesstimate
light_source
{
	-z * 1024
	color rgb	2
	rotate		+x * sun_angle_x
	rotate		+y * sun_angle_y
	parallel
	point_at	<0,0,0>
}

/*
// checker plane
plane
{
	y, 0
	texture
	{
		pigment
		{
			checker
			color srgb 3/4
			color srgb 1/4
		}
	}
}
*/
// hex plane
plane
{
	y, 0
	texture
	{
		pigment
		{
			hexagon
			color srgb 3/4
			color srgb 2/4
			color srgb 1/4
		}
	}
	scale tile_length/2
}

merge
{

	// house
	intersection
	{
		plane
		{
			+x, 0
			rotate +z * 45
			translate +x * tile_length*4
			translate +y * 12 * tile_height
		}
		plane
		{
			-x, 0
			rotate -z * 45
			translate -x * tile_length*4
			translate +y * 12 * tile_height
		}
		box
		{
			<-tile_length*4, 0, -tile_width*4>, <+tile_length*4, tile_height * 32, +tile_width*4>
		}
	}
	// chimney
	box
	{
		<0,0,0,>, <+tile_length, tile_height * 32, +tile_width,>
	}
	// doorway and floor
	clipped_by
	{
		union
		{
			box {<-tile_length, -1, -tile_width*4-1,>, <+tile_length, +8 * tile_height, +tile_width*4+1,> inverse}
			plane {+y, 0}
		}
	}
	pigment {color srgbt <1,0,0,0>}
}

#local sphere_siz = 1/8;

/*
#local sphere_3d_1 = <+tile_length*4,0,+tile_width*22,>;
sphere {sphere_3d_1, sphere_siz pigment{color srgb y}}
#local sphere_2d_1 = Get_Screen_XY(sphere_3d_1);
#debug concat("\np1 = (", vstr(2, sphere_2d_1, ",", 0, -1), ")\n\n")

#local sphere_3d_2 = <+tile_length*4,0,-tile_width*6,>;
sphere {sphere_3d_2, sphere_siz pigment{color srgb y}}
#local sphere_2d_2 = Get_Screen_XY(sphere_3d_2);
#debug concat("\np2 = (", vstr(2, sphere_2d_2, ",", 0, -1), ")\n\n")

#local shadow_length = cosd(sun_angle_x)/sind(sun_angle_x)*(+12 * tile_height);
#local corner_pos = <+tile_length*4,0,-tile_width*4,>;

#local sphere_3d_5 = <0,0,0,>;
sphere {sphere_3d_5 + corner_pos, sphere_siz pigment{color srgb y}}
#local sphere_2d_5 = Get_Screen_XY(sphere_3d_5) - <512,512>;
#debug concat("\np5 = (", vstr(2, sphere_2d_5, ",", 0, -1), ")\n\n")

#local sphere_3d_6 = <0,+12 * tile_height,0,>;
sphere {sphere_3d_6 + corner_pos, sphere_siz pigment{color srgb y}}
#local sphere_2d_6 = Get_Screen_XY(sphere_3d_6) - <512,512>;
#debug concat("\np6 = (", vstr(2, sphere_2d_6, ",", 0, -1), ")\n\n")

#local sphere_3d_7 = vrotate(<0,0,shadow_length,>, <0,sun_angle_y,0>);
sphere {sphere_3d_7 + corner_pos, sphere_siz pigment{color srgb y}}
#local sphere_2d_7 = Get_Screen_XY(sphere_3d_7) - <512,512>;
#debug concat("\np7 = (", vstr(2, sphere_2d_7, ",", 0, -1), ")\n\n")

cylinder
{
	sphere_3d_5 + corner_pos, sphere_3d_6 + corner_pos, sphere_siz/2
	pigment {color srgb z}
}
cylinder
{
	sphere_3d_5 + corner_pos, sphere_3d_7 + corner_pos, sphere_siz/2
	pigment {color srgb z}
}
*/
