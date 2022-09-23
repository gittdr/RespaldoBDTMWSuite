SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Pass a commodity ID and this proc will return a 1 if the commodity exists in PowerSuite
   or a -1 if it does not.  Call should look like:

           SELECT @commodityID = 'barstock'
           exec @ret =  dx_does_commodity_exist @commodityID

   where @commodityID is a varchar(8) and contains the commodity id; @ret is an int 
*/
CREATE PROCEDURE [dbo].[dx_does_commodity_exist]
	@commodityID varchar(8)	
 AS 

 
 IF (SELECT count(*) 
           From commodity
	   WHERE cmd_code = @commodityID) > 0
    RETURN 1
 ELSE
    Return -1

GO
GRANT EXECUTE ON  [dbo].[dx_does_commodity_exist] TO [public]
GO
