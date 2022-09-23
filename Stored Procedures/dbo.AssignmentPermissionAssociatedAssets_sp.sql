SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[AssignmentPermissionAssociatedAssets_sp](
    @assettype char(3),
    @assetid varchar(13)
)

AS BEGIN
	DECLARE	@resultset TABLE	(
		Selected varchar(1),
		IDType varchar(4),
		ID varchar(13),
		Name varchar(45)
	)

	--DECLARE @IDType varchar(4)
	--DECLARE @ID varchar(13)
	DECLARE	@AsOfDate datetime
	
	SELECT @AsOfDate = GETDATE()
	
	INSERT	@resultset	(
				Selected,
				IDType,
				ID,
				Name
	)
	SELECT	'Y' as selected, 
				'DRV2' as IDType, 
				trc.trc_driver2 as ID, 
				mpp.mpp_lastfirst as name
		FROM	tractorprofile trc
				INNER JOIN manpowerprofile mpp on mpp.mpp_tractornumber = trc.trc_number
		WHERE	mpp.mpp_id = @assetid
				AND @assettype = 'DRV'
				AND ISNULL(trc.trc_driver2, 'UNKNOWN') <> 'UNKNOWN'
	UNION
		SELECT	'Y', 
				'TRC', 
				mpp.mpp_tractornumber, 
				trc.trc_owner
		FROM	manpowerprofile mpp
				INNER JOIN tractorprofile trc on mpp.mpp_tractornumber = trc.trc_number
		WHERE	mpp.mpp_id = @assetid
				AND @assettype = 'DRV'
				AND ISNULL(mpp.mpp_tractornumber, 'UNKNOWN') <> 'UNKNOWN'
	UNION
		SELECT	'Y', 
				'DRV1', 
				trc.trc_driver, 
				mpp.mpp_lastfirst
		FROM	tractorprofile trc
				INNER JOIN manpowerprofile mpp on trc.trc_driver = mpp.mpp_id
		WHERE	trc.trc_number = @assetid
				AND @assettype = 'TRC'
				AND ISNULL(trc.trc_driver, 'UNKNOWN') <> 'UNKNOWN'
	UNION
		SELECT	'Y', 
				'DRV2', 
				trc.trc_driver2, 
				mpp.mpp_lastfirst
		FROM	tractorprofile trc
				INNER JOIN manpowerprofile mpp on trc.trc_driver = mpp.mpp_id
		WHERE	trc.trc_number = @assetid
				AND @assettype = 'TRC'
				AND ISNULL(trc.trc_driver2, 'UNKNOWN') <> 'UNKNOWN'
	UNION
		SELECT	'Y', 
				'TRL2', 
				trl.trl_pupid, 
				trl_pup.trl_owner
		FROM	trailerprofile trl
				INNER JOIN trailerprofile trl_pup on trl.trl_pupid = trl_pup.trl_id
		WHERE	trl.trl_id = @assetid
				AND @assettype = 'TRL'
				AND ISNULL(trl.trl_pupid, 'UNKNOWN') <> 'UNKNOWN'



	INSERT	@resultset	(
				Selected,
				IDType,
				ID,
				Name
	)
	SELECT	TOP 1 'Y',
			'TRL1',
			evt.evt_trailer1,
			''
	FROM	event evt
			INNER JOIN assetassignment aa on aa.evt_number = evt.evt_number
	WHERE	aa.asgn_id =	CASE @assettype
								WHEN 'TRC' THEN @assetid
								ELSE	(	SELECT TOP 1 ID
											FROM	@resultset rs
											WHERE	rs.IDType = 'TRC'
										)
							END
			and aa.asgn_type = 'TRC'
			and asgn_status IN ('CMP', 'STD', 'DSP') 
			AND asgn_date <= @AsOfDate
			AND evt.evt_sequence = 1
			AND ISNULL(evt.evt_trailer1, 'UNKNOWN') <> 'UNKNOWN'
	ORDER BY aa.asgn_date DESC
	
	INSERT	@resultset	(
				Selected,
				IDType,
				ID,
				Name
	)
	SELECT	TOP 1 'Y',
			'TRL2',
			evt.evt_trailer2,
			''
	FROM	event evt
			INNER JOIN assetassignment aa on aa.evt_number = evt.evt_number
	WHERE	aa.asgn_id =	CASE @assettype
								WHEN 'TRC' THEN @assetid
								ELSE	(	SELECT TOP 1 ID
											FROM	@resultset rs
											WHERE	rs.IDType = 'TRC'
										)
							END
			and aa.asgn_type = 'TRC'
			and asgn_status IN ('CMP', 'STD', 'DSP') 
			AND asgn_date <= @AsOfDate
			AND evt.evt_sequence = 1
			AND ISNULL(evt.evt_trailer2, 'UNKNOWN') <> 'UNKNOWN'
	ORDER BY aa.asgn_date DESC

	SELECT DISTINCT Selected,
			IDType,
			ID,
			Name
	FROM	@resultset
END


GO
GRANT EXECUTE ON  [dbo].[AssignmentPermissionAssociatedAssets_sp] TO [public]
GO
