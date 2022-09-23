SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================================================
-- Stored Proc: [dbo].[tmail_routesync_purgeBlobRecords_Omnitracs]
-- Author     :	Rob Scott
-- Create date: 2013.10.28  - PTS 71605
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
CREATE PROCEDURE [dbo].[tmail_routesync_purgeBlobRecords_Omnitracs]
@cutoffdays Int,
@readytopurgeflag Int
AS

SET NOCOUNT OFF

DECLARE @DeleteCnt INT
SET @DeleteCnt = 0		--PTS 68464

IF @cutoffdays > 0	--if @cutoffdays = 0, then don't delete any records
	BEGIN
		DELETE	FROM lgh_routesync 
				WHERE lrs_date_calculated <= dateadd(dd, -@cutoffdays, getdate())
				AND (lrs_status & @readytopurgeflag) <> 0
		SET @DeleteCnt = @@ROWCOUNT
	END

RETURN @DeleteCnt
GO
GRANT EXECUTE ON  [dbo].[tmail_routesync_purgeBlobRecords_Omnitracs] TO [public]
GO
