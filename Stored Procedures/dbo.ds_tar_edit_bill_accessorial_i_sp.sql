SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_tar_edit_bill_accessorial_i_sp]
( @primary_tar_number      INT
, @acc_trk_tar_number      INT
, @acc_trk_trk_number      INT
, @acc_tar_description     VARCHAR(50)    = NULL
, @acc_cht_itemcode        VARCHAR(6)     = NULL
, @acc_tar_rate            MONEY          = NULL
, @acc_cht_rateunit        VARCHAR(6)     = NULL
, @acc_cht_unit            VARCHAR(6)     = NULL
, @acc_cht_rollintolh      INT            = NULL
, @taa_taa_seq             INT            = NULL
, @acc_trk_startdate       DATETIME       = NULL
, @acc_trk_enddate         DATETIME       = NULL
) AS

/**
 *
 * NAME:
 * dbo.ds_tar_edit_bill_accessorial_i_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for inserting into tables tariffaccessorial, tariffkey and tariffheader
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @primary_tar_number      INT
 * @acc_trk_tar_number      INT
 * @acc_trk_trk_number      INT
 * @acc_tar_description     VARCHAR(50)    = NULL
 * @acc_cht_itemcode        VARCHAR(6)     = NULL
 * @acc_tar_rate            MONEY          = NULL
 * @acc_cht_rateunit        VARCHAR(6)     = NULL
 * @acc_cht_unit            VARCHAR(6)     = NULL
 * @acc_cht_rollintolh      INT            = NULL
 * @taa_taa_seq             INT            = NULL
 * @acc_trk_startdate       DATETIME       = NULL
 * @acc_trk_enddate         DATETIME       = NULL
 *
 *
 * REVISION HISTORY:
 * PTS 62530 SPN Created 05/23/12
 *
 **/

SET NOCOUNT ON

BEGIN

   --TariffHeader for Accessorial
   DECLARE @acc_tar_rowbasis           CHAR(6)
   DECLARE @acc_tar_colbasis           CHAR(6)
   DECLARE @acc_tar_minquantity        DECIMAL(19,4)
   DECLARE @acc_tar_mincharge          MONEY
   DECLARE @acc_cht_currunit           VARCHAR(6)
   DECLARE @acc_tar_applyto_asset      CHAR(3)
   DECLARE @acc_tar_tblratingoption    VARCHAR(6)
   DECLARE @acc_tar_tro_roworcolumn    CHAR(1)
   DECLARE @acc_cht_class              VARCHAR(6)
   DECLARE @acc_cht_lh_min             CHAR(1)
   DECLARE @acc_cht_lh_rev             CHAR(1)
   DECLARE @acc_cht_lh_stl             CHAR(1)
   DECLARE @acc_cht_lh_rpt             CHAR(1)
   DECLARE @acc_tar_totlh_mincharge    MONEY
   DECLARE @acc_tar_minqty             CHAR(1)
   DECLARE @acc_tar_non_billable       CHAR(1)
   DECLARE @acc_tar_zerorateisnorate   CHAR(1)
   DECLARE @acc_tar_external_flag      CHAR(1)
   DECLARE @acc_tar_rowcolbasis_view   VARCHAR(10)
   DECLARE @acc_tar_maxquantity        DECIMAL(19,4)
   DECLARE @acc_tar_maxcharge          MONEY
   DECLARE @acc_tar_type               CHAR(1)

   --TariffKey for Accessorial
   DECLARE @acc_trk_billto             CHAR(8)
   DECLARE @acc_cmp_othertype1         CHAR(6)
   DECLARE @acc_cmp_othertype2         CHAR(6)
   DECLARE @acc_cmd_code               CHAR(8)
   DECLARE @acc_cmd_class              CHAR(8)
   DECLARE @acc_trl_type1              CHAR(6)
   DECLARE @acc_trl_type2              CHAR(6)
   DECLARE @acc_trl_type3              CHAR(6)
   DECLARE @acc_trl_type4              CHAR(6)
   DECLARE @acc_trk_revtype1           CHAR(6)
   DECLARE @acc_trk_revtype2           CHAR(6)
   DECLARE @acc_trk_revtype3           CHAR(6)
   DECLARE @acc_trk_revtype4           CHAR(6)
   DECLARE @acc_trk_originpoint        CHAR(8)
   DECLARE @acc_trk_origincity         INT
   DECLARE @acc_trk_originzip          CHAR(10)
   DECLARE @acc_trk_originstate        CHAR(6)
   DECLARE @acc_trk_destpoint          CHAR(8)
   DECLARE @acc_trk_destcity           INT
   DECLARE @acc_trk_destzip            CHAR(10)
   DECLARE @acc_trk_deststate          CHAR(6)
   DECLARE @acc_trk_minmiles           INT
   DECLARE @acc_trk_minweight          DECIMAL(19,4)
   DECLARE @acc_trk_minpieces          INT
   DECLARE @acc_trk_minvolume          DECIMAL(19,4)
   DECLARE @acc_trk_maxmiles           INT
   DECLARE @acc_trk_maxweight          DECIMAL(19,4)
   DECLARE @acc_trk_duplicateseq       INT
   DECLARE @acc_trk_primary            CHAR(1)
   DECLARE @acc_trk_minstops           INT
   DECLARE @acc_trk_maxstops           INT
   DECLARE @acc_trk_minodmiles         INT
   DECLARE @acc_trk_maxodmiles         INT
   DECLARE @acc_trk_minvariance        MONEY
   DECLARE @acc_trk_maxvariance        MONEY
   DECLARE @acc_trk_orderedby          VARCHAR(8)
   DECLARE @acc_trk_minlength          MONEY
   DECLARE @acc_trk_maxlength          MONEY
   DECLARE @acc_trk_minwidth           MONEY
   DECLARE @acc_trk_maxwidth           MONEY
   DECLARE @acc_trk_minheight          MONEY
   DECLARE @acc_trk_maxheight          MONEY
   DECLARE @acc_trk_origincounty       CHAR(3)
   DECLARE @acc_trk_destcounty         CHAR(3)
   DECLARE @acc_trk_company            VARCHAR(8)
   DECLARE @acc_trk_carrier            VARCHAR(8)
   DECLARE @acc_trk_lghtype1           CHAR(6)
   DECLARE @acc_trk_load               CHAR(6)
   DECLARE @acc_trk_team               CHAR(6)
   DECLARE @acc_trk_boardcarrier       CHAR(6)
   DECLARE @acc_mpp_type1              VARCHAR(6)
   DECLARE @acc_mpp_type2              VARCHAR(6)
   DECLARE @acc_mpp_type3              VARCHAR(6)
   DECLARE @acc_mpp_type4              VARCHAR(6)
   DECLARE @acc_trc_type1              VARCHAR(6)
   DECLARE @acc_trc_type2              VARCHAR(6)
   DECLARE @acc_trc_type3              VARCHAR(6)
   DECLARE @acc_trc_type4              VARCHAR(6)
   DECLARE @acc_trk_stoptype           VARCHAR(6)
   DECLARE @acc_trk_delays             VARCHAR(6)
   DECLARE @acc_trk_ooamileage         INT
   DECLARE @acc_trk_ooastop            INT
   DECLARE @acc_trk_carryins1          INT
   DECLARE @acc_trk_carryins2          INT
   DECLARE @acc_cmp_mastercompany      VARCHAR(8)
   DECLARE @acc_trk_minrevpermile      MONEY
   DECLARE @acc_trk_maxrevpermile      MONEY
   DECLARE @acc_trk_stp_event          VARCHAR(6)
   DECLARE @acc_trk_custdoc            INT
   DECLARE @acc_trk_partytobill_id     VARCHAR(8)
   DECLARE @acc_trk_thirdparty         VARCHAR(8)
   DECLARE @acc_trk_lghtype2           VARCHAR(6)
   DECLARE @acc_trk_lghtype3           VARCHAR(6)
   DECLARE @acc_trk_lghtype4           VARCHAR(6)
   DECLARE @acc_trk_thirdpartytype     VARCHAR(12)
   DECLARE @acc_trk_minsegments        INT
   DECLARE @acc_trk_maxsegments        INT
   DECLARE @acc_billto_othertype1      VARCHAR(6)
   DECLARE @acc_billto_othertype2      VARCHAR(6)
   DECLARE @acc_stop_othertype1        VARCHAR(6)
   DECLARE @acc_stop_othertype2        VARCHAR(6)
   DECLARE @acc_trk_usefor_billable    INT
   DECLARE @acc_trk_mincarriersvcdays  INT
   DECLARE @acc_trk_maxcarriersvcdays  INT

   --Data Validation
   IF @primary_tar_number IS NULL OR @primary_tar_number <= 0
      BEGIN
         RAISERROR('A Primary Tariff# is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM tariffheader WITH (NOLOCK)
                   WHERE tar_number = @primary_tar_number
                 )
      BEGIN
         RAISERROR('Primary Tariff# not found',16,1)
         RETURN
      END

   IF @acc_trk_tar_number IS NULL OR @acc_trk_tar_number <= 0
      BEGIN
         RAISERROR('A Secondary Tariff# is required',16,1)
         RETURN
      END

   IF @acc_trk_trk_number IS NULL OR @acc_trk_trk_number <= 0
      BEGIN
         RAISERROR('A Secondary Tariff Key is required',16,1)
         RETURN
      END

   IF @acc_cht_itemcode IS NULL OR @acc_cht_itemcode = ''
      BEGIN
         RAISERROR('ItemCode cannot be blank',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM chargetype WITH (NOLOCK)
                   WHERE cht_itemcode = @acc_cht_itemcode
                 )
      BEGIN
         RAISERROR('ItemCode not found',16,1)
         RETURN
      END

   --Default Values for Tariffheader
   SELECT @acc_tar_rowbasis          = 'NOT'
        , @acc_tar_colbasis          = 'NOT'
        , @acc_tar_minquantity       = 0
        , @acc_tar_mincharge         = 0
        , @acc_cht_currunit          = 'US$'
        , @acc_tar_applyto_asset     = 'UNK'
        , @acc_tar_tblratingoption   = 'NONE'
        , @acc_tar_tro_roworcolumn   = 'N'
        , @acc_cht_class             = 'UNK'
        , @acc_cht_lh_min            = 'Y'
        , @acc_cht_lh_rev            = 'Y'
        , @acc_cht_lh_stl            = 'Y'
        , @acc_cht_lh_rpt            = 'Y'
        , @acc_tar_totlh_mincharge   = 0
        , @acc_tar_minqty            = 'N'
        , @acc_tar_non_billable      = 'N'
        , @acc_tar_zerorateisnorate  = 'N'
        , @acc_tar_external_flag     = 'N'
        , @acc_tar_rowcolbasis_view  = 'TABBED'
        , @acc_tar_maxquantity       = 0
        , @acc_tar_maxcharge         = 0
        , @acc_tar_type              = 'T'

   --Default Values for Tariffkey
   SELECT @acc_trk_billto            = 'UNKNOWN'
        , @acc_cmp_othertype1        = 'UNK'
        , @acc_cmp_othertype2        = 'UNK'
        , @acc_cmd_code              = 'UNKNOWN'
        , @acc_cmd_class             = 'UNKNOWN'
        , @acc_trl_type1             = 'UNK'
        , @acc_trl_type2             = 'UNK'
        , @acc_trl_type3             = 'UNK'
        , @acc_trl_type4             = 'UNK'
        , @acc_trk_revtype1          = 'UNK'
        , @acc_trk_revtype2          = 'UNK'
        , @acc_trk_revtype3          = 'UNK'
        , @acc_trk_revtype4          = 'UNK'
        , @acc_trk_originpoint       = 'UNKNOWN'
        , @acc_trk_origincity        = 0
        , @acc_trk_originzip         = 'UNKNOWN'
        , @acc_trk_originstate       = 'XX'
        , @acc_trk_destpoint         = 'UNKNOWN'
        , @acc_trk_destcity          = 0
        , @acc_trk_destzip           = 'UNKNOWN'
        , @acc_trk_deststate         = 'XX'
        , @acc_trk_minmiles          = 0
        , @acc_trk_minweight         = 0.0000
        , @acc_trk_minpieces         = 0
        , @acc_trk_minvolume         = 0.0000
        , @acc_trk_maxmiles          = 2147483647
        , @acc_trk_maxweight         = 2147483647.0000
        , @acc_trk_duplicateseq      = 1
        , @acc_trk_primary           = 'N'
        , @acc_trk_minstops          = 0
        , @acc_trk_maxstops          = 2147483647
        , @acc_trk_minodmiles        = 0
        , @acc_trk_maxodmiles        = 2147483647
        , @acc_trk_minvariance       = 0
        , @acc_trk_maxvariance       = 2147483647.00
        , @acc_trk_orderedby         = 'UNKNOWN'
        , @acc_trk_minlength         = 0.00
        , @acc_trk_maxlength         = 2147483647.00
        , @acc_trk_minwidth          = 0.00
        , @acc_trk_maxwidth          = 2147483647.00
        , @acc_trk_minheight         = 0.00
        , @acc_trk_maxheight         = 2147483647.00
        , @acc_trk_origincounty      = 'UNK'
        , @acc_trk_destcounty        = 'UNK'
        , @acc_trk_company           = 'UNK'
        , @acc_trk_carrier           = 'UNKNOWN'
        , @acc_trk_lghtype1          = 'UNK'
        , @acc_trk_load              = 'LD'
        , @acc_trk_team              = 'UNK'
        , @acc_trk_boardcarrier      = 'UNK'
        , @acc_mpp_type1             = 'UNK'
        , @acc_mpp_type2             = 'UNK'
        , @acc_mpp_type3             = 'UNK'
        , @acc_mpp_type4             = 'UNK'
        , @acc_trc_type1             = 'UNK'
        , @acc_trc_type2             = 'UNK'
        , @acc_trc_type3             = 'UNK'
        , @acc_trc_type4             = 'UNK'
        , @acc_trk_stoptype          = 'UNK'
        , @acc_trk_delays            = 'UNK'
        , @acc_trk_ooamileage        = 0
        , @acc_trk_ooastop           = 0
        , @acc_trk_carryins1         = 0
        , @acc_trk_carryins2         = 0
        , @acc_cmp_mastercompany     = 'UNKNOWN'
        , @acc_trk_minrevpermile     = 0.00
        , @acc_trk_maxrevpermile     = 2147483647.00
        , @acc_trk_stp_event         = 'UNK'
        , @acc_trk_custdoc           = 0
        , @acc_trk_partytobill_id    = 'UNKNOWN'
        , @acc_trk_thirdparty        = 'UNKNOWN'
        , @acc_trk_lghtype2          = 'UNK'
        , @acc_trk_lghtype3          = 'UNK'
        , @acc_trk_lghtype4          = 'UNK'
        , @acc_trk_thirdpartytype    = 'UNKNOWN'
        , @acc_trk_minsegments       = 1
        , @acc_trk_maxsegments       = 2147483647
        , @acc_billto_othertype1     = 'UNK'
        , @acc_billto_othertype2     = 'UNK'
        , @acc_stop_othertype1       = 'UNK'
        , @acc_stop_othertype2       = 'UNK'
        , @acc_trk_usefor_billable   = 0
        , @acc_trk_mincarriersvcdays = 0
        , @acc_trk_maxcarriersvcdays = 2147483647

   --Insert or Update Tariffheader
   IF EXISTS (SELECT 1
                FROM tariffheader WITH (NOLOCK)
               WHERE tar_number = @acc_trk_tar_number
             )
      BEGIN
         UPDATE tariffheader
            SET tar_description        = @acc_tar_description
              , cht_itemcode           = @acc_cht_itemcode
              , cht_unit               = @acc_cht_unit
              , tar_rate               = @acc_tar_rate
              , cht_rateunit           = @acc_cht_rateunit
              , cht_rollintolh         = @acc_cht_rollintolh
          WHERE tar_number = @acc_trk_tar_number
      END
   ELSE
      BEGIN
         INSERT INTO tariffheader
         ( tar_number
         , tar_description
         , cht_itemcode
         , cht_unit
         , tar_rate
         , cht_rateunit
         , cht_rollintolh
         , tar_rowbasis
         , tar_colbasis
         , tar_minquantity
         , tar_mincharge
         , cht_currunit
         , tar_applyto_asset
         , tar_tblratingoption
         , tar_tro_roworcolumn
         , cht_class
         , cht_lh_min
         , cht_lh_rev
         , cht_lh_stl
         , cht_lh_rpt
         , tar_totlh_mincharge
         , tar_minqty
         , tar_non_billable
         , tar_zerorateisnorate
         , tar_external_flag
         , tar_rowcolbasis_view
         , tar_maxquantity
         , tar_maxcharge
         , tar_type
         )
         VALUES
         ( @acc_trk_tar_number
         , @acc_tar_description
         , @acc_cht_itemcode
         , @acc_cht_unit
         , @acc_tar_rate
         , @acc_cht_rateunit
         , @acc_cht_rollintolh
         , @acc_tar_rowbasis
         , @acc_tar_colbasis
         , @acc_tar_minquantity
         , @acc_tar_mincharge
         , @acc_cht_currunit
         , @acc_tar_applyto_asset
         , @acc_tar_tblratingoption
         , @acc_tar_tro_roworcolumn
         , @acc_cht_class
         , @acc_cht_lh_min
         , @acc_cht_lh_rev
         , @acc_cht_lh_stl
         , @acc_cht_lh_rpt
         , @acc_tar_totlh_mincharge
         , @acc_tar_minqty
         , @acc_tar_non_billable
         , @acc_tar_zerorateisnorate
         , @acc_tar_external_flag
         , @acc_tar_rowcolbasis_view
         , @acc_tar_maxquantity
         , @acc_tar_maxcharge
         , @acc_tar_type
         )
      END

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
   , mpp_type1
   , mpp_type2
   , mpp_type3
   , mpp_type4
   , trc_type1
   , trc_type2
   , trc_type3
   , trc_type4
   , trk_stoptype
   , trk_delays
   , trk_ooamileage
   , trk_ooastop
   , trk_carryins1
   , trk_carryins2
   , cmp_mastercompany
   , trk_minrevpermile
   , trk_maxrevpermile
   , trk_stp_event
   , trk_custdoc
   , trk_partytobill_id
   , trk_thirdparty
   , trk_lghtype2
   , trk_lghtype3
   , trk_lghtype4
   , trk_thirdpartytype
   , trk_minsegments
   , trk_maxsegments
   , billto_othertype1
   , billto_othertype2
   , stop_othertype1
   , stop_othertype2
   , trk_usefor_billable
   , trk_mincarriersvcdays
   , trk_maxcarriersvcdays
   )
   VALUES
   ( @acc_trk_trk_number
   , @acc_trk_tar_number
   , @acc_trk_startdate
   , @acc_trk_enddate
   , @acc_trk_billto
   , @acc_cmp_othertype1
   , @acc_cmp_othertype2
   , @acc_cmd_code
   , @acc_cmd_class
   , @acc_trl_type1
   , @acc_trl_type2
   , @acc_trl_type3
   , @acc_trl_type4
   , @acc_trk_revtype1
   , @acc_trk_revtype2
   , @acc_trk_revtype3
   , @acc_trk_revtype4
   , @acc_trk_originpoint
   , @acc_trk_origincity
   , @acc_trk_originzip
   , @acc_trk_originstate
   , @acc_trk_destpoint
   , @acc_trk_destcity
   , @acc_trk_destzip
   , @acc_trk_deststate
   , @acc_trk_minmiles
   , @acc_trk_minweight
   , @acc_trk_minpieces
   , @acc_trk_minvolume
   , @acc_trk_maxmiles
   , @acc_trk_maxweight
   , @acc_trk_duplicateseq
   , @acc_trk_primary
   , @acc_trk_minstops
   , @acc_trk_maxstops
   , @acc_trk_minodmiles
   , @acc_trk_maxodmiles
   , @acc_trk_minvariance
   , @acc_trk_maxvariance
   , @acc_trk_orderedby
   , @acc_trk_minlength
   , @acc_trk_maxlength
   , @acc_trk_minwidth
   , @acc_trk_maxwidth
   , @acc_trk_minheight
   , @acc_trk_maxheight
   , @acc_trk_origincounty
   , @acc_trk_destcounty
   , @acc_trk_company
   , @acc_trk_carrier
   , @acc_trk_lghtype1
   , @acc_trk_load
   , @acc_trk_team
   , @acc_trk_boardcarrier
   , @acc_mpp_type1
   , @acc_mpp_type2
   , @acc_mpp_type3
   , @acc_mpp_type4
   , @acc_trc_type1
   , @acc_trc_type2
   , @acc_trc_type3
   , @acc_trc_type4
   , @acc_trk_stoptype
   , @acc_trk_delays
   , @acc_trk_ooamileage
   , @acc_trk_ooastop
   , @acc_trk_carryins1
   , @acc_trk_carryins2
   , @acc_cmp_mastercompany
   , @acc_trk_minrevpermile
   , @acc_trk_maxrevpermile
   , @acc_trk_stp_event
   , @acc_trk_custdoc
   , @acc_trk_partytobill_id
   , @acc_trk_thirdparty
   , @acc_trk_lghtype2
   , @acc_trk_lghtype3
   , @acc_trk_lghtype4
   , @acc_trk_thirdpartytype
   , @acc_trk_minsegments
   , @acc_trk_maxsegments
   , @acc_billto_othertype1
   , @acc_billto_othertype2
   , @acc_stop_othertype1
   , @acc_stop_othertype2
   , @acc_trk_usefor_billable
   , @acc_trk_mincarriersvcdays
   , @acc_trk_maxcarriersvcdays
   )

   --TariffAccessorial
   INSERT INTO tariffaccessorial
   ( tar_number
   , trk_number
   , taa_seq
   )
   VALUES
   ( @primary_tar_number
   , @acc_trk_trk_number
   , @taa_taa_seq
   )

END
GO
GRANT EXECUTE ON  [dbo].[ds_tar_edit_bill_accessorial_i_sp] TO [public]
GO
