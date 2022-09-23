SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
         MODIFICATION LOG
 created 12/6/00 dpete PTS8863
 updated 08/10/2010 PTS51088 SPN

*/

CREATE  PROCEDURE       [dbo].[ttrheaderbycode_sp] (@ttrcode varchar(10), @ttr_type char(1))
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
	ttr_billto,
        ttr_regiontype 
      -- BEGIN PTS 51088 SPN
      , (SELECT MAX(userlabelname)
           FROM labelfile
          WHERE labeldefinition = 'REVTYPE1'
        ) AS cmp_revtype1_labeldefinition
      , cmp_revtype1
      , rowsec_rsrv_id
      -- END PTS 51088 SPN
FROM ttrheader
WHERE ttr_code = @ttrcode and ttr_triptypeorregion = @ttr_type
--BEGIN PTS 51088 SPN
  AND dbo.RowRestrictByUser('ttrheader',rowsec_rsrv_id,'','','') = 1
--END PTS 51088 SPN
GO
GRANT EXECUTE ON  [dbo].[ttrheaderbycode_sp] TO [public]
GO
