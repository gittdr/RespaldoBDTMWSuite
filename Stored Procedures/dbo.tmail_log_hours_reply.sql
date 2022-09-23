SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Log Hours Recording **************************
** Used for inserting log hours as sent by driver 
** Created:		Dan Klein
**			11/11/97
***************************************************/

CREATE PROCEDURE [dbo].[tmail_log_hours_reply] 
	@driver_id varchar(8),
	@date datetime,
	@onduty int,
	@sleeper int,
	@driving int,
	@miles int,
	@errmess varchar(128) OUT

AS

DECLARE	@Rule_Reset_Indicator varchar(1) /* jgf 1/9/04 {21232} */
Select @Rule_Reset_Indicator = NULL -- default

EXEC dbo.tmail_log_hours_reply2 @driver_id, @date, @onduty, @sleeper, @driving,
	@miles, @errmess out, @Rule_Reset_Indicator

GO
GRANT EXECUTE ON  [dbo].[tmail_log_hours_reply] TO [public]
GO
