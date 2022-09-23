SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_FindFreightForHLT] 
		@lgh					AS VARCHAR(20), 
		@event					AS VARCHAR(20), 
		@cmd_code				AS VARCHAR(30), 
		@cmd_description		AS VARCHAR(50)
							 
AS

-- =============================================================================
-- Stored Proc: tmail_FindFreightForHLT
-- Author     :	From email authored by Lori Brickley to Dave Gudat on April 10, 2013
-- Create date: 2014.03.04
-- Description:
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

--tmail_FindFreightForHLT 1444725,'hlt','UNKNOWN','UNKNOWN'

BEGIN

	SET NOCOUNT ON;

	IF @event <> 'HLT'
		select @cmd_code, @cmd_description

	ELSE

	SELECT cmd_code, fgt_description

	FROM dbo.freightdetail (NOLOCK) 

	WHERE stp_number IN (SELECT stp_number FROM stops (NOLOCK) WHERE lgh_number = @lgh) and cmd_code <>'UNKNOWN'

END

GO
GRANT EXECUTE ON  [dbo].[tmail_FindFreightForHLT] TO [public]
GO
