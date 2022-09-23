SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[dddw_ttrheader_region_sp] AS

/**
 *
 * NAME:
 * dbo.dddw_ttrheader_region_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow dddw_ttrheader_region
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 *
 * REVISION HISTORY:
 * PTS 55666 SPN Created 03/22/11
 * 
 **/

SET NOCOUNT ON

BEGIN

   CREATE TABLE #tmp
   ( ttr_number            INT          NULL
   , ttr_triptypeorregion  CHAR(1)      NULL
   , ttr_code              VARCHAR(10)  NULL
   , ttr_name              VARCHAR(30)  NULL
   , ttr_comment           VARCHAR(254) NULL
   , ttr_addon          DATETIME     NULL
   , ttr_updateon       DATETIME     NULL
   , ttr_updateby       VARCHAR(8)   NULL
   , ttr_startdate         DATETIME     NULL
   , ttr_enddate        DATETIME     NULL
   , ttr_billto         VARCHAR(8)   NULL
   , displayname        VARCHAR(50)  NULL
   )

   INSERT #tmp
   ( ttr_number
   , ttr_triptypeorregion
   , ttr_code
   , ttr_name
   , ttr_comment
   , ttr_addon
   , ttr_updateon
   , ttr_updateby
   , ttr_startdate
   , ttr_enddate
   , ttr_billto
   , displayname
   )
   EXEC ttrheaderdddw_sp 'R'

   INSERT INTO #tmp
   ( ttr_number
   , ttr_triptypeorregion
   , ttr_code
   , ttr_name
   , ttr_comment
   , ttr_addon
   , ttr_updateon
   , ttr_updateby
   , ttr_startdate
   , ttr_enddate
   , ttr_billto
   , displayname
   )
   VALUES
   ( -1
   , 'R'
   , 'UNK'
   , 'UNKNOWN'
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , 'UNK - UNKNOWN'
   )

   SELECT * FROM #tmp

END
GO
GRANT EXECUTE ON  [dbo].[dddw_ttrheader_region_sp] TO [public]
GO
