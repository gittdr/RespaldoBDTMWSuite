SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_dispatch_multiplan]
	@ordernumber varchar(12),
	@movenumber varchar(12),
	@tractornumber varchar(13)

AS

SET NOCOUNT ON 

DECLARE @ordhdr int,
	@move int,
	@lgh int,
	@driver varchar(8),
	@status varchar(12)

/* for testing 
DECLARE 	@ordernumber varchar(12),
	@movenumber varchar(12),
	@tractornumber varchar(13)
--SET @move = 47101 
SET @tractornumber = '105006' 
set @ordernumber = 29853 */

SELECT @move = CONVERT (int, @movenumber)

IF @move <= 0 OR @move IS NULL 
  BEGIN
	SELECT @ordhdr = ord_hdrnumber
	FROM orderheader (NOLOCK)
	WHERE ord_number = @ordernumber

	SELECT @move = MIN ( mov_number )
	FROM stops (NOLOCK)
	WHERE ord_hdrnumber = @ordhdr
  END

-- Get the legheader and driver for the leg we're accepting
SELECT @lgh = ppa_lgh_number
FROM preplan_assets (NOLOCK)
WHERE ppa_tractor = @tractornumber
  AND ppa_mov_number = @move
  AND ppa_status = 'Active'

-- Validation 
SET @status = 'NOT ASSIGNED'
SELECT @status = ISNULL(ppa_status,'NOT ASSIGNED')
FROM preplan_assets (NOLOCK)
WHERE ppa_mov_number = @move
		AND ppa_tractor = @tractornumber
		AND ppa_createdon = (SELECT MAX(ppa_createdon)
					FROM preplan_assets (NOLOCK)
					WHERE ppa_mov_number = @move
						AND ppa_tractor = @tractornumber)

IF UPPER(@status) = 'NOT ASSIGNED'
  BEGIN
	SELECT @status
	RETURN
  END
ELSE IF UPPER(@status) = 'MISSED'
  BEGIN
	SELECT @status
	RETURN
  END
ELSE IF UPPER(@status) = 'NO RESPONSE'
  BEGIN
	SELECT @status
	RETURN
  END
ELSE IF UPPER(@status) = 'REFUSED'
  BEGIN
	SELECT @status
	RETURN
  END
ELSE IF UPPER(@status) = 'ACCEPTED'
  BEGIN
	SELECT @status
	RETURN
  END
ELSE
  BEGIN
	-- Update the status for the tractor that accepted
	UPDATE preplan_assets
	SET ppa_status = 'TmHold'
	WHERE  ppa_mov_number = @move
	  AND ppa_status = 'Active'

	UPDATE preplan_assets
	SET ppa_status = 'Accepted'
	WHERE  ppa_mov_number = @move
	  AND ppa_tractor = @tractornumber
	  AND ppa_status = 'TmHold'
	
	-- Update the status for all of the other tractors on the order
	UPDATE preplan_assets
	SET ppa_status = 'Missed'
	WHERE  ppa_mov_number = @move
	  AND ppa_status = 'TmHold'	

	SELECT 'SUCCESS' 
  END
GO
GRANT EXECUTE ON  [dbo].[tmail_dispatch_multiplan] TO [public]
GO
