SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_add_extra_info]
	@tableName varchar(50) = '',
	@tabName varchar(50) = '',
	@colName varchar(50) = '',
	@tableKey varchar(50) = '',
	@colData varchar(80) = '',
	@checkDups char(1) = 'N'

 AS 

 declare @extra_id int
 declare @tab_id int
 declare @col_id int
 declare @col_row int
 if len(rtrim(@tableKey)) = 0 return -1
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

 if upper(@checkDups) = 'Y'
  begin
   if (select count(*) from extra_info_data 
	where extra_id = @extra_id and tab_id = @tab_id and col_id = @col_id 
	and col_data = @colData and table_key = @tableKey) > 0
   return -6
  end

 select @col_row = isnull(max(col_row),0) from extra_info_data 
	where extra_id = @extra_id and tab_id = @tab_id 
	and col_id = @col_id and table_key = @tableKey

 select @col_row = @col_row + 1

 insert into extra_info_data(
  extra_id, tab_id, col_id, col_data, table_key, col_row)
 values (@extra_id, @tab_id, @col_id, @colData, @tableKey, @col_row)

 return 1

GO
GRANT EXECUTE ON  [dbo].[dx_add_extra_info] TO [public]
GO
