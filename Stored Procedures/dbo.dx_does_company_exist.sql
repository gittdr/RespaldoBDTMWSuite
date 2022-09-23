SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Pass a company ID and this proc will return a 1 if the company ID is valid in PowerSuite
   or a -1if it is not.  Call should look like:

           DECLARE @CMP VARCHAR(8), @ret int
           SELECT @CMP = 'FORD'
           EXEC @ret =  dx_does_company_exist @cmp
   where @cmp is a varchar(8) and contains the company id; @ret is an int 
*/
CREATE PROCEDURE [dbo].[dx_does_company_exist]
	@cmp_id varchar(8)	
 AS 

 
 IF EXISTS (SELECT top 1 cmp_id FROM company WHERE cmp_id = @cmp_id) 
    RETURN 1
 ELSE
    RETURN -1

GO
GRANT EXECUTE ON  [dbo].[dx_does_company_exist] TO [public]
GO
