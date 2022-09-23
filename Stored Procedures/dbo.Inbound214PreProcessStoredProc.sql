SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[Inbound214PreProcessStoredProc] 
(@ID int, @ord_hdrnumber int output, @lgh_number int output, @stp_number int output, @StatusCode varchar(2) output, @StatusDateTime datetime output)

AS
Set @StatusCode = 'DW'
Set @StatusDateTime = GetDate()

GO
GRANT EXECUTE ON  [dbo].[Inbound214PreProcessStoredProc] TO [public]
GO
