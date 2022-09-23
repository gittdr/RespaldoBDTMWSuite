SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--jet - 2/28/12 - PTS 61665, removed from trigger because this affects the settings needed for 
--	a change requested by Ryder and recommended by Mindy (use of a Unique index on mpp_otherid that ignores NULLS)
--SET ANSI_NULLS ON
--GO
--
--SET QUOTED_IDENTIFIER ON
--GO

CREATE  FUNCTION [dbo].[RowRestrictValidRecord_Orderheader_fn_NET](@mov_number int, @TmwUser varchar(255))
RETURNS  int

AS

BEGIN
	declare @orderpassrestrictioncount int
	declare @ordercount int
	declare @retrievetrip int

	SET @retrievetrip = 1
	
	--Do any orders pass security?
	SELECT	@orderpassrestrictioncount = count(DISTINCT stp.ord_hdrnumber)
	FROM	stops stp
			inner join orderheader oh on stp.ord_hdrnumber = oh.ord_hdrnumber
			INNER JOIN RowRestrictValidAssignments_for_tmwuser_fn_NET('orderheader', @TmwUser) rsva on	(	oh.rowsec_rsrv_id = rsva.rowsec_rsrv_id
																										OR rsva.rowsec_rsrv_id = 0
																									)
	WHERE	stp.mov_number = @mov_number

	--any orders?
	SELECT	@ordercount = count(DISTINCT stp.ord_hdrnumber)
	FROM	stops stp
	WHERE	stp.mov_number = @mov_number
			AND stp.ord_hdrnumber > 0 

	IF @ordercount > 0 BEGIN
		IF @orderpassrestrictioncount = 0 BEGIN
			SET @retrievetrip = 0
		END
	END
	ELSE BEGIN
		--make sure associated tractors at least are present
		SELECT	@orderpassrestrictioncount = count(*)
		FROM	stops stp
				INNER JOIN event evt on stp.stp_number = evt.stp_number
				INNER JOIN tractorprofile trc on evt.evt_tractor = trc.trc_number
				INNER JOIN RowRestrictValidAssignments_for_tmwuser_fn_NET('tractorprofile', @TmwUser) rsva on	(	trc.rowsec_rsrv_id = rsva.rowsec_rsrv_id
																												OR rsva.rowsec_rsrv_id = 0
																											)
		WHERE	stp.mov_number = @mov_number

		IF @orderpassrestrictioncount = 0 BEGIN
			SELECT @retrievetrip = 0
		END 
	END
	RETURN @retrievetrip

END

GO
GRANT EXECUTE ON  [dbo].[RowRestrictValidRecord_Orderheader_fn_NET] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowRestrictValidRecord_Orderheader_fn_NET] TO [public]
GO
