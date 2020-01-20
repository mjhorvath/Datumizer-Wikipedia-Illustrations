Caption         Shape grid macro
Version         1.16
Authors         Michael Horvath, with formulas by And and Tor Olav Kristensen
Website         http://isometricland.net
Created         2008-06-22
Updated         2018-08-04
This file is licensed under the terms of the CC-LGPL.

DESCRIPTION

This include file contains a collection of macros used to generate grids of 
several different shapes. The grid objects are untextured, and therefore can be 
used within CSG operations. They can also be used within object patterns. The 
principle feature is that grid lines always remain a constant width no matter 
where they are within the object.

The macros must be called from within an "object" tag.

Several shapes are provided
- Cube
- Cone
- Cylinder
- Sphere (parametric)
- Sphere (Munsell)
- Ellipsoid (parametric)
- Double-cone
- Inverted double-cone


REFERENCE

SGrid_Cone_Macro
(
	6,			// ConeGrid_radii,		// The number of radial divisions.		(integer)
	12,			// ConeGrid_longt,		// The number of longitudinal divisions.	(integer)
	6,			// ConeGrid_lattt,		// The number of latitudinal divisions.		(integer)
	1,			// ConeGrid_radius,		// The radius of the cone.			(float)
	1,			// ConeGrid_height,		// The height of the cone.			(float)
	0,			// ConeGrid_center,		// The center coordinates of the cone.		(vector)
	0.01,			// ConeGrid_thickness,		// The thickness of the grid lines.		(float)
	on,			// ConeGrid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// ConeGrid_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_Cylinder_Macro
(
	6,			// CylinderGrid_radii,		// The number of radial divisions.		(integer)
	12,			// CylinderGrid_longt,		// The number of longitudinal divisions.	(integer)
	6,			// CylinderGrid_lattt,		// The number of latitudinal divisions.		(integer)
	1,			// CylinderGrid_radius,		// The radius of the cylinder.			(float)
	1,			// CylinderGrid_height,		// The height of the cylinder.			(float)
	0,			// CylinderGrid_center,		// The center coordinates of the cylinder.	(vector)
	0.01,			// CylinderGrid_thickness,	// The thickness of the grid lines.		(float)
	on,			// CylinderGrid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// CylinderGrid_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_Sphere_Macro
(
	6,			// SphereGrid_radii,		// The number of radial divisions.		(integer)
	12,			// SphereGrid_longt,		// The number of longitudinal divisions.	(integer)
	6,			// SphereGrid_lattt,		// The number of latitudinal divisions.		(integer)
	1,			// SphereGrid_radius,		// The radius of the sphere.			(float)
	0,			// SphereGrid_center,		// The center coordinates of the sphere.	(vector)
	0.01,			// SphereGrid_thickness,	// The thickness of the grid lines.		(float)
	on,			// SphereGrid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off			// SphereGrid_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_Munsell_Macro
(
	6,			// SphereMunsellGrid_radii,	// The number of radial divisions.		(integer)
	12,			// SphereMunsellGrid_longt,	// The number of longitudinal divisions.	(integer)
	6,			// SphereMunsellGrid_lattt,	// The number of latitudinal divisions.		(integer)
	1,			// SphereMunsellGrid_radius,	// The radius of the sphere.			(float)
	0,			// SphereMunsellGrid_center,	// The center coordinates of the sphere.	(vector)
	0.01,			// SphereMunsellGrid_thickness,	// The thickness of the grid lines.		(float)
	on			// SphereMunsellGrid_offset,	// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// SphereMunsellGrid_endcap,	// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_Ellipsoid_Macro
(
	3,			// SGrid_Ellipsoid_radii,		// The number of radial divisions.		(integer)
	24,			// SGrid_Ellipsoid_longt,		// The number of longitudinal divisions.	(integer)
	12,			// SGrid_Ellipsoid_latit,		// The number of latitudinal divisions.		(integer)
	1,			// SGrid_Ellipsoid_radius_major,	// The major (horizontal) radius of the ellipsoid.	(float)
	0.5,			// SGrid_Ellipsoid_radius_minor,	// The minor (vertical) radius of the ellipsoid.	(float)
	0,			// SGrid_Ellipsoid_center,		// The center coordinates of the sphere.	(vector)
	0.01,			// SGrid_Ellipsoid_thickness,		// The thickness of the grid lines.		float)
	off,			// SGrid_Ellipsoid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// SGrid_Ellipsoid_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_DblCone_Macro
(
	6,			// DoubleConeGrid_radii,	// The number of radial divisions.		(integer)
	12,			// DoubleConeGrid_longt,	// The number of longitudinal divisions.	(integer)
	12,			// DoubleConeGrid_lattt,	// The number of latitudinal divisions.		(integer)
	1,			// DoubleConeGrid_radius,	// The radius of the double-cone.		(float)
	1,			// DoubleConeGrid_height,	// The height of each half of the double-cone.	(float)
	0,			// DoubleConeGrid_center,	// The center coordinates of the double-cone.	(vector)
	0.01,			// DoubleConeGrid_thickness,	// The thickness of the grid lines.		(float)
	on,			// DoubleConeGrid_offset,	// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// DoubleConeGrid_endcap,	// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_DblConeInv_Macro
(
	6,			// DoubleConeInvGrid_radii,	// The number of radial divisions.		(integer)
	12,			// DoubleConeInvGrid_longt,	// The number of longitudinal divisions.	(integer)
	6,			// DoubleConeInvGrid_lattt,	// The number of latitudinal divisions.		(integer)
	1,			// DoubleConeInvGrid_radius,	// The radius of the double-cone.		(float)
	1,			// DoubleConeInvGrid_height,	// The height of each half of the double-cone.	(float)
	0,			// DoubleConeInvGrid_center,	// The center coordinates of the double-cone.	(vector)
	0.01,			// DoubleConeInvGrid_thickness,	// The thickness of the grid lines.		(float)
	on,			// DoubleConeInvGrid_offset,	// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// DoubleConeInvGrid_endcap,	// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)

SGrid_Cube_Macro
(
	<6,6,6,>,		// SGrid_Cube_sectors,		// The number of sections along each axis.	(integer vector)
	<1,1,1,>,		// SGrid_Cube_width,		// The width of the cuboid along each axis.	(float vector)
	0,			// SGrid_Cube_corner,		// The coordinates of the bottom corner.	(float vector)
	0.01,			// SphereGrid_thickness,	// The thickness of the grid lines.		(float)
	on,			// SphereGrid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
	off,			// SGrid_Cube_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
)
