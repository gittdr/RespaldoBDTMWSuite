SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[adjust_trcplan_order_sp] 
	@p_ord_hdrnumber	int,
	@p_lgh_number		int,
	@p_mpp_id		varchar(8),
	@p_ord_startdate	datetime

AS

/**
 * 
 * NAME:
 * adjust_trcplan_order_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Adjusts the mfh_number on the legheader table for the driver and startdate passed to the proc.
 * Each time the proc is called for a specific driver on a specific day, the proc will look at the
 * MAX mfh_sequence for that driver on that day, and increment it's next assigned leg by 10.
 * This keeps the drag & drop sequence on the planning worksheet in order.
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:
 * @p_ord_hdrnumber	int		Order number that has been planned and needs it's sequence updated
 * @p_lgh_number	int		Leg number that has been planned and needs it's sequence updated
 * @p_mpp_id		varchar(8)	Driver ID for which to adjust the mfh_sequence on it's legs 
 * 					for the specified day.
 * @p_ord_startdate	datetime	Day on which the mfh_sequence is to be adjusted for the
 *					specified driver.
 *
 * REVISION HISTORY:
 * 10/10/2005.01 ? PTS30119 - Dan Hudec ? Created Procedure
 * 11/30/2005.01 - PTS30763 - JJF - fix date issue
 *
 **/

DECLARE	@v_ord_startdate_today		datetime,
	@v_ord_startdate_tomorrow	datetime,
	@v_max_mfh_number		int,
	@v_new_mfh_number		int

CREATE TABLE #TEMP(
	lgh_driver1	varchar(8) null,
	lgh_startdate	datetime null,
	mfh_number	int null)

If @p_lgh_number = -1
 BEGIN
	select	@p_lgh_number = min(lgh_number)
	from 	legheader
	where 	ord_hdrnumber = @p_ord_hdrnumber
 END

--PTS 30763 JJF 11/30/05 - trims needed, otherwise single digit dates will not function
select 	@v_ord_startdate_today = str(datepart(yyyy, @p_ord_startdate),4) + 
		right('0' + ltrim(rtrim(str(datepart(mm, @p_ord_startdate), 2))), 2) + 
		right('0' + ltrim(rtrim(str(datepart(dd, @p_ord_startdate), 2))), 2)


select	@v_ord_startdate_tomorrow = dateadd(dd, 1, @v_ord_startdate_today)

INSERT INTO #TEMP
SELECT  lgh_driver1, 
	lgh_startdate, 
	IsNull(mfh_number, 0)
FROM 	legheader
WHERE	lgh_driver1 = @p_mpp_id AND
	lgh_startdate >= @v_ord_startdate_today AND
	lgh_startdate < @v_ord_startdate_tomorrow

IF (select count(*) from #TEMP) > 0
 BEGIN
	SELECT	@v_max_mfh_number = max(mfh_number)
	FROM	#TEMP
	
	IF @v_max_mfh_number = 0
		SELECT @v_new_mfh_number = 10
	ELSE
		SELECT @v_new_mfh_number = @v_max_mfh_number + 10

	UPDATE 	legheader
	SET	mfh_number = @v_new_mfh_number
	WHERE	lgh_number = @p_lgh_number

 END
ELSE
 BEGIN
	SELECT	@v_new_mfh_number = 10

	UPDATE 	legheader
	SET	mfh_number = @v_new_mfh_number
	WHERE	lgh_number = @p_lgh_number
 END

DROP TABLE #TEMP

GO
GRANT EXECUTE ON  [dbo].[adjust_trcplan_order_sp] TO [public]
GO
