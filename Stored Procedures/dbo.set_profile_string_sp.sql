SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[set_profile_string_sp] (
@filename varchar(255), 
@section varchar(255), 
@field varchar(255),
@value  varchar(255),
@userid varchar(20)
)
as
/************************************************************************************
 NAME:		dbo.set_profile_string_sp
 DOS NAME:	tmwsp_set_profile_string_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:
 DEPENDANCIES:
 PROCESS:
 ---------------------------------------------------------------------------

REVISION LOG

DATE			WHO				REASON
----			---				------
2000-10-26      Neil Niu        Initial creation.
4-Feb-2002      Tannis Drysdale Using the new table format, update the value for the
                                user.  Delete then insert method of updating.  
                                Modified the length of the parameters
18-Jun-2002     Tannis Drysdale Grant access to tt_db_tmw_update_role instead of public

exec set_profile_string_sp 'TTS50.INI', 'TEST', 'TESTSET', 'TestSetProfile', 'KDECELLE'
*************************************************************************************/

declare     @file_id                int,
            @section_id             int,
            @file_section_id        int,
            @item_id                int,
            @file_section_item_id   int,
            @value_id               int,
            @row_count              int


if not exists (select * from ini_values where group_level is null) -- 42255 for non trim users we are only supporting the global settings
	return

/* Check if file exists */
select @row_count = count(*)
from ini_file
where upper(file_name) = upper(@filename)

if @row_count > 0 
  /* file exists */
  begin
    select @file_id = file_id
    from ini_file
    where upper(file_name) = upper(@filename)
  end
else
  begin
    /* file doesn't exist */
    exec @file_id =  getsystemnumber 'INIF', ''

    if isnull(@file_id,0)=0 or (@file_id <= 0)
        return -1

    INSERT INTO ini_file
    (file_id, file_name, created, created_by, active)
    select @file_id, upper(@filename), getdate(), user, 'Y'
  end

/* check if section exists */
select @row_count = count(*)
from ini_section
where upper(section_name) = upper(@section)

if @row_count > 0
  begin
   /* Section exists */
   select @section_id = section_id
   from ini_section
   where upper(section_name) = upper(@section)
 end
else
  /* Section doesn't exist */
  begin
    exec @section_id = getsystemnumber 'INIS', ''
    if isnull(@section_id,0)=0 or (@section_id <= 0)
       return -1
    INSERT INTO ini_section
    (section_id, section_name, created, created_by, active)
    select @section_id, upper(@section), getdate(), user, 'Y'
  end

/* Check for file/section cross reference */
select @row_count = count(*)
from ini_xref_file_section
where section_id = @section_id
and file_id = @file_id

if @row_count > 0 
  /* cross reference exists */
  select @file_section_id = file_section_id
  from ini_xref_file_section
  where section_id = @section_id
  and file_id = @file_id
else
  begin
    exec @file_section_id = getsystemnumber 'INIFS', ''
    if isnull(@file_section_id,0)=0 or (@file_section_id <= 0)
       return -1

    INSERT INTO ini_xref_file_section
    (file_section_id, file_id, section_id, created, created_by, active)
     select @file_section_id, @file_id, @section_id, getdate(), user, 'Y'
 end
 
/* Check to see if item exists */
select @row_count = count(*)
from ini_item
where upper(item_name) = upper(@field)

if @row_count > 0 
   select @item_id = item_id
   from ini_item
   where upper(item_name) = upper(@field)
else
  begin
    exec @item_id = getsystemnumber 'INII', ''
    if isnull(@item_id,0)=0 or (@item_id <= 0)
       return -1
    INSERT INTO ini_item
    (item_id, item_name, created, created_by, active)
     select @item_id, upper(@field), getdate(), user, 'Y'
  end 

/* Check for file/section/item cross reference */
select @row_count = count(*)
from ini_xref_file_section_item
where file_section_id = @file_section_id
and item_id = @item_id

if @row_count > 0
  begin
    select @file_section_item_id = file_section_item_id
    from ini_xref_file_section_item
    where file_section_id = @file_section_id
    and item_id = @item_id
  end
else
  begin
    exec @file_section_item_id = getsystemnumber 'INIFSI', ''

    if isnull(@file_section_item_id,0)=0 or (@file_section_item_id <= 0)
      return -1

    INSERT INTO ini_xref_file_section_item
    (file_section_item_id, file_section_id, item_id, created, created_by, active)
    select @file_section_item_id, @file_section_id, @item_id, getdate(), user, 'Y'
  end


/* Insert into the values table */
exec @value_id = getsystemnumber 'INIV', ''

if isnull(@value_id,0)=0 or (@value_id <= 0)
   return -1


if @file_id > 0 and @section_id > 0 and @file_section_id > 0
   and @item_id > 0 and @file_section_item_id > 0 and @value_id > 0
   begin

      delete from ini_values
      where file_section_item_id = @file_section_item_id
      and upper(usr_userid) = upper(@userid)
 
      INSERT INTO ini_values
      (value_id, value_setting, file_section_item_id, usr_userid, created, created_by, active)
      select @value_id, @value, @file_section_item_id, upper(@userid), getdate(), user, 'Y'
   end
GO
GRANT EXECUTE ON  [dbo].[set_profile_string_sp] TO [public]
GO
