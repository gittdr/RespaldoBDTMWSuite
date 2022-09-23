SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	CREATE FUNCTION [dbo].[tmwf_scroll_assignments_concat] (@mov_number int)
	RETURNS varchar(5000)
	AS
	BEGIN


		declare @ls_tripdesc varchar(5000)
		set @ls_tripdesc = ''

		select @ls_tripdesc = @ls_tripdesc + '/' + rtrim(ord_number)
		from orderheader where mov_number = @mov_number and ord_number is not null
		order by ord_number

		Return @ls_tripdesc
	END
GO
GRANT EXECUTE ON  [dbo].[tmwf_scroll_assignments_concat] TO [public]
GO
