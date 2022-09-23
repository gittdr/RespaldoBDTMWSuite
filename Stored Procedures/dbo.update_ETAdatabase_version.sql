SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[update_ETAdatabase_version] (@version varchar(60)) 
as

if (select count(*) from generalinfo where gi_name = 'DBVER ETA AGENT' ) = 0
	INSERT INTO generalinfo 
			( gi_name, gi_string1, gi_datein)  
 	VALUES( 'DBVER ETA AGENT', @version, getdate())  
else
  UPDATE generalinfo  
     SET gi_string1 = @version
	from generalinfo 
	where gi_name = 'DBVER ETA AGENT'

return

GO
GRANT EXECUTE ON  [dbo].[update_ETAdatabase_version] TO [public]
GO
