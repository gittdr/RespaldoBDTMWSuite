SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
         MODIFICATION LOG
 created 12/6/00 dpete PTS8863
 LOR - PTS# 11538 - added @ttr_type arg.
 SPN - PTS# 51088 - added row security
*/

CREATE  PROCEDURE       [dbo].[ttrheaderdddw_sp] (@ttr_type char(1))
AS

SELECT ttr_number,
	ttr_triptypeorregion,
	ttr_code,
	ttr_name,
	ttr_comment,
	ttr_addon,
	ttr_updateon,
	ttr_updateby,
	ttr_startdate,
	ttr_enddate,
	ttr_billto ,
	displayname = ttr_code+' - '+ttr_name
FROM ttrheader
WHERE ttr_triptypeorregion = @ttr_type
--BEGIN PTS 51088 SPN
  AND dbo.RowRestrictByUser('ttrheader',rowsec_rsrv_id,'','','') = 1
--END PTS 51088 SPN
Order by displayname

GO
GRANT EXECUTE ON  [dbo].[ttrheaderdddw_sp] TO [public]
GO
