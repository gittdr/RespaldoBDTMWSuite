SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 10/03/01 TD: Created to workaround SQL2K Inert/RowCount issue. */

CREATE PROCEDURE [dbo].[tmail_purge_checkcalls_Help]    @LoopID varchar(20), 
					@MinPerUnit int,
					@TrailerFlag int -- Nonzero means trailer.
AS

	SET ROWCOUNT @MinPerUnit
	IF @TrailerFlag = 0
		SELECT ckc_date 
		FROM checkcall (NOLOCK)
		WHERE ckc_tractor = @LoopId
		  AND ckc_asgntype = 'DRV'
		  AND ckc_event = 'TRP'
		  AND ckc_updatedby = 'TMAIL'
		ORDER BY ckc_date DESC
	ELSE
		SELECT ckc_date 
		FROM checkcall (NOLOCK)
		WHERE ckc_asgnid = @LoopId
		  AND ckc_asgntype = 'TRL'
		  AND ckc_event = 'TRL'
		  AND ckc_updatedby = 'TMAIL'
		ORDER BY ckc_date DESC

	SET ROWCOUNT 0
GO
GRANT EXECUTE ON  [dbo].[tmail_purge_checkcalls_Help] TO [public]
GO
