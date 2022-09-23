SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_update_comments_sp]
(
		@file_id 	int,
		@section_id int,
		@item_id int,
		@comment  varchar(255),
		@table_name varchar(255),
		@file_section_id  int,
		@file_section_item_id  int,
		@userid 	char(20),
		@active 	char(1),
		@insert_type varchar(255)

)

as

/************************************************************************************
 NAME:		ini_update_comments_sp
 DOS NAME:	tmwsp_ini_update_comments_sp.SQL
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Update Section and Item comments for the INI_APPLICATION
 DEPENDANCIES:
 PROCESS:
 exec ini_update_comments_sp 33, 655, 3820, 'test', 'ini_section', 0, 0, 'LLEHMANN', 'Y', 'INSERT'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
2002-Jan-15    LLEHMANN    Initial Creation
2002-Jun-18    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/
begin transaction ini_update_comments

declare @cur_dt datetime,
        @numrows int,
        @error int

--Load the variables
select @cur_dt = getdate()

--SECTION TABLE
If UPPER(@table_name) = 'INI_SECTION'
Begin
  IF UPPER(@insert_type) = 'UPDATE'
  BEGIN
    update ini_xref_file_section
    set comment = @comment
    where file_section_id = @file_section_id

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_comments
        select    @error
        return 1
    END
  END
  IF UPPER(@insert_type) = 'INSERT'
  BEGIN
    EXECUTE @file_section_id = getsystemnumber 'INIFS', ''
    INSERT INTO ini_xref_file_section
           (file_section_id, 
           file_id, 
           section_id, 
           created, 
           created_by, 
           active, 
           comment)
    values(@file_section_id, 
           @file_id, 
           @section_id, 
           @cur_dt, 
           @userid, 
           @active, 
           @comment)
    select @error = @@error

    IF @error != 0
       BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
       END
  END
END


--ITEM TABLE
If UPPER(@table_name) = 'INI_ITEM'
Begin
  IF UPPER(@insert_type) = 'UPDATE'
  BEGIN
    update ini_xref_file_section_item
    set comment = @comment
    where file_section_item_id = @file_section_item_id

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_comments
        select    @error
        return 1
    END
  END
  IF UPPER(@insert_type) = 'INSERT'
  BEGIN
    --get a new file_section_item_id
    EXECUTE @file_section_item_id = getsystemnumber 'INIFSI', ''
    --Find the file_section_id...if does not exist, insert it
    select @numrows = count(*) 
    from ini_xref_file_section x
    where 
    x.file_id = @file_id
    and x.section_id = @section_id
    
    IF @numrows = 0 
    -- no rows found... insert a row
    BEGIN
        EXECUTE @file_section_id = getsystemnumber 'INIFS', ''
        INSERT INTO ini_xref_file_section
              (file_section_id, 
              file_id, 
              section_id, 
              created, 
              created_by, 
              active, 
              comment)
        values(@file_section_id, 
              @file_id, 
              @section_id, 
              @cur_dt, 
              @userid, 
              @active,
              '')
        select @error = @@error

        IF @error != 0
            BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
        END
    END
    IF @numrows > 0
    -- rows found so get the id
    BEGIN
        select @file_section_id = x.file_section_id 
        from ini_xref_file_section x
        where 
        x.file_id = @file_id
        and x.section_id = @section_id
    END
    
    --INSERT NEW VALUE INTO ini_xref_file_section_item
    INSERT INTO ini_xref_file_section_item
           (file_section_item_id, 
           file_section_id, 
           item_id,  
           created, 
           created_by, 
           active, 
           comment)
    values(@file_section_item_id, 
           @file_section_id,
           @item_id,
           @cur_dt,
           @userid,
           @active,
           @comment)

    select @error = @@error

    IF @error != 0
       BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
       END
  END
END

commit transaction ini_update_comments
GO
GRANT EXECUTE ON  [dbo].[ini_update_comments_sp] TO [public]
GO
