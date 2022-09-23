SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CaseView2] @sInputValue varchar(50),
								 @Min1 varchar(50),
								 @Max1 varchar(50),
								 @Result1 varchar(50),
								 @Min2 varchar(50),
								 @Max2 varchar(50),
								 @Result2 varchar(50),
								 @Min3 varchar(50),
								 @Max3 varchar(50),
								 @Result3 varchar(50),
								 @Min4 varchar(50),
								 @Max4 varchar(50),
								 @Result4 varchar(50),
								 @Min5 varchar(50),
								 @Max5 varchar(50),
								 @Result5 varchar(50),
								 @Min6 varchar(50),
								 @Max6 varchar(50),
								 @Result6 varchar(50),
								 @Min7 varchar(50),
								 @Max7 varchar(50),
								 @Result7 varchar(50),
								 @Min8 varchar(50),
								 @Max8 varchar(50),
								 @Result8 varchar(50),
								 @Min9 varchar(50),
								 @Max9 varchar(50),
								 @Result9 varchar(50),
								 @Min10 varchar(50),
								 @Max10 varchar(50),
								 @Result10 varchar(50),
								 @CompareStyle varchar(10)

AS
	-- 01/12/2007 LB PTS35801 - Added tm_CaseView3 with @Flags and @ElseResult as additional parameters
	-- 01/04/2005 DG Made shell to call CaseView2 (PTS 26345 created for this 1/4/2005 for checkin)
	-- 06/31/03 MZ Created 
	DECLARE @return int

	EXEC @return = dbo.tm_CaseView3 @sInputValue,
								 @Min1 , @Max1 , @Result1 ,
								 @Min2 , @Max2 , @Result2 ,
								 @Min3 , @Max3 , @Result3 ,
								 @Min4 , @Max4 , @Result4 ,
								 @Min5 , @Max5 , @Result5 ,
								 @Min6 , @Max6 , @Result6 ,
								 @Min7 , @Max7 , @Result7 ,
								 @Min8 , @Max8 , @Result8 ,
								 @Min9 , @Max9 , @Result9 ,
								 @Min10 , @Max10 , @Result10 ,
								 @CompareStyle,0,NULL

	RETURN @Return
GO
GRANT EXECUTE ON  [dbo].[tm_CaseView2] TO [public]
GO
