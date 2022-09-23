SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMail_Transaction_Distribute_Messages]
	@InstanceName VARCHAR(4) = NULL
AS

/**
 * 
 * NAME:
 * dbo.TMail_Transaction_Distribute_Messages
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Used for Message Balancing. Main Procedure for TMWSuite side (Outbound).
 *   Handles top level processing of TMWSuite side (TMSQLMessageTran) Transaction Server entries. 
 *   Including list cleanup and if Messages need redistribution.
 *
 * RETURNS:
 * NONE
 * 
 * PARAMETERS:
 * None
 * 
 * Change Log: 
 * DWG 05/01/2013 PTS 61250 - Created
 *
 **/
 
/*
 Flags:
   1 = Active
   2 = Polling
   4 = Reset
   8 = Start up
   16 = Shutdown Request
   32 = Shutdown Successful
*/

--rwolfe PTS 98345, temp just set to 0 until done with dynamic message balencing
UPDATE TMSQLMessage SET [TranInstance] = 0
GO
GRANT EXECUTE ON  [dbo].[TMail_Transaction_Distribute_Messages] TO [public]
GO
