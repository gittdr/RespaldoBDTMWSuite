SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[getaddressmilesearchdata] @address varchar(100),@zip varchar(15),@Xface varchar(30)
As  
/*   
SR 22841 DPETE created 8/2/4 
  Will be called only for a Tool mileage Inguiry by address (if ever implemented). This proc formats
  the search string to be passed to the mileage interface.  Assumes all address level lookups will 
  be done withthe zip code (not always successfull for remote areas)
 
*/ 

Select 
searchlevel = 'L',
searchstring =  Case Upper(@Xface)   -- return depends on interface and any overrides
      When 'A - ALK' Then @zip+';'+@address
      When 'P - RAND PC' Then @zip+';'+@address  -- this may be wrong
      Else '?'
      End



GO
GRANT EXECUTE ON  [dbo].[getaddressmilesearchdata] TO [public]
GO
