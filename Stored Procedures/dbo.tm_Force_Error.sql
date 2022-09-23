SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Force_Error] @ErrorDesc varchar(254), 
								@Severity varchar(10), 
								@State varchar(10), 
								@Arg1 varchar(50), 
								@Arg2 varchar(50),
								@Arg3 varchar(50),
								@Arg4 varchar(50),
								@Arg5 varchar(50),
								@Arg6 varchar(50),
								@Arg7 varchar(50),
								@Arg8 varchar(50),
								@Arg9 varchar(50),
								@Arg10 varchar(50),
								@Arg11 varchar(50),
								@Arg12 varchar(50),
								@Arg13 varchar(50),
								@Arg14 varchar(50),
								@Arg15 varchar(50),
								@Arg16 varchar(50),
								@Arg17 varchar(50),
								@Arg18 varchar(50),
								@Arg19 varchar(50),
								@Arg20 varchar(50)

AS

SET NOCOUNT ON

	DECLARE @iSeverity int, @iState int
	SELECT @ErrorDesc = ISNULL(@ErrorDesc, 'Unknown')
	if isnull(@severity, '') = ''
		SELECT @iSeverity = 16
	else
		SELECT @iSeverity = CONVERT(INT, ISNULL(@Severity, '16'))

	if isnull(@iState, '') = ''
		SELECT @iState = 1
	else
		SELECT @iState = CONVERT(INT, ISNULL(@State, '1'))
	
	RAISERROR (	@ErrorDesc, 
				@iSeverity, 
				@iState, 
				@Arg1, 
				@Arg2, 
				@Arg3, 
				@Arg4, 
				@Arg5, 
				@Arg6, 
				@Arg7, 
				@Arg8, 
				@Arg9, 
				@Arg10, 
				@Arg11, 
				@Arg12, 
				@Arg13, 
				@Arg14, 
				@Arg15, 
				@Arg16, 
				@Arg17, 
				@Arg18, 
				@Arg19, 
				@Arg20) 

GO
GRANT EXECUTE ON  [dbo].[tm_Force_Error] TO [public]
GO
