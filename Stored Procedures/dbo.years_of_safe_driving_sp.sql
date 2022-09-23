SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[years_of_safe_driving_sp]

AS

/**
 * 
 * NAME:
 * years_of_safe_driving_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Calculates and updates the mpp_yearsofsafedrive field in the manpowerprofile table representing 
 * the years of safe driving for a driver.  Done for every mpp_id in the manpowerprofile table.
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 3/22/2006.01 ? PTS30817 - Dan Hudec ? Created Procedure
 *
 **/

DECLARE @v_driver_counter	int,
	@v_max			int,
	@v_temp_mpp_id		varchar(8),
	@v_temp_mpp_drivedate	datetime,
	@v_temp_mpp_ysdasofdate	datetime,
	@v_yearsofsavedrive	int,
	@v_years_to_check 	int,
	@v_years_counter	int,
	@v_prvacc_count		int

CREATE TABLE #temp(
	id_col		int identity(1,1),
	mpp_id		varchar(8),
	mpp_drivedate 	datetime,
	mpp_ysdasofdate	datetime)

INSERT INTO #temp (mpp_id, mpp_drivedate, mpp_ysdasofdate)
SELECT	mpp_id, mpp_drivedate, mpp_ysdasofdate
FROM	manpowerprofile
WHERE	mpp_id not like 'UNK%'
  AND	(mpp_terminationdt > getdate() or mpp_terminationdt Is Null)

SELECT	@v_driver_counter = 1
SELECT	@v_max = max(id_col)
FROM	#TEMP

WHILE	@v_driver_counter <= @v_max
 BEGIN
	SELECT	@v_temp_mpp_id = mpp_id,
		@v_temp_mpp_drivedate = mpp_drivedate,
		@v_temp_mpp_ysdasofdate = mpp_ysdasofdate
	FROM 	#TEMP
	WHERE 	id_col = @v_driver_counter

	SELECT	@v_yearsofsavedrive = 0

	--Calculate how many years we need to look at, then loop through years
	SELECT 	@v_years_counter = 1

	If datepart(mm, @v_temp_mpp_drivedate) < 7
		Select @v_years_to_check = datediff(yyyy, @v_temp_mpp_drivedate, getdate())
	Else if datepart(mm, @v_temp_mpp_drivedate) = 7 and datepart(dd, @v_temp_mpp_drivedate) = 1
		Select @v_years_to_check = datediff(yyyy, @v_temp_mpp_drivedate, getdate())
	Else
		Select @v_years_to_check = datediff(yyyy, @v_temp_mpp_drivedate, getdate()) - 1
	
	--Calculate years of safe driving for @v_temp_mpp_id
	While @v_years_counter <= @v_years_to_check
	 BEGIN
		SELECT	@v_prvacc_count = count(a.acd_id)
		FROM	accident a, safetyreport s
		WHERE	a.acd_accidenttype2 = 'PRVACC'
		  AND	a.srp_id = s.srp_id
		  AND   a.acd_driver1 = @v_temp_mpp_id
 		  AND	datepart(yy, s.srp_eventdate) = datepart(yy, dateadd(yy, -(@v_years_counter), getdate()))

		IF @v_prvacc_count = 0
			SELECT @v_yearsofsavedrive = @v_yearsofsavedrive + 1
	
		SELECT	@v_years_counter = @v_years_counter + 1
	 END

	--Update years of safe driving and increment counter
	UPDATE	manpowerprofile
	SET	mpp_yearsofsafedrive = @v_yearsofsavedrive,
		mpp_ysdasofdate = getdate()
	WHERE	mpp_id = @v_temp_mpp_id

	SELECT	@v_driver_counter = @v_driver_counter + 1
 END

drop table #temp
	
GO
GRANT EXECUTE ON  [dbo].[years_of_safe_driving_sp] TO [public]
GO
