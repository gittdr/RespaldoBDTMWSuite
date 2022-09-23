SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[udf_concat_cols] (@table_name varchar(100))
RETURNS varchar(400) as BEGIN
DECLARE @s varchar(400)
set @s = ''
select @s = @s + column_name + ', ' 
from primary_keys
where table_name = @table_name
order by key_ordinal
RETURN @s
END
GO
