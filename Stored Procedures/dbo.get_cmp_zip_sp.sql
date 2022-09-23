SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[get_cmp_zip_sp] @cmp_id varchar(8), @cmp_zip varchar(9) output AS
/**
 * 
 * NAME:
 * dbo.get_cmp_zip_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

SELECT	@cmp_zip = cmp_zip
	FROM company 
	WHERE cmp_id = @cmp_id
select @cmp_zip=isnull(@cmp_zip,'')
if @cmp_zip = ''
	SELECT @cmp_zip = cty_zip
		FROM company,city 
		WHERE cmp_id = @cmp_id and cty_code=cmp_city
select @cmp_zip=isnull(@cmp_zip,'')

GO
GRANT EXECUTE ON  [dbo].[get_cmp_zip_sp] TO [public]
GO
