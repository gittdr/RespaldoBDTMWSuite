SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CompanyLatLongInALKFormat] @parmCompanyID varchar(25), --PTS 61189 change cmp_id fields to 25 length
@Flag varchar(12)

  --                                       123456789 123456789
  -- returns @sALKLatLong as varchar(20) = -99.9999X,-999.9999X
  -- @Flag is just here for future use, if there is any future.

as

SET NOCOUNT ON 

declare	@fLatSeconds float, 	@fLongSeconds float, 		@iFlag int,
    @sALKLatLong varchar(20),	@sLatDegrees varchar(8),	@sLongDegrees varchar(11),
    @fLatDegrees float,		@fLongDegrees float,		@sLatDirText char,
    @sLongDirText char,		@iDivisor int,			@sCompanyName varchar(100)

SET @iDivisor = CASE (SELECT gi_string1 
					  FROM generalinfo (NOLOCK) 
                      WHERE gi_name = 'CompanyLatLongUnits')
                 WHEN 'S' THEN 3600
		 ELSE 1
		 END

SELECT @sCompanyName = cmp_name , @fLatSeconds = cmp_latseconds, @fLongSeconds = cmp_longseconds
	FROM Company (NOLOCK)
	WHERE cmp_id = @parmCompanyID
IF ISNULL(@sCompanyName, 'UNKNOWN') = 'UNKNOWN'
	BEGIN
	RAISERROR ('Company ID (%s) not found', 16, 1, @parmCompanyID)
	RETURN 1
	END

IF (ISNULL(@fLatSeconds,0) = 0) OR (ISNULL(@fLongSeconds,0) = 0)
	BEGIN
	SELECT ''
	RETURN 0
	END

IF ISNULL(@fLatSeconds,0) < 0  -- Southern lattitude
	SET @sLatDirText = 'S'
ELSE  -- Northen lattitude
	SET @sLatDirText = 'N'

IF @fLongSeconds < 0 -- Eastern (really Western, but this is TMW...)
	SET @sLongDirText = 'E'
ELSE -- see if you can guess
	SET @sLongDirText = 'W'

SET @sLatDegrees = LTRIM(STR(@fLatSeconds/@iDivisor, 8, 4))
SET @sLongDegrees = LTRIM(STR(ABS(@fLongSeconds)/@iDivisor, 9, 4))

SELECT @sLatDegrees + @sLatDirText + ',' + @sLongDegrees + @sLongDirText

GO
GRANT EXECUTE ON  [dbo].[tm_CompanyLatLongInALKFormat] TO [public]
GO
