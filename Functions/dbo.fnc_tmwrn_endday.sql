SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[fnc_tmwrn_endday] 
(@date datetime)
returns datetime 
as
begin
	return convert(datetime, convert(varchar,@date,10) + ' 23:59:59')

end 
GO
