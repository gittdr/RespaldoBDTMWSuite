SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[add_new_setting_sp] (@ps_sectionname varchar(255), @ps_setting varchar(255), @ps_value varchar(255),@ps_description varchar(6000)) as
-- PROCEDURE adds new 'ini' settings to the db. Created by: Jude Date:4/25/08

declare @file_id int,@section_id int , @item_id int, @value_id int,@file_section_id int , @file_section_item_id int
declare @li_newsection int 

select @file_id= file_id from ini_file where file_name = 'TTS50.INI'

if not exists (select * from ini_master_tmw where ini_filename = 'TTS50.INI' and ini_section = @ps_sectionname and ini_item = @ps_setting)
	insert into ini_master_tmw (ini_filename,ini_section,ini_item,ini_value,ini_description)
	values('TTS50.INI',@ps_sectionname,@ps_setting,@ps_value,@ps_description)


If @file_id is null 
Begin
	select 'Setting will only be added to the master settings list.'
	Return -1
End

if exists (select * from ini_values where group_level is null) 
Begin
	select '[Warning],Using Trimac config.... Setting will only be added to the master settings list and NOT to the ini_* tables.'
	Return 0
End


select @li_newsection = 0
select @section_id = ini_xref_file_section.section_id from ini_section inner join ini_xref_file_section  
		on ini_section.section_id  = ini_xref_file_section.section_id 
		Where   ini_xref_file_section.file_id = @file_id and ini_section.section_name = @ps_sectionname
If @section_id is null
Begin
	exec @section_id =  getsystemnumber 'INIS',''
	exec @item_id = getsystemnumber 'INIV',''
	select @li_newsection  = 1
End
Else
Begin
--	select @item_id = ini_xref_file_section_item.item_id from ini_item inner join ini_xref_file_section_item  
	--		on ini_item.item_id  = ini_xref_file_section_item.item_id 
		--	Where  ini_xref_file_section_item.file_section_id = @section_id and  ini_item.item_name = @ps_setting



	select @item_id = e.item_id
	from ini_item e
	     inner join ini_xref_file_section_item c
	        on e.item_id = c.item_id
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
		where 
			f.file_id = @file_id and 
			g.section_name = @ps_sectionname and 
			e.item_name = @ps_setting

--	select * from ini_xref_file_section_item
--	select * from ini_item
--	select * from ini_xref_file_section
	If @item_id is null
		exec @item_id =  getsystemnumber 'INII',''
	else -- Setting already exists do not recreate
		Return 0
End
--select * from ini_xref_file_section_item

exec @value_id = getsystemnumber 'INIV',''

exec @file_section_item_id = getsystemnumber 'INIFSI',''


if IsNull(@section_id ,0) <= 0 
Begin
	select 'Error,Section ID could not be determined'
	Return -1
end 

if IsNull(@item_id ,0) <= 0 
Begin
	select 'Error,Section ID could not be determined'
	Return -1
end 

BEGIN TRAN
if @li_newsection = 1 
Begin
	exec @file_section_id = getsystemnumber 'INIFS',''
	insert into ini_section (section_id, section_name,created,created_by,active) values (@section_id, @ps_sectionname, getdate(), 'DBO','Y')
	if @@error <> 0 
	Begin
		Rollback
		select 'Error insert ini_section'
		Return
	end


--	select 'here'	
	insert into ini_xref_file_section (file_section_id, file_id, section_id, created,created_by,active) values (@file_section_id, @file_id, @section_id, getdate(), 'DBO','Y')	

	if @@error <> 0 
	Begin
		Rollback
		select 'Error insert ini_xref_file_section'
		Return
	end
--	select * from ini_xref_file_section where section_id = @section_id
End
Else
Begin

	select @file_section_id = d.file_section_id
	from ini_xref_file_section  d
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
		where 
			f.file_id = @file_id and 
			g.section_name = @ps_sectionname 


End

insert into ini_item (item_id, item_name,created,created_by,active) values (@item_id,@ps_setting,getdate(),'DBO','Y')
if @@error <> 0 
Begin
	Rollback
	select 'Error insert ini_item'
	Return
end

insert into ini_xref_file_section_item (file_section_item_id,file_section_id,item_id,created,created_by,active) values (@file_section_item_id,@file_section_id,@item_id,getdate(),'DBO','Y' )
if @@error <> 0 
Begin
	Rollback
	select 'Error insert ini_xref_file_section_item',@file_section_item_id,@section_id,@item_id
	Return
end

insert into ini_values (value_id, file_section_item_id,usr_userid, created, created_by,active,value_setting,group_level) values(@value_id,@file_section_item_id,'UNK',getdate(),'DBO','Y',@ps_value,0 )
if @@error <> 0 
Begin
	Rollback
	select 'Error insert ini_values'
	Return
end

commit
--	select * from ini_xref_file_section
select 'Setting: [' + @ps_sectionname +']-' + @ps_setting + ' has been added to the company wide settings list.'

GO
GRANT EXECUTE ON  [dbo].[add_new_setting_sp] TO [public]
GO
