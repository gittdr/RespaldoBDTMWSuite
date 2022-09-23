SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckNameinsysobj]
	@Name varchar (50),
	@Type varchar (4)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckNameinsysobj]
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
 * 001 - @Name varchar (50)
 * 002 - @Type varchar (4)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckNameinsysobj]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT [name] 
FROM sysobjects(NoLock) 
WHERE name = @Name 
AND type = @Type


GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckNameinsysobj] TO [public]
GO
