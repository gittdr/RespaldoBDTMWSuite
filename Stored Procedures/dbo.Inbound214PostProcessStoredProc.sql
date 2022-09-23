SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[Inbound214PostProcessStoredProc] 
(@ID int, @ord_hdrnumber int output, @lgh_number int, @stp_number int, @StatusCode varchar(2), @StatusDateTime datetime)

AS


GO
GRANT EXECUTE ON  [dbo].[Inbound214PostProcessStoredProc] TO [public]
GO
