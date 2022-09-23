SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================================================
-- Stored Proc: [dbo].[tmail_routesync_purgeBlobRecords]
-- Author     :	Rob Scott
-- Create date: 2013.02.22  - PTS 63996
-- Description:
--
--	Deletes all records in the lgh_routesync table WHERE the lrs_date_calculated
--	(the date the record was created) is older than the number of @cutoffdays.
--
--	If @cutoffdays = 0, then don't delete any records.
--
--
-- Change Log:
--		04/02/2013 PTS 68464 RS	-SQL 2005 doesn't support setting default values
--			in the declaration - fixed DECLARE @DeleteCnt INT = 0
--		
--
-- =============================================================================
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @cutoffdays	Int
--
--      Output paramters:
--      ------------------------------------------------------------------------
--		None
--
--      Returns:
--      ------------------------------------------------------------------------
--		Number of records deleted
--
-- =============================================================================
CREATE PROCEDURE [dbo].[tmail_routesync_purgeBlobRecords]
@cutoffdays Int
AS

DECLARE @DeleteCnt INT
SET @DeleteCnt = 0		--PTS 68464

IF @cutoffdays > 0	--if @cutoffdays = 0, then don't delete any records
	BEGIN
		DELETE	FROM lgh_routesync 
				WHERE lrs_date_calculated <= dateadd(dd, -@cutoffdays, getdate())
		SELECT @DeleteCnt = @@ROWCOUNT
	END

RETURN @DeleteCnt
GO
GRANT EXECUTE ON  [dbo].[tmail_routesync_purgeBlobRecords] TO [public]
GO
