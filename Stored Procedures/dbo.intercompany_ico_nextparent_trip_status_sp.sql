SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46682 JJF 20110515
CREATE PROCEDURE [dbo].[intercompany_ico_nextparent_trip_status_sp]	(
	@stp_number int
) 
AS BEGIN
	DECLARE @mov_number						int
	DECLARE @lgh_startdate					datetime
	
	DECLARE @ico_associated_intercompany_trips TABLE	(
		level int null,
		mov_number int null,
		lgh_number int null,
		ord_hdrnumber int null,
		mov_number_parent int null,
		lgh_number_parent int null,
		lgh_startdate datetime null,
		lgh_enddate datetime null,
		lgh_outstatus varchar(6) null,
		lgh_instatus varchar(6) null,
		leafnode bit null,
		ico_lgh_id int null
	)
	
	IF NOT EXISTS	(	SELECT	*
						FROM	generalinfo
						WHERE	gi_name = 'ICOCarriers'
								and isnull(gi_integer2, 0) = 0
					) BEGIN
		RETURN
	END

	--Get get current movement info
	SELECT TOP 1
			@mov_number = lgh.mov_number,
			@lgh_startdate = lgh.lgh_startdate
	FROM	stops stp
			INNER JOIN legheader lgh ON stp.lgh_number = lgh.lgh_number
	WHERE	stp.stp_number = @stp_number

	--Load up associated ICO trips
	INSERT @ico_associated_intercompany_trips	(
		level,
		mov_number,
		lgh_number,
		ord_hdrnumber,
		mov_number_parent,
		lgh_number_parent,
		lgh_startdate,
		lgh_enddate,
		lgh_outstatus,
		lgh_instatus,
		leafnode,
		ico_lgh_id
	)
	SELECT	level,
			mov_number,
			lgh_number,
			ord_hdrnumber,
			mov_number_parent,
			lgh_number_parent,
			lgh_startdate,
			lgh_enddate,
			lgh_outstatus,
			lgh_instatus,
			leafnode,
			ico_lgh_id
	FROM dbo.ico_associated_intercompany_trips_fn(@mov_number)
		
	--Get first stop of next descendent segment 
	SELECT TOP 1 
			stp.mov_number, 
			stp.lgh_number,
			stp.stp_number,
			stp.stp_lgh_status,
			stp.stp_status,
			stp.stp_departuredate,
			stp.stp_arrivaldate,
			stp.stp_departuredate,
			CASE stp.stp_lgh_status
				WHEN 'PLN' THEN 'Y'
				WHEN 'AVL' THEN 'Y'
				WHEN 'DSP' THEN 'Y'
				ELSE 'N' 
			END AS NextNotActualized,
			'N' ShowDiagnostic
	FROM	stops stp
			INNER JOIN @ico_associated_intercompany_trips ico ON ico.lgh_number = stp.lgh_number
	WHERE	ico.leafnode = 1
			AND ico.mov_number <> @mov_number
			--NOT EXISTS	(	SELECT	*
			--				FROM	legheader lgh_inner
			--						INNER JOIN stops stp_inner ON lgh_inner.lgh_number = stp_inner.lgh_number
			--				WHERE	lgh_inner.lgh_number = stp.lgh_number
			--						AND stp_inner.stp_ico_stp_number_child > 0
			--			)
			AND ico.lgh_startdate > @lgh_startdate
	ORDER BY stp.stp_arrivaldate ASC
		
END

GO
GRANT EXECUTE ON  [dbo].[intercompany_ico_nextparent_trip_status_sp] TO [public]
GO
