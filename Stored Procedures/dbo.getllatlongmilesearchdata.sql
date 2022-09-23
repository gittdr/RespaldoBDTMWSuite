SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[getllatlongmilesearchdata] @lat varchar(15),@long varchar(15),@Xface varchar(30)
As  
/*   
SR 22841 DPETE created 8/2/4 
  Passed a lat and a long in the decimal format (EG 41.4563N or 89.0087W)
  This proc is called to provide an opportunity to format the search string
  used by the mileage interface
  NOTE: Written assuming Rand lookup is same as ALK - Not sure if this is correct
 
*/ 

Select 
searchlevel = 'L',
searchstring =  Case Upper(@Xface)   -- return depends on interface and any overrides
      When 'A - ALK' Then Upper(@lat)+','+Upper(@long)
      When 'P - RAND PC' Then Upper(@lat)+','+Upper(@long)
      Else '?'
      End



GO
GRANT EXECUTE ON  [dbo].[getllatlongmilesearchdata] TO [public]
GO
