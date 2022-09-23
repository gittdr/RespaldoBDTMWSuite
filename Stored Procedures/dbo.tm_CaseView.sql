SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CaseView] @sInputValue varchar(12),
								 @Min1 varchar(12),
								 @Max1 varchar(12),
								 @Result1 varchar(12),
								 @Min2 varchar(12),
								 @Max2 varchar(12),
								 @Result2 varchar(12),
								 @Min3 varchar(12),
								 @Max3 varchar(12),
								 @Result3 varchar(12),
								 @Min4 varchar(12),
								 @Max4 varchar(12),
								 @Result4 varchar(12),
								 @Min5 varchar(12),
								 @Max5 varchar(12),
								 @Result5 varchar(12),
								 @Min6 varchar(12),
								 @Max6 varchar(12),
								 @Result6 varchar(12),
								 @Min7 varchar(12),
								 @Max7 varchar(12),
								 @Result7 varchar(12),
								 @Min8 varchar(12),
								 @Max8 varchar(12),
								 @Result8 varchar(12),
								 @Min9 varchar(12),
								 @Max9 varchar(12),
								 @Result9 varchar(12),
								 @Min10 varchar(12),
								 @Max10 varchar(12),
								 @Result10 varchar(12)

AS
	-- 01/04/2005 DG Made shell to call CaseView2 (PTS 26345 created for this 1/4/2005 for checkin)
	-- 06/31/03 MZ Created 
	DECLARE @return int

	EXEC @return = dbo.tm_CaseView2 @sInputValue,
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
								NULL

	RETURN @Return
GO
GRANT EXECUTE ON  [dbo].[tm_CaseView] TO [public]
GO
