SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_insert_all_ini_values_sp]
(
    @value_id int,
    @xref_file_section_item_id int,
    @xref_file_section_id int,
    @file_id int,
    @section_id int,
    @item_id int,
    @value varchar(255),
    @table_name varchar(255),
    @userid varchar(20),
    @userid_created_by varchar(20),
    @active varchar(1),
    @insert_type varchar(255)
)

as

/************************************************************************************
 NAME:		ini_insert_all_ini_values_sp
 DOS NAME:	tmwsp_ini_insert_all_ini_values_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   insert information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 SAMPLE EXECUTION: 
 exec ini_insert_all_ini_values_sp 0, 6, 6, 33, 673, 3820, "insert all test", "ini_values", "LLEHMANN", "LLEHMANN", "Y", ""
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-08-2002    LLEHMANN    Initial Creation
Jun-18-2002    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

begin transaction ini_new_table_settings

declare @cur_dt datetime,
        @numrows int,
        @error int,
        @min varchar(255),
        @max varchar(255)

--Load the variables
select @cur_dt = getdate()


--**************************
--***** VALUES  TABLE  *****
--**************************

--Delete any values for this user in the values table
delete ini_values
       from ini_values  v
            inner join ini_xref_file_section_item i
                on v.file_section_item_id = i.file_section_item_id
            inner join  ini_xref_file_section f
                on f.file_section_id = i.file_section_id
       where 
       i.item_id = @item_id
       and f.file_id = @file_id
       and f.section_id = @section_id


       select @error = @@error
       IF @error < 0
            BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
        END
        IF @error > 1
            BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
        END

--Find the file_section_id...if does not exist, insert it
    select @numrows = count(*) 
    from ini_xref_file_section x
         inner join ini_file i
            on x.file_id = i.file_id
         inner join ini_section s
            on s.section_id = x.section_id
    where 
    i.file_id = @file_id
    and s.section_id = @section_id

    IF @numrows = 0 
    -- no rows found... insert a row
    BEGIN
        INSERT INTO ini_xref_file_section
            (file_section_id,
             file_id, 
             section_id,
             created,
             created_by,
             active)
        values(@xref_file_section_id, 
               @file_id,
               @section_id,
               @cur_dt,
               @userid_created_by,
               @active)
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
        select @xref_file_section_id = x.file_section_id 
        from ini_xref_file_section x
             inner join ini_file i
                on x.file_id = i.file_id
             inner join ini_section s
                on s.section_id = x.section_id
        where 
        i.file_id = @file_id
        and s.section_id = @section_id

        select @error = @@error

        IF @error != 0
            BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
        END
    END


    --Find the file_section_item_id...if does not exist, insert it
    select @numrows = count(*) 
    from ini_xref_file_section_item x
    where
    x.file_section_id = @xref_file_section_id
    and x.item_id = @item_id
    
    IF @numrows = 0 
    -- no rows found... insert a row
    BEGIN
        INSERT INTO ini_xref_file_section_item
             (file_section_item_id,
              file_section_id,
              item_id,
              created,
              created_by,
              active)
        values(@xref_file_section_item_id, 
               @xref_file_section_id,
               @item_id,
               @cur_dt,
               @userid_created_by,
               @active)
    
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
            select @xref_file_section_item_id = x.file_section_item_id
            from ini_xref_file_section_item x 
            where
            x.file_section_id = @xref_file_section_id
            and x.item_id = @item_id    
        END
        select @error = @@error
        IF @error != 0
        BEGIN
            ROLLBACK TRANSACTION ini_new_table_settings
            select    @error
            return 1
        END

--  now have all id's loaded... load in ini_values table
select @min =  min(usr_userid) from ttsusers
select @max =  max(usr_userid) from ttsusers


WHILE @min <= @max
BEGIN
    EXECUTE @value_id = getsystemnumber 'INIV', ''
    INSERT INTO ini_values
         (value_id, 
          value_setting, 
          file_section_item_id,
          usr_userid,
          created,
          created_by,
          active)
    values(@value_id, 
           @value,
           @xref_file_section_item_id,
           @min,
           @cur_dt,
           @userid_created_by,
           @active)
    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_new_table_settings
        select    @error
        return 1
    END
    select @min =  min(usr_userid) 
    from ttsusers
    where usr_userid > @min
END

commit transaction ini_new_table_settings
SELECT @error
RETURN @error




GO
GRANT EXECUTE ON  [dbo].[ini_insert_all_ini_values_sp] TO [public]
GO
