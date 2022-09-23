SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_TestCreateRegionRate]
( @tar_number  INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_TestCreateRegionRate
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for creating Region based Row/Column rate
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @tar_number  INT OUTPUT
 *
 *
 * REVISION HISTORY:
 * PTS 63568 SPN Created 03/11/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @trk_number           INT

   DECLARE @row_abbr             VARCHAR(6)
   DECLARE @row_trc_number       INT
   DECLARE @row_trc_sequence     INT
   DECLARE @row_matchvalue       VARCHAR(50)
   DECLARE @row_rangevalue       MONEY
   DECLARE @row_multimatch       VARCHAR(255)

   DECLARE @col_abbr             VARCHAR(6)
   DECLARE @col_trc_number       INT
   DECLARE @col_trc_sequence     INT
   DECLARE @col_matchvalue       VARCHAR(50)
   DECLARE @col_rangevalue       MONEY
   DECLARE @col_multimatch       VARCHAR(255)


   DECLARE @id                   INT
   DECLARE @max_id               INT
   DECLARE @tra_rate             MONEY

   DECLARE @TableRow TABLE
   ( seq  INT   IDENTITY
   , R    VARCHAR(50)
   )

   DECLARE @TableCol TABLE
   ( seq  INT   IDENTITY
   , C    VARCHAR(50)
   )

   DECLARE @TableRowCol TABLE
   ( id     INT   IDENTITY
   , R_seq  INT
   , R      VARCHAR(50)
   , C_seq  INT
   , C      VARCHAR(50)
   )

   SELECT @row_abbr = 'TTROR'
   SELECT @col_abbr = 'TTRDR'
   SELECT @tra_rate = .90

   --Row
   INSERT INTO @TableRow
   ( R
   )
   SELECT ttr_code
     FROM ttrheader
    WHERE ttr_triptypeorregion = 'R'

   --Col
   INSERT INTO @TableCol
   ( C
   )
   SELECT ttr_code
     FROM ttrheader
    WHERE ttr_triptypeorregion = 'R'

   --Row/Column
   INSERT INTO @TableRowCol
   ( R_Seq
   , R
   , C_Seq
   , C
   )
   SELECT R.Seq
        , R.R
        , C.Seq
        , C.C
     FROM @TableRow R
        , @TableCol C

   --Create Tariff
   EXECUTE @tar_number = dbo.getsystemnumber 'TARNUM', ''

   INSERT INTO tariffheader
   ( tar_number
   , tar_description
   , cht_itemcode
   , tar_rowbasis
   , tar_colbasis
   , tar_rate
   , tar_minquantity
   , tar_mincharge
   , tar_tarriffnumber
   , tar_tariffitem
   , cht_rateunit
   , cht_unit
   , cht_currunit
   , tar_updateby
   , tar_creatdate
   , tar_updateon
   , tar_applyto_asset
   , tar_TblRatingOption
   , tar_tro_RowOrCOlumn
   , cht_class
   , cht_lh_min
   , cht_lh_rev
   , cht_lh_stl
   , cht_lh_rpt
   , cht_rollintolh
   , tar_totlh_mincharge
   , Tar_tax_id
   , tar_minqty
   , tar_zerorateisnorate
   , tar_non_billable
   , tar_external_flag
--   , tar_rowcolbasis_view
   )
   VALUES
   ( @tar_number
   , 'Test'
   , 'LHD'
   , @row_abbr
   , @col_abbr
   , 0.0000
   , 0.0000
   , 0.0000
   , 'TEST'
   , 'TEST'
   , 'MIL'
   , 'MIL'
   , 'US$'
   , User
   , GetDate()
   , GetDate()
   , 'UNK'
   , 'NONE'
   , 'N'
   , 'UNK'
   , 'Y'
   , 'Y'
   , 'Y'
   , 'Y'
   , 0
   , 0.0000
   , ''
   , 'N'
   , 'N'
   , 'N'
   , 'N'
--   , 'TABBED'
   )


   --Create Index
   EXECUTE @trk_number = dbo.getsystemnumber 'TARKEY', ''

   INSERT INTO tariffkey
   ( trk_number
   , tar_number
   , trk_startdate
   , trk_enddate
   , trk_billto
   , cmp_othertype1
   , cmp_othertype2
   , cmd_code
   , cmd_class
   , trl_type1
   , trl_type2
   , trl_type3
   , trl_type4
   , trk_revtype1
   , trk_revtype2
   , trk_revtype3
   , trk_revtype4
   , trk_originpoint
   , trk_origincity
   , trk_originzip
   , trk_originstate
   , trk_destpoint
   , trk_destcity
   , trk_destzip
   , trk_deststate
   , trk_minmiles
   , trk_minweight
   , trk_minpieces
   , trk_minvolume
   , trk_maxmiles
   , trk_maxweight
   , trk_maxpieces
   , trk_maxvolume
   , trk_duplicateseq
   , trk_primary
   , trk_minstops
   , trk_maxstops
   , trk_minodmiles
   , trk_maxodmiles
   , trk_minvariance
   , trk_maxvariance
   , trk_orderedby
   , trk_minlength
   , trk_maxlength
   , trk_minwidth
   , trk_maxwidth
   , trk_minheight
   , trk_maxheight
   , trk_origincounty
   , trk_destcounty
   , trk_company
   , trk_carrier
   , trk_lghtype1
   , trk_load
   , trk_team
   , trk_boardcarrier
   , trk_distunit
   , trk_wgtunit
   , trk_countunit
   , trk_volunit
   , trk_odunit
   , trc_type1
   , trc_type2
   , trc_type3
   , trc_type4
   , mpp_type1
   , mpp_type2
   , mpp_type3
   , mpp_type4
   , trk_stoptype
   , trk_delays
   , trk_ooamileage
   , trk_ooastop
   , trk_carryins1
   , trk_carryins2
   , trk_terms
   , trk_triptype_or_region
   , cmp_mastercompany
   , trk_fueltableid
   , trk_indexseq
   , trk_return_billto
   , trk_return_revtype1
   , trk_custdoc
   , trk_originsvccenter
   , trk_originsvcregion
   , trk_destsvccenter
   , trk_destsvcregion
   , billto_othertype1
   , billto_othertype2
   , trk_mincarriersvcdays
   , trk_maxcarriersvcdays
   , trk_lghtype2
   , trk_pallet_type
   , trk_pallet_count
--   , trk_servicelevel
   )
   VALUES
   ( @trk_number
   , @tar_number
   , {ts '1950-01-01 00:00:00.000'}
   , {ts '2049-12-31 23:59:00.000'}
   , 'UNKNOWN'
   , 'UNK'
   , 'UNK'
   , 'UNKNOWN'
   , 'UNKNOWN'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNKNOWN'
   , 0
   , 'UNKNOWN'
   , 'XX'
   , 'UNKNOWN'
   , 0
   , 'UNKNOWN'
   , 'XX'
   , 0
   , 0.0000
   , 0
   , 0.0000
   , 2147483647
   , 2147483647.0000
   , 2147483647, 2147483647.0000
   , 1
   , 'Y'
   , 0
   , 2147483647
   , 0
   , 2147483647
   , 0.0000
   , 2147483647.0000
   , 'UNKNOWN'
   , 0.0000
   , 2147483647.0000
   , 0.0000
   , 2147483647.0000
   , 0.0000
   , 2147483647.0000
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNKNOWN'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'MIL'
   , 'LBS'
   , 'PCS'
   , 'GAL'
   , 'MIL'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 0
   , 0
   , 0
   , 0
   , 'UNK'
   , 'X'
   , 'UNKNOWN'
   , 'UNKNOWN'
   , 1
   , 'UNKNOWN'
   , 'UNK'
   , 0
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 'UNK'
   , 0
   , 2147483647
   , 'UNK'
   , 'UNK'
   , 0
--   , 'UNK'
   )


   --Create Matrix
   SELECT @max_id = Count(1) FROM @TableRowCol
   SELECT @id = 0
   WHILE @id < @max_id
   BEGIN
      SELECT @id = @id + 1

      SELECT @row_trc_sequence   = R_seq
           , @row_matchvalue     = R
           , @row_rangevalue     = 2147483647.00
           , @row_multimatch     = NULL
           , @col_trc_sequence   = C_seq
           , @col_matchvalue     = C
           , @col_rangevalue     = 2147483647.00
           , @col_multimatch     = NULL
        FROM @TableRowCol
       WHERE id = @id

      --Create ROW Def
      IF @row_abbr <> 'NOT'
         IF NOT EXISTS (SELECT 1 FROM tariffrowcolumn WHERE tar_number = @tar_number AND trc_rowcolumn = 'R' AND trc_sequence = @row_trc_sequence)
            BEGIN
               EXECUTE @row_trc_number = dbo.getsystemnumber 'TARRC', ''

               INSERT INTO tariffrowcolumn
               ( tar_number
               , trc_number
               , trc_sequence
               , trc_rowcolumn
               , trc_matchvalue
               , trc_rangevalue
               , trc_multimatch
               , last_updateby
               , last_updatedate
               )
               VALUES
               ( @tar_number
               , @row_trc_number
               , @row_trc_sequence
               , 'R'
               , @row_matchvalue
               , @row_rangevalue
               , @row_multimatch
               , User
               , GetDate()
               )
            END
         ELSE
            BEGIN
               SELECT @row_trc_number = trc_number FROM tariffrowcolumn WHERE tar_number = @tar_number AND trc_rowcolumn = 'R' AND trc_sequence = @row_trc_sequence
            END

      --Create COL Def
      IF @col_abbr <> 'NOT'
         IF NOT EXISTS (SELECT 1 FROM tariffrowcolumn WHERE tar_number = @tar_number AND trc_rowcolumn = 'C' AND trc_sequence = @col_trc_sequence)
            BEGIN
               EXECUTE @col_trc_number = dbo.getsystemnumber 'TARRC', ''

               INSERT INTO tariffrowcolumn
               ( tar_number
               , trc_number
               , trc_sequence
               , trc_rowcolumn
               , trc_matchvalue
               , trc_rangevalue
               , trc_multimatch
               , last_updateby
               , last_updatedate
               )
               VALUES
               ( @tar_number
               , @col_trc_number
               , @col_trc_sequence
               , 'C'
               , @col_matchvalue
               , @col_rangevalue
               , @col_multimatch
               , User
               , GetDate()
               )
            END
         ELSE
            BEGIN
               SELECT @col_trc_number = trc_number FROM tariffrowcolumn WHERE tar_number = @tar_number AND trc_rowcolumn = 'C' AND trc_sequence = @col_trc_sequence
            END

      --Create Rate
      If @row_trc_number IS NULL
        SELECT @row_trc_number = 0
      If @col_trc_number IS NULL
        SELECT @col_trc_number = 0
      SELECT @tra_rate = @tra_rate + .10

      INSERT INTO tariffrate
      ( tar_number
      , trc_number_row
      , trc_number_col
      , tra_rate
      , tra_apply
      , tra_retired
      , tra_activedate
      , tra_rateasflat
      , tra_minrate
      , tra_minqty
      , last_updateby
      , last_updatedate
      )
      VALUES
      ( @tar_number
      , @row_trc_number
      , @col_trc_number
      , @tra_rate
      , NULL
      , NULL
      , NULL
      , 'N'
      , NULL
      , 'N'
      , user
      , GetDate()
      )

   END
   --Loop

END
GO
GRANT EXECUTE ON  [dbo].[sp_TestCreateRegionRate] TO [public]
GO
