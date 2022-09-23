SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_tblMessagesFromTo]
	@MessageSN int

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_tblMessagesFromTo]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls FromName, FromType, DeliverTo from tblMessages base on MessageSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * FromName, FromType, DeliverTo fields
 *
 * PARAMETERS:
 * 001 - @MessageSN  int;
 *       
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_tblMessagesFromTo]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT FromName, FromType, DeliverTo 
FROM dbo.tblMessages 
WHERE SN = @MessageSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_tblMessagesFromTo] TO [public]
GO
