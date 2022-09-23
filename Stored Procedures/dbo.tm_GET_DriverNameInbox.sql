SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DriverNameInbox]
	@DriverName varchar(50)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DriverNameInbox]
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
 * 001 - @DriverName varchar(50)
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_DriverNameInbox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tdg.InBox 
From dbo.tblDispatchGroup tdg
inner join tblDrivers td
on tdg.sn = td.CurrentDispatcher
WHERE td.Name = @DriverName 

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DriverNameInbox] TO [public]
GO
