SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[update_database_version] (@version varchar(60)) 
as
/**
 * 
 * NAME:
 * dbo.update_database_version 
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

if (select count(*) from generalinfo where gi_name = 'DBVER TMWSUITE' ) = 0
	INSERT INTO generalinfo 
			( gi_name, gi_string1)  
 	VALUES( 'DBVER TMWSUITE', @version)  
else
  UPDATE generalinfo  
     SET gi_string1 = @version
	from generalinfo 
	where gi_name = 'DBVER TMWSUITE'

return

GO
GRANT EXECUTE ON  [dbo].[update_database_version] TO [public]
GO
