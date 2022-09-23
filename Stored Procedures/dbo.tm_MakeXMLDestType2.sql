SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MakeXMLDestType2] 
		@StopEventType			AS VARCHAR(8), 
		@StpSeq					AS VARCHAR(3), 
		@NoOfStps				AS VARCHAR(3),
		@flags					AS VARCHAR(20), 
		@StopEvent				AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tm_MakeXMLDestType2
-- Author     :	From email authored by Lori Brickley to Dave Gudat on April 10, 2013
-- Create date: 2014.03.04
-- Description:
--
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

--tm_MakeXMLDestType2 'PUP','1','3','1','DLT'

BEGIN

	SET NOCOUNT ON;

	DECLARE @WFDestType AS VARCHAR(20)

	-- Initialize the output variables
	SELECT @WFDestType = ''

	-- Perform the desired procedure.
	SELECT @WFDestType = 
				CASE UPPER(@StopEventType)
					WHEN 'PUP' THEN 'interlinePickup'
					WHEN 'DRP' THEN 'interlineDropoff'
					ELSE ''
				END

	
	IF @StpSeq = 1
	SELECT @WFDestType = 'origin'
	
	IF @StpSeq = @NoOfStps
	SELECT @WFDestType = 'finalDestination' 

	IF @StopEvent = 'DLT'
	SELECT @WFDestType = 'dropoffRelay'

	IF @StopEvent = 'HLT'
	SELECT @WFDestType = 'pickupRelay'
	
	-- Return the results.
	SELECT @WFDestType

END

GO
GRANT EXECUTE ON  [dbo].[tm_MakeXMLDestType2] TO [public]
GO
