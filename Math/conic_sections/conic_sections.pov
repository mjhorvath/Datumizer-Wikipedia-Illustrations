//+KFI0 +KFF9
//+K1


// Persistence of Vision Ray Tracer Scene Description File
// File: ?.pov
// Vers: 3.6
// Desc: Basic Scene Example
// Date: mm/dd/yy
// Auth: ?
//

#version 3.6;

#include "colors.inc"
#include "functions.inc"
#include "Axes_macro.inc"
#include "ShapeGrid_macro.inc"

global_settings
{
	assumed_gamma 1.0
	max_trace_level 200          // keep higher than the number of planes!
	ambient_light 0
}

#declare Camera_Mode = 0;
#declare hypoteneuse = 10;
#declare theta = 45 / (180/pi);	//45 / (180/pi)
#declare opposite = sin(theta) * hypoteneuse;
#declare adjacent = cos(theta) * hypoteneuse;

//#declare theta = 45 / (180/pi);	//45 / (180/pi)
//#declare opposite = 10;
//#declare hypoteneuse = opposite/sin(theta);
//#declare adjacent = cos(theta) * hypoteneuse;

#declare offset_x = -0;
#declare offset_y = -1.5;
#declare rotate_angle = clock*90;
#declare axis_radius = 0.02;

// ----------------------------------------

#switch (Camera_Mode)
	#case (0)
		camera
		{
		//	orthographic
			location <0, 0, -50>
			direction <0, 0, 50>
			right	x * 20 * image_width/image_height
			up	y * 20
			rotate <30,10,0,>
		}
	#break
	#case (1)
		camera
		{
			orthographic
			location <0, 50, 0>
			direction <0, -50, 0>
			right	z * 5 * image_width/image_height
			up	x * 5
			rotate z*rotate_angle
		}
	#break
	#case (2)
		camera
		{
			orthographic
			location <0, 0, -50>
			direction <0, 0, 50>
			right	x * 5 * image_width/image_height
			up	y * 5
			rotate <0,0,0,>
		}
	#break
#end
/*
sky_sphere
{
  pigment
  {
    gradient y
    color_map
    {
      [0.0 rgb <0.6,0.7,1.0>]
      [0.7 rgb <0.0,0.1,0.8>]
    }
  }
}
*/

background
{
	color rgb 1/2
}

light_source
{
	<0, 0, -2000>
	color rgb 1
//	parallel
	rotate <30,30,0,>
	scale 1
}

//////////////

#declare top_cone = cone
{
	<0,opposite,0,>, adjacent, 0, 0
	open
	hollow
}

#declare bot_cone = cone
{
	<0,-opposite,0,>, adjacent, 0, 0
	open
	hollow
}

#declare cone_axis = cylinder
{
	<0,opposite*2,0,>, <0,-opposite*2,0,>, axis_radius
}

#declare plane_axis_1 = cylinder
{
	<0,0,opposite,>, <0,0,-opposite,>, axis_radius
	translate x*offset_x
	translate y*offset_y
}

#declare plane_axis_2 = cylinder
{
	<opposite*10,0,0,>, <-opposite*10,0,0,>, axis_radius
	rotate z*rotate_angle
	translate x*offset_x
	translate y*offset_y
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}

#declare rotate_point = sphere
{
	0, axis_radius*2
	translate x*offset_x
	translate y*offset_y
}

#declare equa_plane = plane
{
	-y, 0
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}

#declare anim_plane = plane
{
	-y, 0
	rotate z*rotate_angle
	translate x*offset_x
	translate y*offset_y
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}

#declare focus_point = sphere
{
	trace(anim_plane, <0,opposite*2,0,>, <0,-1,0,>), axis_radius*2
}

#declare directrix_point = sphere
{
	trace(equa_plane, <offset_x,offset_y,0,>, vrotate(<1,0,0,>,z*rotate_angle)), axis_radius*2
}

#declare vertex_1_point = sphere
{
	trace(top_cone, <offset_x,offset_y,0,>, vrotate(<1,0,0,>,z*rotate_angle)), axis_radius*2
}

#declare vertex_2_point = sphere
{
	trace(bot_cone, <offset_x,offset_y,0,>, vrotate(<1,0,0,>,z*rotate_angle)), axis_radius*2
}

#declare directrix_axis = cylinder
{
	<0,0,opposite*10,>, <0,0,-opposite*10,>, axis_radius
	translate trace(equa_plane, <offset_x,offset_y,0,>, vrotate(<1,0,0,>,z*rotate_angle))
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}

#declare ellp_plane = plane
{
	-y, 0
	hollow
	rotate z*30
	translate x*-adjacent
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}

#declare circ_plane = plane
{
	-y, 0
//	rotate z*30
	translate x*-adjacent
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}
#declare para_plane = plane
{
	-y, 0
	rotate z*60
	translate x*-adjacent
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}
#declare hypr_plane = plane
{
	-y, 0
	rotate z*75
	translate y*-adjacent
	clipped_by
	{
		box
		{
			<-opposite,-opposite,-opposite,>,<opposite,opposite,opposite,>
		}
	}
}

#declare double_conic = union
{
	object {top_cone}
	object {bot_cone}
}

object
{
	double_conic
	pigment
	{
		color rgbt <0,1/2,1/2,1/2,>
	}
	no_shadow
}
object
{
	anim_plane
	clipped_by
	{
		object {double_conic}
	}
	pigment {color rgb 0}
	no_shadow
}
object
{
	anim_plane
	clipped_by
	{
		object {double_conic inverse}
	}
	pigment {color rgbt <1/2,1/2,0,1/2>}
	no_shadow
}

union
{
	object
	{
		cone_axis
		pigment
		{
			color rgb x*1
		}
	}
	object
	{
		plane_axis_1
		pigment
		{
			color rgbt <1/2,1/2,0,1/2>
		}
	}
	object
	{
		plane_axis_2
		pigment
		{
			color rgbt <1/2,1/2,0,1/2>
		}
	}
	object
	{
		directrix_axis
		pigment
		{
			color rgb x*1
		}
	}
	object
	{
		rotate_point
		pigment
		{
			color rgb 1
		}
	}
	object
	{
		equa_plane
		pigment
		{
			color rgbt <1/2,0,1/2,1/2>
		}
	}
	object
	{
		focus_point
		pigment	{color rgb 1}
	}
	object
	{
		directrix_point
		pigment	{color rgb 1}
	}
	object
	{
		vertex_1_point
		pigment	{color rgb 1}
	}
	object
	{
		vertex_2_point
		pigment	{color rgb 1}
	}
	no_shadow
	no_image
}

// the coordinate grid and axes
Axes_Macro
(
	100,	// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
	10,	// Axes_majUnit,	The size of each large-unit square.	(float)
	10,	// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0005,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).	(float)
	on,	// Axes_aBool,		Turns the axes on/off. (boolian)
	on,	// Axes_mBool,		Turns the minor units on/off. (boolian)
	off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.	(boolian)
	on,	// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.	(boolian)
	off	// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.	(boolian)
)
/*
object
{
	Axes_Object
	translate -0.000001
}
*/