SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OttGetLabelfileRecs]
	@LabelDefinition	VARCHAR(20),
	@Abbr				VARCHAR(20)
AS

-- =============================================================================
-- Stored Proc: tmail_OttGetLabelfileRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.10.02
-- Description:
--      This procedure will pull records from the labelfiles table for abbr code
--      validation reasons.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable records.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @labeldefinition	VARCHAR 20
--		002 - @abbr				VARCHAR 6
--
--
--      ------------------------------------------------------------------------
--      ...PTS 73523 - VMS - 2013.11.20 - Move proc from TotalMail section of stored 
--                                        procs to TMW Suite section.
--      ------------------------------------------------------------------------
/*
Used for testing proc
EXEC 
*/
-- =============================================================================

BEGIN 

	SELECT 
		ISNULL(labeldefinition, '') labeldefinition,
		ISNULL(abbr, '') abbr
	FROM labelfile (NOLOCK)
	WHERE labeldefinition = @LabelDefinition
	  AND abbr = @Abbr

	-- If no records are found and empty dataset will be returned.
	
END	

GO
GRANT EXECUTE ON  [dbo].[tmail_OttGetLabelfileRecs] TO [public]
GO
