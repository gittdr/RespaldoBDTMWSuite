SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 10/18/00 MZ: */
CREATE PROCEDURE [dbo].[tmail_last_x_checkcalls1] 	@sEquipment varchar(20),
						@date datetime,
						@nbrcheckcalls int,
						@nTrailerFlag int
AS

SET ROWCOUNT @nbrcheckcalls

if ISNULL(@nTrailerFlag, 0) > 0  --Trailer 
	SELECT  ckc_number, 
		ckc_date, 
		ISNULL(ckc_lghnumber,-1) ckc_lghnumber,
		ckc_latseconds, 
		ckc_longseconds, 
		ISNULL(ckc_home, '') ckc_home
	FROM checkcall (NOLOCK)
	WHERE ckc_asgnid = @sEquipment
	  AND ckc_asgntype = 'TRL'
	  AND ckc_date < @date
	  AND ckc_updatedby = 'TMAIL'
	  AND ckc_event = 'TRP'
	ORDER BY ckc_date DESC
ELSE
	SELECT  ckc_number, 
		ckc_date, 
		ISNULL(ckc_lghnumber,-1) ckc_lghnumber,
		ckc_latseconds, 
		ckc_longseconds, 
		ISNULL(ckc_home, '') ckc_home
	FROM checkcall (NOLOCK)
	WHERE ckc_tractor = @sEquipment
	  AND ckc_date < @date
	  AND ckc_updatedby = 'TMAIL'
	ORDER BY ckc_date DESC

SET ROWCOUNT 0

GO
GRANT EXECUTE ON  [dbo].[tmail_last_x_checkcalls1] TO [public]
GO
