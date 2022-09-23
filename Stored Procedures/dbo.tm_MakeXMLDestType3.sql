SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MakeXMLDestType3] 
		@StopEventType			AS VARCHAR(8), 
		@StpSeq					AS VARCHAR(3), 
		@NoOfStps				AS VARCHAR(3),
		@StopEvent				AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tm_MakeXMLDestType3
--
-- Author     :	Virgil Sensabaugh
-- Create date: 2014.11.11
-- Description: Replaces tm_MakeXMLDestType2.  Old version kept in source for clients
--              who may be using the proc in their workflow forms.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--
--      Input parameters:
--      ------------------------------------------------------------------------
--
-- =============================================================================
-- Modification Log:
-- PTS 83368 - VMS - 2014.11.11 - Created
-- =============================================================================

-- EXEC tm_MakeXMLDestType3 'PUP','1','3','LLD'

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
GRANT EXECUTE ON  [dbo].[tm_MakeXMLDestType3] TO [public]
GO
