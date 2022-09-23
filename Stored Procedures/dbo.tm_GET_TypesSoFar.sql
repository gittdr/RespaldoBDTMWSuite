SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TypesSoFar]
	@TypeCode varchar (1)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TypesSoFar]
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
 * 001 - @TypeCode varchar (1)
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_TypesSoFar]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN 
FROM tblAddressTypes(NoLock)  
WHERE AddressType= @TypeCode 


GO
GRANT EXECUTE ON  [dbo].[tm_GET_TypesSoFar] TO [public]
GO
