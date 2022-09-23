SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tmail_enh_log_hours_reply    Script Date: 12/29/98 8:32:52 AM ******/
/* Log Hours Recording **************************
** Used for inserting log hours as sent by driver 
** Created:		Dan Klein
**			11/11/97
** Added 'Enhanced' 	Todd DiGiacinto
**	features	10/21/98
***************************************************/


/* Note on Enhanced features: msgdate/time being too early must be
	checked by the calling routine as is 24 hour total. */

CREATE PROCEDURE [dbo].[tmail_enh_log_hours_reply] 
	@driver_id varchar(8),
	@ssn varchar(20),
	@tractor varchar(13), 
	@date datetime,
	@onduty int,
	@sleeper int,
	@driving int,
	@miles int

AS

SET NOCOUNT ON 
	
DECLARE @Rule_Reset_Indicator varchar(1) /* jgf 1/9/04 {21232} */
Select @Rule_Reset_Indicator = NULL

EXEC dbo.tmail_enh_log_hours_reply2 @driver_id, @ssn, @tractor, @date, @onduty, @sleeper, @driving, @miles, @Rule_Reset_Indicator

GO
GRANT EXECUTE ON  [dbo].[tmail_enh_log_hours_reply] TO [public]
GO
