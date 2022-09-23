SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_nametypePbysysobjects]
	@sysobjname varchar (100),
	@sysobjtype varchar (1)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_nametypePbysysobjects]
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
 * 001 - @sysobjname varchar (100)
 * 002 - @sysobjtype varchar (1)
 * 
 *     
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_nametypePbysysobjects]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT name 
FROM dbo.sysobjects 
WHERE name = @sysobjname 
AND type = @sysobjtype


GO
GRANT EXECUTE ON  [dbo].[tm_GET_nametypePbysysobjects] TO [public]
GO
