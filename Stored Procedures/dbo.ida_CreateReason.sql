SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









create proc [dbo].[ida_CreateReason]
	@Abbr varchar(6),
	@Reason varchar(20)
as

declare @Code int

select @Code=isnull(max(code)+10, 10) from labelfile (NOLOCK) where labeldefinition='IDAReason'

insert into labelfile
(
	labeldefinition,
	abbr,
	code,
	[name],
	retired
)
values
(
	'IDAReason',
	@Abbr,
	@Code,
	@Reason,
	'N'
)






GO
GRANT EXECUTE ON  [dbo].[ida_CreateReason] TO [public]
GO
