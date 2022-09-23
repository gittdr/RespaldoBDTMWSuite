SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.tm_GetRSValue
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls a tblRs value base on a Keycode
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * tblRs text and description fields
 *
 * PARAMETERS:
 * 001 - @sKeyCode, varchar(10);
 *       Key code to lookup in tblRS
 *
 * REVISION HISTORY:
 * 02/04/06      - 30449    - DWG - Created for Get RS Value view
 * 03/21/12      - 62089    - JW  - Added Static to select query
 **/

/* tm_GetRSValue **************************************************************
** 
*********************************************************************************/

CREATE PROCEDURE [dbo].[tm_GetRSValue]
	@sKeyCode varchar(10)

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
	ISNULL(text, '') ResultText, 
	ISNULL(Description, '') ResultDescription, 
	ISNULL(static, '') ResultStatic  
FROM dbo.tblRS 
WHERE keyCode = @sKeyCode

GO
GRANT EXECUTE ON  [dbo].[tm_GetRSValue] TO [public]
GO
