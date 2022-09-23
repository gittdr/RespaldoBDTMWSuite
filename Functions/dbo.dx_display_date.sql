SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[dx_display_date](@flatdate char(12))
returns varchar(20)
as
begin
	if rtrim(isnull(@flatdate,'')) = ''
		return ''
	declare @displaydate datetime, @displaytext varchar(20)
	select @displaydate = 0
	if isnumeric(substring(@flatdate, 1, 8)) = 1
	begin
		select @displaydate = dateadd(yy, convert(int, substring(@flatdate, 1, 4)) - 1900, @displaydate)
		if isnumeric(substring(@flatdate, 5, 2)) = 1
			select @displaydate = dateadd(mm, convert(int, substring(@flatdate, 5, 2)) - 1, @displaydate)
		if isnumeric(substring(@flatdate, 7, 2)) = 1
			select @displaydate = dateadd(dd, convert(int, substring(@flatdate, 7, 2)) - 1, @displaydate)
		select @displaytext = convert(varchar, @displaydate, 101)
		if isnumeric(substring(@flatdate, 9, 4)) = 1
		begin
			if isnumeric(substring(@flatdate, 9, 2)) = 1
				select @displaydate = dateadd(hh, convert(int, substring(@flatdate, 9, 2)), @displaydate)
			if isnumeric(substring(@flatdate, 11, 2)) = 1
				select @displaydate = dateadd(mi, convert(int, substring(@flatdate, 11, 2)), @displaydate)
			select @displaytext = @displaytext + ' ' + ltrim(right(convert(varchar, @displaydate, 0), 7))
		end
	end
	else
		select @displaytext = '"' + rtrim(@flatdate) + '"'
	return @displaytext
end


GO
GRANT EXECUTE ON  [dbo].[dx_display_date] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_display_date] TO [public]
GO
