SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_ParametersAndNames]
	@ViewName varchar (10)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_ParametersAndNames]
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
 * 001 - @ViewName varchar (10)
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_ParametersAndNames]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT FieldName,tblViewFields.DispXfcTag 
FROM tblViews(NoLock), tblViewFields(NoLock) 
WHERE tblViews.SN = tblViewFields.ViewNumber  
AND tblViews.ViewCode = @ViewName
AND ISNULL(tblViewFields.DispXfcTag,'') <> ''
ORDER BY CONVERT(int, tblViewFields.DispXfcTag)

GO
GRANT EXECUTE ON  [dbo].[tm_GET_ParametersAndNames] TO [public]
GO
