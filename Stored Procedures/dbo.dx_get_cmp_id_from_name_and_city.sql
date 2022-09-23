SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/* Pass a company name and city code ID and this proc will return a 1 and the company ID if the company is valid in TMWSuite
   or a -1if it is not.  Call should look like:

           DECLARE @cmp_name varchar(100), @cmp_city int, @@cmp_id varchar(8), @ret int
           SELECT @cmp_name = 'FORD MOTOR COMPANY'
           SELECT @mcp_city = 11111 (or whatever)
           EXEC @ret =  dx_get_cmp_id_from_name_and_city @cmp_name, @cmp_city, @@cmp_id
           where @cmp_name is a varchar(100) and contains the company name and @cty_code is an integer and 
          contains the TMWSuite city code, @@CMP_ID is a varchar(8) and returns the company id; @ret is an int 
*/
create PROCEDURE [dbo].[dx_get_cmp_id_from_name_and_city]
	@cmp_name varchar(100), 
	@cmp_city int,
	@@cmp_id varchar(8) OUT
 AS 

Select @@CMP_ID = cmp_id from company where cmp_name=@cmp_name and cmp_city=@cmp_city and IsNull(cmp_active,'Y') = 'Y'

 IF (SELECT count(*) 
           From company
	   WHERE cmp_id = @@cmp_id) > 0
    RETURN 1
 ELSE
    Return 0



GO
GRANT EXECUTE ON  [dbo].[dx_get_cmp_id_from_name_and_city] TO [public]
GO
