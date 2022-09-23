SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TM_CKC_UPDATEMileage] @chknum int

AS

SET NOCOUNT ON

DECLARE @truckid varchar(8),

        @exist_before int,
		@chk_before int,
		@lat_before float, 
		@long_before float,
		@chk_current int,
		@date_current datetime,
		@lat_current float,			
		@long_current float,
		@dist_current float,
		@exist_after int,
        @chk_after int,
		@lat_after float, 
		@long_after float,
		@dist_after float

SELECT @chk_current = ckc_number,
       @truckid = ckc_tractor,
       @date_current = ckc_date,
       @lat_current = (CONVERT(float, ckc_latseconds) / 3600.) * (PI() / 180.),
       @long_current = (CONVERT(float, ckc_longseconds) / 3600.) * (PI() / 180.)
FROM checkcall (NOLOCK)
WHERE ckc_number = @chknum

-- no such checkcall in the system
IF @@rowcount = 0 
	RETURN

SELECT TOP 1
	@chk_after = ckc_number,
	@lat_after = (CONVERT(float, ckc_latseconds) / 3600.) * (PI() / 180.),
	@long_after = (CONVERT(float, ckc_longseconds) / 3600.) * (PI() / 180.)
FROM checkcall (NOLOCK)
WHERE ckc_tractor = @truckid 
	and ckc_date > @date_current 
ORDER BY ckc_date desc

-- current checkcall is not out of sequence, mileage has been calculated by checkcall transfer routine
IF @@rowcount = 0 
	RETURN

SELECT TOP 1
	@chk_before = ckc_number,
	@lat_before = (CONVERT(float, ckc_latseconds) / 3600.) * (PI() / 180.),
	@long_before = (CONVERT(float, ckc_longseconds) / 3600.) * (PI() / 180.)
FROM checkcall (NOLOCK)
WHERE ckc_tractor = @truckid 
	and ckc_date < @date_current 
ORDER BY ckc_date DESC

-- calculate distance before-current and UPDATE "current" checkcall mileage
IF @@rowcount > 0
BEGIN
	SELECT @dist_current = COS(@lat_before) * COS(@lat_current) * COS(@long_before - @long_current) + SIN(@lat_before) * SIN(@lat_current)
	IF (@dist_current > 1)		
		SELECT @dist_current = 1
	
	SELECT @dist_current = 3956.5 * ACOS(@dist_current)

	UPDATE checkcall SET ckc_mileage = @dist_current WHERE ckc_number = @chk_current
END

-- calculate distance current-after and UPDATE "after" checkcall mileage
IF @@rowcount > 0
BEGIN
	SELECT @dist_after = COS(@lat_current) * COS(@lat_after) * COS(@long_current - @long_after) + SIN(@lat_current) * SIN(@lat_after)
	IF (@dist_after > 1)		
		SELECT @dist_after = 1
	
	SELECT @dist_after = 3956.5 * ACOS(@dist_after) 

	UPDATE checkcall SET ckc_mileage = @dist_after WHERE ckc_number = @chk_after
END

-- comment UPDATE's and uncomment the following to test
/*
SELECT ckc_number, ckc_cityname, ckc_mileage, null, ckc_latseconds, ckc_longseconds FROM checkcall WHERE ckc_number = @chk_before
union
SELECT ckc_number, ckc_cityname, ckc_mileage, convert(int,@dist_current), ckc_latseconds, ckc_longseconds FROM checkcall WHERE ckc_number = @chk_current
union
SELECT ckc_number, ckc_cityname, ckc_mileage, convert(int,@dist_after), ckc_latseconds, ckc_longseconds FROM checkcall WHERE ckc_number = @chk_after
*/
GO
GRANT EXECUTE ON  [dbo].[TM_CKC_UPDATEMileage] TO [public]
GO
