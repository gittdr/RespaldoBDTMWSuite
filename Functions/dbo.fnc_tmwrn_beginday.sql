SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[fnc_tmwrn_beginday] 
(@date datetime)
returns datetime 
as
begin
	return convert(datetime, convert(varchar,@date,10) + ' 00:00')
end 

GO
