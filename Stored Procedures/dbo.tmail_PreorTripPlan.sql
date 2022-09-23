SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_PreorTripPlan] 
		@drv					AS VARCHAR(20), 
		@trc					AS VARCHAR(20),
		@lgh					AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tmail_PreorTripPlan
-- Author     :	From email authored by Lori Brickley to Dave Gudat on April 10, 2013
-- Create date: 2014.03.04
-- Description:
--      Returns all legs planned to @drv/@trc that start within +/- 10 hours from GETDATE().
--      
--      Outputs:
--      ------------------------------------------------------------------------
--
--      Input parameters:
--      ------------------------------------------------------------------------
--
-- =============================================================================
-- Modification Log:
-- PTS 74198 - VMS - 2014.03.04 - Adding this stored proc to my database
-- =============================================================================

--tmail_PreorTripPlan 'tfbbd','tfbbt','3579'
--select * from legheader where lgh_outstatus = 'dsp' and lgh_driver1 = 'tfbbd'

BEGIN
  
	SET NOCOUNT ON;

	DECLARE @STD int 
	DECLARE @LghStd int
	  
	select @STD = count(lgh_number)   
	from legheader (nolock)   
	where  lgh_driver1 = @drv  
	 AND lgh_tractor = @trc   
	 AND lgh_outstatus in ('STD','DSP')  
	 AND lgh_number <> @lgh
	 --AND lgh_startdate > DATEADD(hh, -20, GETDATE())  

	SELECT @LghStd = lgh_number
	from legheader (nolock)   
	where  lgh_driver1 = @drv  
	 AND lgh_tractor = @trc   
	 AND lgh_outstatus in ('STD','DSP')  
	 --AND lgh_number <> @lgh
	   
	IF @lghstd = @lgh
	BEGIN
		SELECT 'TripPlan'
	END
	ELSE
	BEGIN
	  
		IF @STD >=1
		BEGIN
			SELECT 'PrePlan'
		END
		ELSE
		BEGIN
			SELECT 'TripPlan'
		END
	END

END

GO
GRANT EXECUTE ON  [dbo].[tmail_PreorTripPlan] TO [public]
GO
