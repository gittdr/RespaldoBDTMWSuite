SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_stl_lookup_by_pyd_carinvnum_lgh_number_sp]
   @as_pyd_carinvnum  VARCHAR(30)
AS

/**
 * 
 * NAME:
 * d_stl_lookup_by_pyd_carinvnum_lgh_number_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns lgh_numbers to be displayed in the LGH Number Selection Window in the Trip Folder
 *
 * RETURNS: NONE
 *
 * RESULT SETS: Set of lgh_numbers to be displayed
 *
 * PARAMETERS:
 * @as_pyd_carinvnum_numumber    VARCHAR(30) paydetails.pyd_carinvnum
 *
 * REVISION HISTORY:
 * 11/04/2010 PTS52686 - Suprakash Nandan Created Procedure
 *
 **/
DECLARE
   @ls_pyd_carinvnum VARCHAR(30)

BEGIN

   SET @ls_pyd_carinvnum = @as_pyd_carinvnum

   If CHARINDEX(@ls_pyd_carinvnum, '%') <= 0
      SET @ls_pyd_carinvnum = @ls_pyd_carinvnum + '%'

   --Create Temp Table
   CREATE TABLE #temp
      ( pyd_carinvnum         VARCHAR(30) NULL
      , lgh_number            INT         NULL
      , mov_number            INT         NULL
      , ord_hdrnumber         INT         NULL
      , ord_number            VARCHAR(12) NULL
      , ord_billto            VARCHAR(8)  NULL
      , ord_status            VARCHAR(6)  NULL
      , ord_startdate         DATETIME    NULL
      , ord_completiondate    DATETIME    NULL
      , ord_driver1           VARCHAR(8)  NULL
      , ord_driver2           VARCHAR(8)  NULL
      , ord_tractor           VARCHAR(8)  NULL
      , ord_trailer           VARCHAR(13) NULL
      , ord_carrier           VARCHAR(8)  NULL
      )

   INSERT INTO #temp
      ( pyd_carinvnum
      , lgh_number
      , mov_number
      , ord_hdrnumber
      , ord_number
      , ord_billto
      , ord_status
      , ord_startdate
      , ord_completiondate
      , ord_driver1
      , ord_driver2
      , ord_tractor
      , ord_trailer
      , ord_carrier
      )
   SELECT DISTINCT
          p.pyd_carinvnum
        , l.lgh_number
        , o.mov_number
        , o.ord_hdrnumber
        , o.ord_number
        , o.ord_billto
        , o.ord_status
        , o.ord_startdate
        , o.ord_completiondate
        , l.lgh_driver1
        , l.lgh_driver2
        , l.lgh_tractor
        , (CASE WHEN p.asgn_type = 'TRL' THEN p.asgn_id ELSE 'UNKNOWN' END) as trailer
        , l.lgh_carrier
     FROM paydetail p
     JOIN orderheader o ON p.ord_hdrnumber = o.ord_hdrnumber
     JOIN legheader l ON p.lgh_number = l.lgh_number
    WHERE p.pyd_carinvnum LIKE @ls_pyd_carinvnum

   SELECT * FROM #temp

   RETURN

END

GO
GRANT EXECUTE ON  [dbo].[d_stl_lookup_by_pyd_carinvnum_lgh_number_sp] TO [public]
GO
