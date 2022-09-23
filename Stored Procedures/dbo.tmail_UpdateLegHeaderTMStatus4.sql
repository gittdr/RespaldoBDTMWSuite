SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatus4]
					@lLegNum int, 
					@sNewStatus varchar(6),
					@lNoOverride int,
					@sFlags varchar(12)
				    	
AS

EXEC dbo.tmail_UpdateTMStatus @lLegNum, 0, '', 0, '', 0, @sFlags, @sNewStatus, @lNoOverride
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatus4] TO [public]
GO
