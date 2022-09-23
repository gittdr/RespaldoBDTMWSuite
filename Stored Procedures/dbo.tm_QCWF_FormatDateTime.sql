SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_QCWF_FormatDateTime]
	@InputDateTime AS VARCHAR(20)

AS

DECLARE @WFOutDateTime AS VARCHAR(40)

BEGIN
	SET NOCOUNT ON;

	-- Initialize the output variables
	SELECT @WFOutDateTime = ''

	-- Perform the desired procedure.
	SELECT @WFOutDateTime = 
				REPLACE(CONVERT(VARCHAR(40),CONVERT(DATETIME,@InputDateTime),120),' ','T')

	-- Return the results.
	SELECT @WFOutDateTime

END
GO
GRANT EXECUTE ON  [dbo].[tm_QCWF_FormatDateTime] TO [public]
GO
