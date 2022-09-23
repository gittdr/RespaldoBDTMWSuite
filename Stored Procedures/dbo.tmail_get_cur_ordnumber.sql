SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 08/10/00 MZ:  
   05/24/01 DAG: Converting for international date format */

CREATE PROCEDURE [dbo].[tmail_get_cur_ordnumber]    @tractor varchar(8),
												@msgdate datetime

AS

SET NOCOUNT ON 

DECLARE @lgh_date datetime,
	@lgh_number int,
	@ord int	-- Returns ordernumber or -1 for failure

-- Pre-check arguments
IF ISNULL(@tractor,'') = ''
  BEGIN
	SELECT @ord = -1
	GOTO SP_EXIT
  END

IF ISNULL(@msgdate,'19500101') = '19500101'
  BEGIN
	SELECT @ord = -1
	GOTO SP_EXIT
  END

SELECT @lgh_date = ISNULL(MAX(lgh_startdate), '19500101') 
FROM legheader (NOLOCK) 
WHERE lgh_startdate <= @msgdate
	AND lgh_enddate >= @msgdate
	AND lgh_tractor = @tractor
	AND lgh_outstatus IN ('STD', 'CMP')
	
IF @lgh_date = '19500101'
	SELECT @lgh_date = ISNULL(MAX(lgh_startdate), '19500101') 
	FROM legheader (NOLOCK) 
	WHERE lgh_startdate <= @msgdate
		AND lgh_tractor = @tractor
		AND lgh_outstatus IN ('STD', 'CMP')
								
IF @lgh_date <> '19500101'
  BEGIN
	SELECT @lgh_number = MAX(lgh_number)
	FROM legheader (NOLOCK)
	WHERE lgh_tractor = @tractor
		AND lgh_startdate = @lgh_date
		AND lgh_outstatus IN ('STD', 'CMP')

	IF (ISNULL(@lgh_number,0) <> 0)
	  BEGIN
		SELECT @ord = 0

		SELECT @ord = ISNULL(ord_hdrnumber, -1)
		FROM legheader (NOLOCK)
		WHERE lgh_number = @lgh_number

		IF @ord = -1
			SELECT @ord = MIN(stops.ord_hdrnumber) 
			FROM stops (NOLOCK), legheader (NOLOCK)
			WHERE stops.mov_number = legheader.mov_number
				AND legheader.lgh_number = @lgh_number
				AND ISNULL(stops.ord_hdrnumber, 0) <> 0
	  END
  END
ELSE
	-- Couldn't find a current legheader for this tractor/datetime
	SELECT @ord = -1

SP_EXIT:
	RETURN @ord
GO
GRANT EXECUTE ON  [dbo].[tmail_get_cur_ordnumber] TO [public]
GO
