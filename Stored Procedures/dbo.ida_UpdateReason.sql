SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









create proc [dbo].[ida_UpdateReason]
	@Abbr varchar(6),
	@Code int,
	@Reason varchar(20),
	@fRetired as bit = 0
as

update labelfile
	set
	abbr = @Abbr,
	[name] = @Reason,
	retired = case when @fRetired = 1 then 'Y' else 'N' end
where
	code = @Code
	and
	labeldefinition='IDAReason'







GO
GRANT EXECUTE ON  [dbo].[ida_UpdateReason] TO [public]
GO
