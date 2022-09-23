SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_update_all_stats]
AS
/**
 * 
 * NAME:
 * dbo.tmw_update_all_stats
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure will run UPDATE STATISTICS against all user-defined tables within this database.
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

DECLARE @tablename varchar(30)
DECLARE @tablename_header varchar(75)
DECLARE tnames_cursor CURSOR FOR SELECT name FROM sysobjects 
	WHERE type = 'U'
OPEN tnames_cursor
FETCH NEXT FROM tnames_cursor INTO @tablename
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SELECT @tablename_header = 'Updating ' + 
			RTRIM(UPPER(@tablename))
		PRINT @tablename_header
		EXEC ('UPDATE STATISTICS ' + @tablename )
		EXEC ('sp_recompile ' + @tablename )

	END
	FETCH NEXT FROM tnames_cursor INTO @tablename
END
PRINT ' '
PRINT ' '
SELECT @tablename_header = '*************  NO MORE TABLES'
			+ '  *************' 
PRINT @tablename_header
PRINT ' '
PRINT 'Statistics have been updated for all tables.'

DEALLOCATE tnames_cursor
GO
GRANT EXECUTE ON  [dbo].[tmw_update_all_stats] TO [public]
GO
