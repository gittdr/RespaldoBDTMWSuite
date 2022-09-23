SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_TrailerLoadedStatus]
	(@trl_number varchar(8),
	 @trl_ilt_scac varchar(4)='')
RETURNS varchar(3)
AS
BEGIN
declare @stp_loadstatus varchar(3)
declare @trl_id varchar(13)

If @trl_ilt_scac = ''
	SET @trl_id = @trl_number
ELSE
	SET @trl_id = @trl_ilt_scac + ',' + @trl_number 

SET @stp_loadstatus = IsNull(
	(
	SELECT  stp_loadstatus
	FROM    event (NOLOCK), Stops (NOLOCK)
	Where   event.stp_number = stops.stp_number		       
     and event.evt_number = 
	   (select max(aa.last_dne_evt_number)
	     from AssetAssignment aa (NOLOCK) 
	     where aa.asgn_id = @trl_id 
		   and aa.asgn_type = 'TRL' 
		   and aa.asgn_status IN ('CMP','STD'))
	), 'UNK')

return @stp_loadstatus 
	
END
GO
