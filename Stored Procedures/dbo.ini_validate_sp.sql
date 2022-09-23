SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[ini_validate_sp]
as
declare @li_ret int

	Create table #temp
	(
		[file_name] varchar(255),
		section_name varchar(255),
		item_name varchar(255),
		value_setting varchar(1024)
	)

	insert into #temp
	select f.[file_name], 
	       g.section_name, 
	       e.item_name,
	       a.value_setting
	from ini_values a
	     inner join ini_xref_file_section_item c
	        on a.file_section_item_id = c.file_section_item_id
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_item e
	        on e.item_id = c.item_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
	where 
		a.group_level = 0

select @li_ret = 0

if exists (select * from #temp where section_name = 'ORDER')
	if exists (select * from #temp where section_name = 'DISPATCH')
		if exists (select * from #temp where section_name = 'INVOICE')
			if exists (select * from #temp where section_name = 'SETTLEMENT')
				select @li_ret = 1




return @li_ret 


GO
GRANT EXECUTE ON  [dbo].[ini_validate_sp] TO [public]
GO
