SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 10/29/01 MZ Created to fix ckc_lghnumber on the checkcall table */
CREATE PROCEDURE [dbo].[tmail_checkcall_lgh_fix] @NbrDaysToFix int,
											 @EndDateToFix datetime
AS

SET NOCOUNT ON 

/* For testing 
DECLARE @NbrDaysToFix int,
		@EndDateToFix datetime
SET @NbrDaysToFix = 2
SET @EndDateToFix = '20011006' */

DECLARE @StartDate datetime,
		@EndDate datetime

IF ISNULL(@EndDateToFix, '19510101') = '19510101'	
  BEGIN
	-- This is running nightly as a scheduled job, so just uses GETDATE()
	SET @StartDate = DATEADD(dd, -@NbrDaysToFix, GETDATE())
	SET @EndDate = GETDATE()
  END	
ELSE
  BEGIN
	-- Running for a specific time frame, so calculate @StartDate
	SET @StartDate = DATEADD(dd, -@NbrDaysToFix, @EndDate)
	SET @EndDate = @EndDateToFix
  END

-- Update ckc_lghnumber
UPDATE checkcall
SET ckc_lghnumber = (SELECT lgh_number 
					 FROM assetassignment (NOLOCK)
					 WHERE asgn_type = 'TRC' 
					   AND asgn_id = ckc_tractor 
					   AND asgn_date = (SELECT MAX(asgn_date) 
										 FROM assetassignment (NOLOCK)
										 WHERE asgn_date <= ckc_date 
										   AND asgn_type = 'TRC' 
										   AND asgn_id = ckc_tractor)) 
WHERE ckc_date > @StartDate
  AND ckc_date < @EndDate
GO
GRANT EXECUTE ON  [dbo].[tmail_checkcall_lgh_fix] TO [public]
GO
