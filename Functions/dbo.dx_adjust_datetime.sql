SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[dx_adjust_datetime]
	(@origdate datetime,
	 @minutestoadd int)
returns datetime
 as
begin
	declare @newdate datetime
	select @newdate = @origdate

	if @origdate is not null
		if @origdate <> convert(datetime, '1950-1-1') and @origdate < convert(datetime, '2049-12-31 23:59')
			select @newdate = dateadd(mi, @minutestoadd, @origdate)

	return @newdate
end
GO
GRANT EXECUTE ON  [dbo].[dx_adjust_datetime] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_adjust_datetime] TO [public]
GO
