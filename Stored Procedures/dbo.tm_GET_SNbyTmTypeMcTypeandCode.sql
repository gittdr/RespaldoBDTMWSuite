SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_SNbyTmTypeMcTypeandCode]
	@tmType int,
	@mcType int,
	@Code varchar (10)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_SNbyTmTypeMcTypeandCode]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @tmType int
 * 002 - @mcType int 
 * 003 - @Code varchar(10)
 *     
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_SNbyTmTypeMcTypeandCode]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM dbo.tblFldType 
WHERE TotalMailType = @tmType
AND MobileCommType = @mcType
AND Code = @Code



GO
GRANT EXECUTE ON  [dbo].[tm_GET_SNbyTmTypeMcTypeandCode] TO [public]
GO
