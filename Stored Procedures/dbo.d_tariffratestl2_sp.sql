SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[d_tariffratestl2_sp] (@pl_tarnum int) AS

/**
 *
 * NAME:
 * dbo.d_tariffratestl2_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow d_tar_editrate_stl
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 - @pl_tarnum int
 *
 * REVISION HISTORY:
 * PTS 51901 SPN Created 01/17/11
 * 
 **/

SET NOCOUNT ON
--DECLARE @li_cellhistory int

--SELECT @li_cellhistory = 0

--IF EXISTS (SELECT *
--             FROM GENERALINFO
--            WHERE gi_name = 'Tar_Show_Cell_History'
--              AND gi_string1 = 'Y'
--          )
--SELECT @li_cellhistory = 1

--IF @li_cellhistory = 1
--exec autogenerate_tariffratestlhistory_sp @pl_tarnum

CREATE TABLE #temp
( tra_rate                    MONEY    NULL
, trc_number_row              INT      NULL
, trc_number_col              INT      NULL
, tar_number                  INT      NULL
, tariffrow_sequence          INT      NULL
, tariffcolumn_sequence       INT      NULL
, tra_apply                   CHAR(1)  NULL
, tra_retired                 DATETIME NULL
, tra_activedate              DATETIME NULL
, tra_minrate                 MONEY    NULL
, tra_standardhours           MONEY    NULL
, tra_minqty                  CHAR(1)  NULL
, tra_rateasflat              CHAR(1)  NULL
, tariffrow_trc_rangevalue    MONEY    NULL
, tariffcolumn_trc_rangevalue MONEY    NULL
)

INSERT INTO #temp
SELECT t.tra_rate
     , t.trc_number_row
     , t.trc_number_col
     , t.tar_number
     , tr.trc_sequence        AS tariffrow_sequence
     , tc.trc_sequence        AS tariffcolumn_sequence
     , t.tra_apply
     , t.tra_retired
     , t.tra_activedate
     , t.tra_minrate
     , t.tra_standardhours
     , t.tra_minqty
     , t.tra_rateasflat
     , tr.trc_rangevalue      AS tariffrow_trc_rangevalue
     , tc.trc_rangevalue      AS tariffcolumn_trc_rangevalue
  FROM tariffratestl t
LEFT OUTER JOIN tariffrowcolumnstl tr ON t.trc_number_row = tr.trc_number
LEFT OUTER JOIN tariffrowcolumnstl tc ON t.trc_number_col = tc.trc_number
 WHERE t.tar_number = @pl_tarnum

--IF @li_cellhistory = 1 
--BEGIN
--    UPDATE #temp
--    SET tra_rate = NULL
--      , tra_activedate = NULL
--      , tra_retired = NULL
--
--   UPDATE #temp
--      SET tra_rate = trh.tra_rate
--   FROM tariffratestlhistory trh
--    WHERE trh.tar_number = @pl_tarnum
--      AND trh.trc_number_row = #temp.trc_number_row
--      AND trh.trc_number_col = #temp.trc_number_col
--      AND getdate() BETWEEN trh_fromdate AND trh_todate
-- 
--   UPDATE #temp
--      SET tra_rate = trh.tra_rate
--     FROM tariffratestlhistory trh
--    WHERE trh.tar_number = @pl_tarnum
--      AND #temp.tra_rate IS NULL
--      AND trh.trc_number_row = #temp.trc_number_row
--      AND trh.trc_number_col = #temp.trc_number_col
--      AND trh_todate = (SELECT MAX(trh_todate)
--                          FROM tariffratestlhistory trh2
--                         WHERE trh2.tar_number = @pl_tarnum
--                           AND trh2.trc_number_row = #temp.trc_number_row
--                           AND trh2.trc_number_col = #temp.trc_number_col
--                       )
-- 
--   UPDATE #temp
--      SET tra_retired = trh.trh_todate
--     FROM tariffratestlhistory trh
--    WHERE trh.tar_number = @pl_tarnum
--      AND trh.trc_number_row = #temp.trc_number_row
--      AND trh.trc_number_col = #temp.trc_number_col
--      AND getdate() BETWEEN trh_fromdate AND trh_todate
-- 
--   UPDATE #temp
--      SET tra_activedate = trh.trh_fromdate
--     FROM tariffratestlhistory trh
--    WHERE trh.tar_number = @pl_tarnum
--      AND trh.trc_number_row = #temp.trc_number_row
--      AND trh.trc_number_col = #temp.trc_number_col
--      AND getdate() BETWEEN trh_fromdate AND trh_todate
--END

SELECT tra_rate
     , trc_number_row
     , trc_number_col
     , tar_number
     , tariffrow_sequence
     , tariffcolumn_sequence
     , tra_apply
     , tra_retired
     , IsNull(tra_activedate,'19500101 00:00') tra_activedate
     , tra_minrate
     , tra_standardhours
     , tra_minqty
     , tra_rateasflat
     , tariffrow_trc_rangevalue     AS trc_rowrangevalue
     , tariffcolumn_trc_rangevalue  AS trc_colrangevalue
  FROM #temp
   
GO
GRANT EXECUTE ON  [dbo].[d_tariffratestl2_sp] TO [public]
GO
