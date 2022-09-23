SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DeliveryTypeDescription]
	@DeliverToTypeList varchar (1)


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DeliveryTypeDescription]
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
 * 001 - @DeliverToTypeList varchar (1)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DeliveryTypeDescription]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Description] 
FROM tblAddressTypes(NoLock) 
WHERE SN = @DeliverToTypeList

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DeliveryTypeDescription] TO [public]
GO
