SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_get_key_from_extra_info]
	@tableName varchar(50) = '',
	@tabName varchar(50) = '',
	@colName varchar(50) = '',
	@colData varchar(80) = '',
	@@tableKey varchar(50) output

 AS 

 declare @extra_id int
 declare @tab_id int
 declare @col_id int

 if len(rtrim(@tableName)) = 0 return -2
 select @extra_id = extra_id from extra_info_header where table_name = @tableName
 if @extra_id is null return -2
 if len(rtrim(@tabName)) = 0 return -3
 select @tab_id = tab_id from extra_info_tab where extra_id = @extra_id and tab_name = @tabName
 if @tab_id is null return -3
 if len(rtrim(@colName)) = 0 return -4
 select @col_id = col_id from extra_info_cols where extra_id = @extra_id and tab_id = @tab_id and col_name = @colName
 if @col_id is null return -4
 if len(rtrim(@colData)) = 0 return -5

 if (select count(*) from extra_info_data where extra_id = @extra_id 
	and tab_id = @tab_id and col_id = @col_id and col_data = @colData) = 0
  return -1

 select @@tableKey = Min(table_key) from extra_info_data where extra_id = @extra_id
	and tab_id = @tab_id and col_id = @col_id and col_data = @colData

 return 1

GO
GRANT EXECUTE ON  [dbo].[dx_get_key_from_extra_info] TO [public]
GO
