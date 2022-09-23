SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[ida_UpdateEval]
	@idIDAEval int,
	@iOrder int,
	@iDisplayOrder int,
	@fEnabled bit,
	@sEvalName varchar(200),
	@sCategory varchar(200)
as

update ida_IDAEval
	set
	iOrder = @iOrder,
	iDisplayOrder = @iDisplayOrder,
	fEnabled = @fEnabled,
	sEvalName = @sEvalName,
	sCategory = @sCategory
where idIDAEval=@idIDAEval

GO
GRANT EXECUTE ON  [dbo].[ida_UpdateEval] TO [public]
GO
