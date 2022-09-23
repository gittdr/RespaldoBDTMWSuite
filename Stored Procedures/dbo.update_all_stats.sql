SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_all_stats    Script Date: 6/1/99 11:54:06 AM ******/
CREATE PROCEDURE [dbo].[update_all_stats]
AS
/*
This procedure will run UPDATE STATISTICS against
all user-defined tables within this database.
*/
DECLARE @tablename varchar(30)
DECLARE @tablename_header varchar(75)
DECLARE tnames_cursor CURSOR FOR SELECT name FROM sysobjects 
    WHERE type = 'U' ORDER BY name
OPEN tnames_cursor
FETCH NEXT FROM tnames_cursor INTO @tablename
WHILE (@@fetch_status <> -1)
BEGIN
    IF (@@fetch_status <> -2)
    BEGIN
        SELECT @tablename_header = "Updating " + 
            RTRIM(UPPER(@tablename))
        PRINT @tablename_header
        EXEC ("UPDATE STATISTICS " + @tablename )
  	  EXEC ("sp_recompile " + @tablename )

    END
    FETCH NEXT FROM tnames_cursor INTO @tablename
END
PRINT " "
PRINT " "
SELECT @tablename_header = "*************  NO MORE TABLES"
               + "  *************" 
PRINT @tablename_header
PRINT " "
PRINT "Statistics have been updated for all tables."
DEALLOCATE tnames_cursor

GO
GRANT EXECUTE ON  [dbo].[update_all_stats] TO [public]
GO
