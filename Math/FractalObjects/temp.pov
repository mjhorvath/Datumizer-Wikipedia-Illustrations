// Doesn't work yet
#macro FracObj_Menger_Sponge(dMax, cSca, gWid)
	#local iPos = array[7]
	{
		<1,1,1>,
		<1,1,0>,
		<1,0,1>,
		<0,1,1>,
		<1,1,2>,
		<1,2,1>,
		<2,1,1>
	}
	#local gWid = gWid * pow(3, dMax);
	#local bObj = merge
	{
		box {<1/3,1/3,-1/9>,<2/3,2/3,10/9>}
		box {<1/3,-1/9,1/3>,<2/3,10/9,2/3>}
		box {<-1/9,1/3,1/3>,<10/9,2/3,2/3>}
		scale cSca - gWid
		translate gWid/2
	}
	#local dCount = 0;
	#while (dCount < dMax)
		#local bObj = union
		{
			#local iCount = 0;
			#while (iCount < 7)
				#local iCoo = iPos[iCount];
				#local cCoo = iCoo * cSca;
				object
				{
					bObj
					translate cCoo
					scale 1/3
				}
				#local iCount = iCount + 1;
			#end
			bounded_by {box {0, cSca}}
		}
		#local dCount = dCount + 1;
	#end
	difference
	{
		box {0, cSca}
		object { bObj }
	}
#end


// Doesn't work yet
#macro FracObj_Menger_Sponge(dMax, cSca, gWid)
	#local iPos = array[7]
	{
		<1,1,1>,
		<1,1,0>,
		<1,0,1>,
		<0,1,1>,
		<1,1,2>,
		<1,2,1>,
		<2,1,1>
	}
	#local gWid = gWid * pow(3, dMax);
	#local bObj = box
	{
		0, 1
		scale cSca - gWid
		translate gWid/2
	}
	#local dCount = 0;
	#while (dCount < dMax)
		#local bObj = union
		{
			#local iCount = 0;
			#while (iCount < 7)
				#local iCoo = iPos[iCount] * cSca;
				object
				{
					bObj
					translate iCoo
					scale 1/3
				}
				#local iCount = iCount + 1;
			#end
		}
		#local dCount = dCount + 1;
	#end
	difference
	{
		box {0, cSca}
		object { bObj scale 1.01 translate -0.005}
	}
#end


// This works, but is slow
#macro FracObj_Menger_Sponge(dMax, cSca, gWid)
	#local iPos = array[20];
	#local iMax = 3;
	#local iCount = 0;
	#local xCount = 0;
	#while (xCount < iMax)
		#local yCount = 0;
		#while (yCount < iMax)
			#local zCount = 0;
			#while (zCount < iMax)
				#if ((xCount = 1) & (yCount = 1))
				#else
					#if ((xCount = 1) & (zCount = 1))
					#else
						#if ((zCount = 1) & (yCount = 1))
						#else
							#local iPos[iCount] = <xCount,yCount,zCount,>;
							#local iCount = iCount + 1;
						#end
					#end
				#end
				#local zCount = zCount + 1;
			#end
			#local yCount = yCount + 1;
		#end
		#local xCount = xCount + 1;
	#end
	#local gWid = gWid * pow(3, dMax);
	#local bObj = box
	{
		0, 1
		scale cSca - gWid
		translate gWid/2
	}
	#local dCount = 0;
	#while (dCount < dMax)
		#local bObj = union
		{
			#local iCount = 0;
			#while (iCount < 20)
				#local iCoo = iPos[iCount] * cSca;
				object
				{
					bObj
					translate iCoo
					scale 1/3
				}
				#local iCount = iCount + 1;
			#end
			bounded_by {box {0, cSca}}
		}
		#local dCount = dCount + 1;
	#end
	object { bObj }
#end
