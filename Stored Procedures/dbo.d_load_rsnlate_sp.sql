SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_load_rsnlate_sp    Script Date: 6/1/99 11:54:15 AM ******/
create proc [dbo].[d_load_rsnlate_sp](@rsnlate varchar(8), @number int)
as

select @rsnlate = @rsnlate+'%'

if @number = 1 
	set rowcount 1 
 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

SELECT name, abbr, code 
FROM labelfile 
WHERE labeldefinition = "ReasonLate" and abbr LIKE @rsnlate 
order by abbr

set rowcount 0

GO
GRANT EXECUTE ON  [dbo].[d_load_rsnlate_sp] TO [public]
GO
