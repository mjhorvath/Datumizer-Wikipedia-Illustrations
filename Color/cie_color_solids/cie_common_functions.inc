#declare cie_pigmentR = pigment
{
	function {cie_linearRGBc(cie_fOutR(cie_fInpX(x,y,z),cie_fInpY(x,y,z),cie_fInpZ(x,y,z)))}
	color_map
	{
		[0 color rgb <0,0,0>]
		[1 color rgb <3,0,0>]
	}
}
#declare cie_pigmentG = pigment
{
	function {cie_linearRGBc(cie_fOutG(cie_fInpX(x,y,z),cie_fInpY(x,y,z),cie_fInpZ(x,y,z)))}
	color_map
	{
		[0 color rgb <0,0,0>]
		[1 color rgb <0,3,0>]
	}
}
#declare cie_pigmentB = pigment
{
	function {cie_linearRGBc(cie_fOutB(cie_fInpX(x,y,z),cie_fInpY(x,y,z),cie_fInpZ(x,y,z)))}
	color_map
	{
		[0 color rgb <0,0,0>]
		[1 color rgb <0,0,3>]
	}
}
#declare cie_pigmentRGB = pigment
{
	average
	pigment_map
	{
		[1 cie_pigmentR]
		[1 cie_pigmentG]
		[1 cie_pigmentB]
	}
}
#declare cie_fFinal = function(X,Y,Z)
{
	cie_fDist
	(
		cie_fD(cie_fOutR(X,Y,Z)),
		cie_fD(cie_fOutG(X,Y,Z)),
		cie_fD(cie_fOutB(X,Y,Z))
	)
}
