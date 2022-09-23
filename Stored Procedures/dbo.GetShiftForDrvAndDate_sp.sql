SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[GetShiftForDrvAndDate_sp]	
			@p_mpp_id		varchar(8),
			@p_startdate	datetime,
			@p_ss_id		int	OUTPUT

AS

BEGIN 

DECLARE	@v_prior_buffer_date	datetime,
		@v_after_buffer_date	datetime,
		@v_lgh_number			int,
		@v_asgn_status			varchar(6),
		@v_ord_status			varchar(6),
		@v_asgn_date			datetime

SELECT	@v_prior_buffer_date = DateAdd(day, -1, @p_startdate)
SELECT	@v_after_buffer_date = DateAdd(day, 2, @p_startdate)
SET		@v_lgh_number = -1

--If it's started, check order status to make sure it's not CMP.  If so, then get the next days shift
SELECT	@v_lgh_number = lgh_number,
		@v_asgn_status = asgn_status,
		@v_asgn_date = asgn_date
FROM	assetassignment
WHERE	asgn_id = @p_mpp_id
AND		asgn_type = 'DRV'
AND		asgn_status <> 'CMP'
AND		asgn_date = (SELECT min(asgn_date)
					 FROM	assetassignment
					 WHERE  asgn_id = @p_mpp_id 
					 AND	asgn_type = 'DRV' /*PTS #41182 - FIX PERFORMANCE*/
					 AND	asgn_status <> 'CMP'
					 AND    asgn_date > @v_prior_buffer_date)
					 AND	asgn_date < @v_after_buffer_date

select	@v_ord_status = ord_status
from	orderheader
where	mov_number = (select mov_number from legheader where lgh_number = @v_lgh_number)

IF @v_asgn_status = 'STD' and @v_ord_status = 'CMP'
 BEGIN
	SET @v_lgh_number = -1

	--Need to get the next shift
	SELECT	@v_lgh_number = lgh_number,
		@v_asgn_status = asgn_status,
		@v_asgn_date = asgn_date
		FROM	assetassignment
		WHERE	asgn_id = @p_mpp_id
			AND		asgn_type = 'DRV'
			AND		asgn_status <> 'CMP'
			AND		asgn_date = (SELECT min(asgn_date)
								 FROM	assetassignment
								 WHERE  asgn_id = @p_mpp_id 
								   AND	asgn_status <> 'CMP' 
								   And	asgn_type = 'DRV' /*PTS #41182 - FIX PERFORMANCE*/
								   AND	asgn_date > @v_asgn_date)
								   AND	asgn_date < @v_after_buffer_date
 END

IF (@v_lgh_number = -1) 
  BEGIN
	-- Was no shift in our date range with PLN/STD legs.  
	-- Just check if there is a shiftschedule record for today
	SET @p_ss_id = -1

	SELECT  @p_ss_id = ISNULL(ss_id, -1)
	FROM shiftschedules 
	WHERE Convert(varchar,ss_date,1) = Convert(varchar,@p_startdate,1) 
		AND mpp_id = @p_mpp_id
		AND ss_shiftstatus = 'ON'
  END
ELSE
  BEGIN
	SELECT	@p_ss_id = IsNull(shift_ss_id, -1)
	FROM	legheader
	WHERE	lgh_number = @v_lgh_number
  END
END
GO
GRANT EXECUTE ON  [dbo].[GetShiftForDrvAndDate_sp] TO [public]
GO
