SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[update_xfcdatabase_version] (@version varchar(60)) 
as
/**
 * 
 * NAME:
 * dbo.update_xfcdatabase_version 
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

if (select count(*) from generalinfo where gi_name = 'DBVER FUEL IMPORT' ) = 0
	INSERT INTO generalinfo 
			( gi_name, gi_string1)  
 	VALUES( 'DBVER FUEL IMPORT', @version)  
else
  UPDATE generalinfo  
     SET gi_string1 = @version
	from generalinfo 
	where gi_name = 'DBVER FUEL IMPORT'

return

GO
GRANT EXECUTE ON  [dbo].[update_xfcdatabase_version] TO [public]
GO
