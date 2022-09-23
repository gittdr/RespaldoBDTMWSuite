SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/* sample calls:

exec tmw_dba_find_text 'drop table #', 'P'
exec tmw_dba_find_text '(index=', 'ALL'
exec tmw_dba_find_text '(index=', 'TR'
exec tmw_dba_find_text '(index=', 'P'
exec tmw_dba_find_text '(index =', 'P'
exec tmw_dba_find_text '(nolock)', 'P'
exec tmw_dba_find_text '(holdlock)', 'P'
exec tmw_dba_find_text 'st.stp_event, stp_mfh_sequence', 'P' 		--keyword split case
exec tmw_dba_find_text  'OR CHARINDEX('','' + legheader.trl_type4 + '',''', 'P' 	--keyword split case
*/

create   procedure [dbo].[tmw_dba_find_text](
 @text            VARCHAR(200),
 @objecttypelist  varchar(255) = 'ALL'

) AS
/**
 * 
 * NAME:
 * dbo.tmw_dba_find_text
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This proc finds text in single byte SQL Code and displays the line text.
 *
 * RETURNS:
 * None.
 *
 * RESULT SETS: 
 * objectname, objecttype, line
 *
 * PARAMETERS:
 * 001 - @text, varchar(200), keyword to search, input;
 * 002 - @objecttypelist, varchar(300), object type list, input;
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    - none
 * CalledBy001 - none
 * 
 * REVISION HISTORY:
 * 1/19/2006.01 - Mindy Curnutt, Keith Mader - Initial version
 * 1/19/2006.02 - Keith Mader -   
 * 		  Return results as a table, rather than print 
 * 		  statements.  Added argument to take in 
 *         	  object type (U, TR, P, etc...)   
 *         	  object type is a comma separted list   
 * 1/23/2006.01 - J.Guo - Expand 'select *' to be compliant with standard.   
 * 1/24/2006.01 - J.Guo - Fix line number problem. If the keyword is not found
 *                        in every syscomments row, then line number is not reliable.
 *                        Remove line number display.
 * 			- Fix keyword split line problem at 4000th character in syscomments row.
 *			- Add object type in the display list and make variable name generic.
 * 2/28/2006.01 - J.Guo - SQL 2000 version
 **/

begin

declare @results table (objectname varchar(128), objecttype char(2), line varchar(300))

set nocount on

 select @objecttypelist = ',' + @objecttypelist + ','

    -- Adjust search text to find all contains.
    SET @text = '%' + @text + '%'

    --  Declare general purpose variables.
    DECLARE @line    VARCHAR(300)
    DECLARE @char    CHAR
    DECLARE @counter INTEGER

    -- Declare cursor structure.
    DECLARE @objectname    VARCHAR(128),
	    @objecttype	   CHAR(2),
            @usage   VARCHAR(8000)

    --  Declare cursor of stored procedures.
    DECLARE codeCursor CURSOR
    FOR
    SELECT SUBSTRING(OBJECT_NAME(c.id),1,128) AS sproc, o.type, convert(varchar(4000), c.text) + CASE d.colid WHEN 1 THEN '' ELSE convert(varchar(4000), d.text) END
    FROM syscomments c, syscomments d, sysobjects o
    WHERE c.id = d.id  
	  and c.id = o.id 
          and ( (c.colid = d.colid - 1) or (c.colid = d.colid and d.colid=1) ) 
          and convert(varchar(4000), c.text) + CASE d.colid WHEN 1 THEN '' ELSE convert(varchar(4000), d.text) END LIKE @text 
          and  (@objecttypelist = ',ALL,' OR charindex(',' + rtrim(ltrim(o.type)) + ',', @objecttypelist) > 0)
/*
    DECLARE codeCursor CURSOR
    FOR
        SELECT  SUBSTRING(OBJECT_NAME(syscomments.id),1,50) AS sproc,
                text
        FROM    syscomments inner join sysobjects on syscomments.id = sysobjects.id
        WHERE   text LIKE @text AND
    (@objecttypelist = ',ALL,' OR charindex(',' + rtrim(ltrim(type)) + ',', @objecttypelist) > 0)
*/
    --  Open cursor and fetch first row. 
    OPEN codeCursor
    FETCH NEXT FROM codeCursor
        INTO @objectname, @objecttype, @usage

    --  Check if any stored procedures were found.
    IF @@FETCH_STATUS <> 0 BEGIN 
        PRINT 'Text ''' + SUBSTRING(@text,2,LEN(@text)-2) + ''' not found in objects on database ' + @@SERVERNAME + '.' + DB_NAME()

        -- Close and release code cursor.
        CLOSE codeCursor
        DEALLOCATE codeCursor
        RETURN
    END

    --  Search each stored procedure within code cursor.
    WHILE @@FETCH_STATUS = 0 BEGIN
        SET @counter = 1

        -- Process each line.
        WHILE (@counter <> LEN(@usage)) 
	BEGIN
            SET @char = SUBSTRING(@usage,@counter,1)

            --Check for line breaks.
            IF (@char = CHAR(13)) 
	    BEGIN
                -- Check if we found the specified text.
                IF (PATINDEX(@text,@line) <> 0) 
                    --PRINT @objectname + CHAR(9) + STR(@lineNo) + CHAR(9) + LTRIM(@line)    
     		insert into @results (objectname, objecttype, line) values (@objectname, @objecttype, @line)
            
                SET @line = ''
     	    END 
	    ELSE
         	IF (@char <> CHAR(10)) SET @line = @line + @char

                SET @counter = @counter + 1
        END
   
        FETCH NEXT FROM codeCursor
            INTO @objectname, @objecttype, @usage
    END

    --  Close and release cursor.
    CLOSE codeCursor
    DEALLOCATE codeCursor

    SELECT DISTINCT objectname, objecttype, line 
    FROM @results 
    ORDER BY objectname

    RETURN
END

GO
GRANT EXECUTE ON  [dbo].[tmw_dba_find_text] TO [public]
GO
