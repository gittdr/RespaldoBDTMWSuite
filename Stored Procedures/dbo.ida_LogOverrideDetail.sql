SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






create proc [dbo].[ida_LogOverrideDetail]
	@idOverride integer,
	@PowerId varchar(50),
	@rank integer,
	@sCategory varchar(50),
	@sConstituent varchar(50),
	@curValue decimal,
	@ValueError varchar(200)
as

insert ida_OverrideDetail
(
	idOverride,
	PowerId,
	rank,
	sCategory,
	sComponentName,
	curValue,
	ValueError
)
values
(
	@idOverride,
	@PowerId,
	@rank,
	@sCategory,
	@sConstituent,
	@curValue,
	@ValueError
)

select SCOPE_IDENTITY()





GO
GRANT EXECUTE ON  [dbo].[ida_LogOverrideDetail] TO [public]
GO
