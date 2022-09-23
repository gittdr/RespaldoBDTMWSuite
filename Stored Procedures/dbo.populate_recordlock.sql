SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[populate_recordlock] 
	@user_id char(20)
	, @dt DateTime
	, @ordnum Int
AS

DECLARE @mov INT

CREATE TABLE #temp (
	trc_number CHAR(8)
	)

SELECT 	@mov = mov_number
FROM	orderheader
WHERE	ord_hdrnumber = @ordnum

INSERT INTO 	recordlock (
	locked_by
	, session_date
	, ord_hdrnumber 
	)
VALUES		(
	@user_id
	, @dt
	, @ordnum
	)

INSERT INTO 	#temp
SELECT	lgh_tractor
FROM	legheader
WHERE	mov_number = @mov

INSERT INTO	#temp
SELECT	ppa_tractor
FROM 	preplan_assets
WHERE	ppa_mov_number = @mov
  AND	NOT EXISTS (SELECT trc_number FROM #temp WHERE trc_number = ppa_tractor) 
  AND	ppa_status = 'ACTIVE'

INSERT INTO	recordlock (
	locked_by
	, session_date
	, ord_hdrnumber 
	)
SELECT	DISTINCT 
	@user_id
	, @dt
	, orderheader.ord_hdrnumber
FROM 	#temp, orderheader, legheader, assetassignment
WHERE	legheader.ord_hdrnumber = orderheader.ord_hdrnumber
  AND	asgn_type = 'TRC'
  AND	asgn_id = #temp.trc_number
  AND	assetassignment.lgh_number = legheader.lgh_number
  AND	legheader.lgh_active = 'Y'
  AND	legheader.lgh_outstatus in ('PLN', 'STD', 'DSP')
	
INSERT INTO	recordlock (
	locked_by
	, session_date
	, ord_hdrnumber 
	)
SELECT	DISTINCT 
	@user_id
	, @dt
	, orderheader.ord_hdrnumber
FROM 	#temp, orderheader, legheader, preplan_assets
WHERE	legheader.ord_hdrnumber = orderheader.ord_hdrnumber
  AND	ppa_tractor = #temp.trc_number
  AND	preplan_assets.ppa_lgh_number = legheader.lgh_number
  AND	preplan_assets.ppa_status = 'Active'

GO
GRANT EXECUTE ON  [dbo].[populate_recordlock] TO [public]
GO
