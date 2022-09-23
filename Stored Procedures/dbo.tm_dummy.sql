SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_dummy]   @parm1 varchar(80),
				@parm2 varchar(80),
				@parm3 varchar(80),
				@parm4 varchar(80),
				@parm5 varchar(80),
				@parm6 varchar(80),
				@parm7 varchar(80),
				@parm8 varchar(80),
				@parm9 varchar(80),
				@parm10 varchar(80)
as


select 1

GO
GRANT EXECUTE ON  [dbo].[tm_dummy] TO [public]
GO
