SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_purge_ohos_detailed_records]	
		@Type					INT,
		@Limit					INT
AS

-- =============================================================================
-- Stored Proc: tmail_purge_ohos_detailed_records
-- Author     :	Binghunaiem, Abdullah
-- Create date: 2016.01.12
-- Description:
--      This procedure will purge data from the QHOSDriverLogExportData table.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      None										--
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		@Type					INT,
--		@Limit					INT
--
-- Revisions:
-- 01/12/2016 - Abdullah Binghunaiem - PTS 98061: Initial creation.
--
-- =============================================================================

-- Check for nulls 
IF @Type IS NULL
BEGIN
	RAISERROR (N'The parameter Type cannot be NULL in the stored proc tmail_purge_ohos_detailed_records.',10, 1)
END

IF @Limit IS NULL
BEGIN
	RAISERROR (N'The parameter Limit cannot be NULL in the stored proc tmail_purge_ohos_detailed_records.',10, 1)
END

-- check the type of purge specified
IF @TYPE = 1
BEGIN
	WITH BATCH AS
	(
		SELECT [SN]
		FROM QHOSDriverLogExportData (NOLOCK)
		WHERE DATEDIFF(DAY, [StartTime], GETDATE()) > @Limit
	)
	DELETE FROM BATCH 
END
ELSE IF @TYPE = 2
BEGIN
	WITH BATCH AS
	(
		SELECT [SN]
		FROM QHOSDriverLogExportData (NOLOCK)
		WHERE [SN] NOT IN
		(SELECT TOP (@Limit) [SN]
		FROM QHOSDriverLogExportData (NOLOCK)
		ORDER BY [StartTime] DESC)
	)
	DELETE FROM BATCH 
END
GO
GRANT EXECUTE ON  [dbo].[tmail_purge_ohos_detailed_records] TO [public]
GO
