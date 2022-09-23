SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_sysobjectsLength]
	@TableName varchar (50),
	@ColumnFieldName varchar (50)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_sysobjectsLength]
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
 * 001 - @TableName varchar (50)
 * 002 - @ColumnFieldName varchar (50)
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_sysobjectsLength]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT c.length 
FROM dbo.sysobjects o 
INNER JOIN syscolumns c 
ON o.id = c.id 
WHERE o.name = @TableName 
AND c.name = @ColumnFieldName


GO
GRANT EXECUTE ON  [dbo].[tm_GET_sysobjectsLength] TO [public]
GO
