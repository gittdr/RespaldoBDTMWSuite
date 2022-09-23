SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ico_associated_intercompany_trips_fn](@mov_number int)
RETURNS @Table	TABLE	(
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

AS
BEGIN
	
	DECLARE	@level int
	DECLARE @priorcount int
	DECLARE @newcount int

	DECLARE @tt	TABLE	(
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
		stp_ico_stp_number_child int null,
		id int IDENTITY(1,1) NOT null,
		ico_lgh_id int null
		 
	)
	
	DECLARE @movtbl TABLE (
		mov_number_parent int null,
		lgh_number_parent int null,
		ico_lgh_id_parent int null,
		mov_number_child int null
	)

	SELECT @mov_number = dbo.intercompany_ico_mov_number_top_fn(@mov_number)	

	
	INSERT	@tt	(
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
		stp_ico_stp_number_child
	)
	SELECT	DISTINCT 0 as level,
			lgh.mov_number,
			lgh.lgh_number,
			lgh.ord_hdrnumber,
			0 mov_number_parent,
			0 lgh_number_parent,
			lgh.lgh_startdate,
			lgh.lgh_enddate,
			lgh.lgh_outstatus, 
			lgh.lgh_instatus,
			CASE ISNULL(stp.stp_ico_stp_number_child, 0) 
				WHEN 0 THEN 1
				ELSE 0
			END AS leafnode,
			stp.stp_ico_stp_number_child
	FROM	legheader lgh
			INNER JOIN stops stp on stp.lgh_number = lgh.lgh_number
	WHERE	lgh.mov_number = @mov_number

	UPDATE	@tt
	SET		ico_lgh_id =	(	SELECT TOP 1 
										id 
								FROM	@tt ttinner 
								WHERE	ttinner.lgh_number = tt.lgh_number
							)
	FROM	@tt tt
						
	
	SELECT	@level = 0
	SELECT	@priorcount = 0
	SELECT	@newcount = -1
	
	WHILE	@priorcount <> @newcount BEGIN
		SELECT	@level = @level + 1
		
		SELECT	@priorcount = COUNT(*) 
		FROM	@tt

		DELETE @movtbl
		
		INSERT	@movtbl(
			mov_number_parent,
			lgh_number_parent,
			ico_lgh_id_parent,
			mov_number_child
		)
		SELECT DISTINCT
				tt.mov_number,
				tt.lgh_number,
				tt.ico_lgh_id,
				stp.mov_number
		FROM	@tt tt
				INNER JOIN stops stp ON tt.stp_ico_stp_number_child = stp.stp_number
		WHERE	tt.level = @level - 1
		
		INSERT	@tt	(
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
			stp_ico_stp_number_child,
			ico_lgh_id
		)
		SELECT DISTINCT	@level,
				lgh.mov_number,
				lgh.lgh_number,
				lgh.ord_hdrnumber,
				mt.mov_number_parent,
				mt.lgh_number_parent,
				lgh.lgh_startdate,
				lgh.lgh_enddate,
				lgh.lgh_outstatus, 
				lgh.lgh_instatus,
				CASE ISNULL(stp.stp_ico_stp_number_child, 0) 
					WHEN 0 THEN 1
					ELSE 0
				END AS leafnode,
				stp.stp_ico_stp_number_child,
				mt.ico_lgh_id_parent
		FROM	@movtbl mt 
				INNER JOIN legheader lgh on mt.mov_number_child = lgh.mov_number
				INNER JOIN stops stp ON lgh.lgh_number = stp.lgh_number

		SELECT	@newcount = COUNT(*) 
		FROM	@tt
		
	END
	
	INSERT @Table	(
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
	SELECT DISTINCT 
			level,
			tt.mov_number,
			tt.lgh_number,
			tt.ord_hdrnumber,
			tt.mov_number_parent,
			tt.lgh_number_parent,
			tt.lgh_startdate,
			tt.lgh_enddate,
			tt.lgh_outstatus, 
			tt.lgh_instatus,
			tt.leafnode,
			tt.ico_lgh_id
	FROM	@tt tt 
	
RETURN 
	
END
GO
GRANT REFERENCES ON  [dbo].[ico_associated_intercompany_trips_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[ico_associated_intercompany_trips_fn] TO [public]
GO
