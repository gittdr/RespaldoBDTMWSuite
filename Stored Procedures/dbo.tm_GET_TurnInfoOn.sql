SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TurnInfoOn]
	@KeyCode varchar (10)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TurnInfoOn]
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
 * 001 - @KeyCode varchar(10)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_TurnInfoOn]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT [text]
FROM tblRS(NoLock) 
WHERE keyCode = @KeyCode

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TurnInfoOn] TO [public]
GO
