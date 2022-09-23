SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetTruckDispGroupNameForCER]
	@TruckName						VARCHAR(15)

AS

-- =============================================================================
-- Stored Proc: [dbo].[tm_GetTruckDispGroupNameForCER]
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.09.04
-- Description:
--      This procedure will get the dispatch group name from tblDispatchGroup
--		using the CurrentDispatcher field value in tblTrucks for the TruckName
--		submitted.  This will be used in creating the initial form message
--		in the Critical Event Reporting process.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @TruckName					VARCHAR(15)
--
--      Outputs:
--      ------------------------------------------------------------------------
--		001 - TruckDispGroupName			VARCHAR(30)
--
--  ===========================================================================
/*
Used for testing proc
EXEC tm_GetTruckDispGroupNameForCER '232061'
EXEC tm_GetTruckDispGroupNameForCER 'QC353164'
*/
-- =============================================================================

BEGIN

	DECLARE 
		@TruckDispGroupName				VARCHAR(30)
    ----------------------------------------------------------------------------
	SELECT @TruckDispGroupName = DGRP.Name 
	  FROM tbltrucks AS TRK
			JOIN tblDispatchGroup AS DGRP 
				ON TRK.CurrentDispatcher = DGRP.sn
	 WHERE trk.TruckName  = @TruckName
    ----------------------------------------------------------------------------
    -- SELECT @TruckDispGroupName AS 'TruckDispGroupName'
    SELECT ISNULL(@TruckDispGroupName,'') AS 'TruckDispGroupName'

END 

GO
GRANT EXECUTE ON  [dbo].[tm_GetTruckDispGroupNameForCER] TO [public]
GO
