SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_transfer_checkcall_xfc]

AS

/* 03/11/2014 PTS 74678 HMA - tm_transfer_checkcall_xfc now calls tm_transfer_checkcall_xfc2 and all the code that 
*                         was tm_transfer_checkcall_xfc is now in tm_transfer_checkcall_xfc2 with some modifications.

*/
DECLARE @p_returned int

EXEC dbo.tm_transfer_checkcall_xfc2 0, @p_returned

GO
GRANT EXECUTE ON  [dbo].[tm_transfer_checkcall_xfc] TO [public]
GO
