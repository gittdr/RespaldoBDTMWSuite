SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_cvtGeoCoord]  -- Converts geo coordinate to decimal degrees
	@table varchar(15), -- terms of input value as TMWS/TM file: 'city', 'company', 'checkcall', 'tbllatlong'
	@value decimal(12,4),
	@outValue decimal(12,4) out
AS
BEGIN

DECLARE @units char(1),
	@ret decimal(12,4)

if @value is null 
begin
	set @outValue = @value
	return 
END	

SELECT @table=lower(@table), @ret=0

--Specifies whether the lat/long values in the city table are in seconds or decimal degrees.  
--If the gi_string1 field is "S" then the value is in seconds.  
--If it is "D" (the default) , then the value is in decimal degrees

IF @table = 'city' 
BEGIN
	SELECT @units=gi_string1 
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'CityLatLongUnits'
	IF @units='S'
		SELECT @ret = convert(decimal(12,4),@value/3600)
	ELSE
		SELECT @ret = convert(decimal(12,4),@value)
END
ELSE
BEGIN
	IF @table = 'company'
	BEGIN
		SELECT @units=gi_string1 
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'CompanyLatLongUnits'
		
		IF @units='S'
			SELECT @ret = convert(decimal(12,4),@value/3600)
		ELSE
			SELECT @ret = convert(decimal(12,4),@value)
	END
	ELSE
	BEGIN
		IF @table = 'checkcall' 
			SELECT @ret = convert(decimal(12,4),@value/3600)
		ELSE
		BEGIN
			IF @table = 'tbllatlong'
				SELECT @ret = convert(decimal(12,4),@value)
		END
	END
END

set @outValue = @ret

END

GO
GRANT EXECUTE ON  [dbo].[tm_cvtGeoCoord] TO [public]
GO
