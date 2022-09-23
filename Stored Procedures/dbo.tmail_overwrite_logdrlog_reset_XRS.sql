SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_overwrite_logdrlog_reset_XRS]
	@ResetDay DATETIME,
	@mpp_id VARCHAR(25)
AS
/*
Name: tmail_overwrite_logdrlog_reset_XRS

Type:
Stored Procedure

Descritption:


Returns:


Parameters:


Change Log:
rwolfe init 08-01-2014

*/

UPDATE log_driverlogs SET rule_reset_indc = 'N' WHERE mpp_id = @mpp_id AND log_date > DATEADD(day, -3, @ResetDay);

UPDATE	log_driverlogs SET rule_reset_indc = 'Y' WHERE mpp_id = @mpp_id AND DATEDIFF(DAY, log_date, @ResetDay) = 0


GO
GRANT EXECUTE ON  [dbo].[tmail_overwrite_logdrlog_reset_XRS] TO [public]
GO
