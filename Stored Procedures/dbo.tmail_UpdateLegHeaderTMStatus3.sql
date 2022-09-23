SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatus3]
					@lLegNum int, 
					@sNewStatus varchar(6),
					@lNoOverride int
				    	
AS

EXEC tmail_UpdateLegHeaderTMStatus4
					@lLegNum, 
					@sNewStatus,
					@lNoOverride,
					0
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatus3] TO [public]
GO
