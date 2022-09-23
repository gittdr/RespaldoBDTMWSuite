SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_LegInfo] 
		@pLeg					AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tmail_LegInfo
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

BEGIN

	SET NOCOUNT ON;

	DECLARE @iLeg INT

	--Parameter Validation
	IF ISNUMERIC(@pLeg) = 1
	BEGIN
		SET @iLeg = CONVERT(int,@pLeg)
	END
	ELSE
	BEGIN
		RAISERROR('INVALID LEG NUMBER', 16, 1, @pLeg)
		RETURN
	END

	IF NOT EXISTS (SELECT NULL FROM legheader (NOLOCK) where lgh_number = @iLeg)
	BEGIN
		RAISERROR('INVALID LEG NUMBER', 16, 1, @pLeg)
		RETURN
	END

	--Return Leg Info	
	SELECT lgh_driver1, lgh_tractor, ord_hdrnumber, mov_number
	FROM legheader (NOLOCK) 
	WHERE lgh_number = @iLeg
	
END

GO
GRANT EXECUTE ON  [dbo].[tmail_LegInfo] TO [public]
GO
