SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[import_commodity_info] @cmd_code varchar(8), @cmd_name varchar(30) as
/* proc to check and add the commodity returns result set with CMD_code*/

if (select count(*)
	from commodity
	where cmd_code =@cmd_code) < 1
begin
	insert commodity (cmd_code,cmd_name,cmd_class,cmd_code_num)
	select @cmd_code, @cmd_name,'UNK', (select max(cmd_code_num) from commodity)+1
end

select @cmd_code

GO
GRANT EXECUTE ON  [dbo].[import_commodity_info] TO [public]
GO
