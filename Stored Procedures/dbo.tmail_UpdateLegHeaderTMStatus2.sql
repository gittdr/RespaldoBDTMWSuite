SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatus2] 
					@lLegNum int, 
					@sNewStatus varchar(6)
				    	
AS

EXEC dbo.tmail_UpdateTMStatus @lLegNum, 0, '', 0, '', 0, '', @sNewStatus, 0
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatus2] TO [public]
GO
