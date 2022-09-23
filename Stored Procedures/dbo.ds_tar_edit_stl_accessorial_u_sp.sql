SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_tar_edit_stl_accessorial_u_sp]
( @primary_tar_number      INT
, @acc_trk_tar_number      INT
, @acc_trk_trk_number      INT
, @acc_tar_description     VARCHAR(50)
, @acc_cht_itemcode        VARCHAR(6)
, @acc_tar_rate            MONEY
, @acc_cht_rateunit        VARCHAR(6)
, @acc_cht_unit            VARCHAR(6)
, @taa_taa_seq             INT
, @acc_trk_startdate       DATETIME
, @acc_trk_enddate         DATETIME
) AS

/**
 *
 * NAME:
 * dbo.ds_tar_edit_stl_accessorial_u_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for updating tables tariffaccessorialstl, tariffkey and tariffheaderstl
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

   --TariffheaderStl for Accessorial
   DECLARE @acc_tar_rowbasis           CHAR(6)
   DECLARE @acc_tar_colbasis           CHAR(6)
   DECLARE @acc_tar_minquantity        DECIMAL(19,4)
   DECLARE @acc_tar_mincharge          MONEY
   DECLARE @acc_cht_currunit           VARCHAR(6)
   DECLARE @acc_tar_applyto_asset      CHAR(3)
   DECLARE @acc_tar_tblratingoption    VARCHAR(6)
   DECLARE @acc_tar_tro_roworcolumn    CHAR(1)
   DECLARE @acc_tar_minqty             CHAR(1)
   DECLARE @acc_tar_zerorateisnorate   CHAR(1)
   DECLARE @acc_tar_external_flag      CHAR(1)
   DECLARE @acc_tar_maxquantity        DECIMAL(19,4)
   DECLARE @acc_tar_maxcharge          MONEY

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
                    FROM tariffheaderstl WITH (NOLOCK)
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

   IF NOT EXISTS (SELECT 1
                    FROM tariffheaderstl WITH (NOLOCK)
                   WHERE tar_number = @acc_trk_tar_number
                 )
      BEGIN
         RAISERROR('Secondary Tariff# not found',16,1)
         RETURN
      END

   IF @acc_trk_trk_number IS NULL OR @acc_trk_trk_number <= 0
      BEGIN
         RAISERROR('A Secondary Tariff Key is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM tariffkey WITH (NOLOCK)
                   WHERE trk_number = @acc_trk_trk_number
                 )
      BEGIN
         RAISERROR('Secondary Tariff Key not found',16,1)
         RETURN
      END

   IF @acc_cht_itemcode IS NULL OR @acc_cht_itemcode = ''
      BEGIN
         RAISERROR('ItemCode cannot be blank',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM paytype WITH (NOLOCK)
                   WHERE pyt_itemcode = @acc_cht_itemcode
                 )
      BEGIN
         RAISERROR('ItemCode not found',16,1)
         RETURN
      END

   --Current Values from TariffheaderStl
   SELECT @acc_tar_rowbasis          = tar_rowbasis
        , @acc_tar_colbasis          = tar_colbasis
        , @acc_tar_minquantity       = tar_minquantity
        , @acc_tar_mincharge         = tar_mincharge
        , @acc_cht_currunit          = cht_currunit
        , @acc_tar_applyto_asset     = tar_applyto_asset
        , @acc_tar_tblratingoption   = tar_tblratingoption
        , @acc_tar_tro_roworcolumn   = tar_tro_roworcolumn
        , @acc_tar_minqty            = tar_minqty
        , @acc_tar_zerorateisnorate  = tar_zerorateisnorate
        , @acc_tar_external_flag     = tar_external_flag
        , @acc_tar_maxquantity       = tar_maxquantity
        , @acc_tar_maxcharge         = tar_maxcharge
     FROM tariffheaderstl
    WHERE tar_number = @acc_trk_tar_number

   --Current Values from Tariffkey
   SELECT @acc_trk_billto            = trk_billto
        , @acc_cmp_othertype1        = cmp_othertype1
        , @acc_cmp_othertype2        = cmp_othertype2
        , @acc_cmd_code              = cmd_code
        , @acc_cmd_class             = cmd_class
        , @acc_trl_type1             = trl_type1
        , @acc_trl_type2             = trl_type2
        , @acc_trl_type3             = trl_type3
        , @acc_trl_type4             = trl_type4
        , @acc_trk_revtype1          = trk_revtype1
        , @acc_trk_revtype2          = trk_revtype2
        , @acc_trk_revtype3          = trk_revtype3
        , @acc_trk_revtype4          = trk_revtype4
        , @acc_trk_originpoint       = trk_originpoint
        , @acc_trk_origincity        = trk_origincity
        , @acc_trk_originzip         = trk_originzip
        , @acc_trk_originstate       = trk_originstate
        , @acc_trk_destpoint         = trk_destpoint
        , @acc_trk_destcity          = trk_destcity
        , @acc_trk_destzip           = trk_destzip
        , @acc_trk_deststate         = trk_deststate
        , @acc_trk_minmiles          = trk_minmiles
        , @acc_trk_minweight         = trk_minweight
        , @acc_trk_minpieces         = trk_minpieces
        , @acc_trk_minvolume         = trk_minvolume
        , @acc_trk_maxmiles          = trk_maxmiles
        , @acc_trk_maxweight         = trk_maxweight
        , @acc_trk_duplicateseq      = trk_duplicateseq
        , @acc_trk_primary           = trk_primary
        , @acc_trk_minstops          = trk_minstops
        , @acc_trk_maxstops          = trk_maxstops
        , @acc_trk_minodmiles        = trk_minodmiles
        , @acc_trk_maxodmiles        = trk_maxodmiles
        , @acc_trk_minvariance       = trk_minvariance
        , @acc_trk_maxvariance       = trk_maxvariance
        , @acc_trk_orderedby         = trk_orderedby
        , @acc_trk_minlength             = trk_minlength
        , @acc_trk_maxlength         = trk_maxlength
        , @acc_trk_minwidth          = trk_minwidth
        , @acc_trk_maxwidth          = trk_maxwidth
        , @acc_trk_minheight         = trk_minheight
        , @acc_trk_maxheight         = trk_maxheight
        , @acc_trk_origincounty      = trk_origincounty
        , @acc_trk_destcounty        = trk_destcounty
        , @acc_trk_company           = trk_company
        , @acc_trk_carrier           = trk_carrier
        , @acc_trk_lghtype1          = trk_lghtype1
        , @acc_trk_load              = trk_load
        , @acc_trk_team              = trk_team
        , @acc_trk_boardcarrier      = trk_boardcarrier
        , @acc_mpp_type1             = mpp_type1
        , @acc_mpp_type2             = mpp_type2
        , @acc_mpp_type3             = mpp_type3
        , @acc_mpp_type4             = mpp_type4
        , @acc_trc_type1             = trc_type1
        , @acc_trc_type2             = trc_type2
        , @acc_trc_type3             = trc_type3
        , @acc_trc_type4             = trc_type4
        , @acc_trk_stoptype          = trk_stoptype
        , @acc_trk_delays            = trk_delays
        , @acc_trk_ooamileage        = trk_ooamileage
        , @acc_trk_ooastop           = trk_ooastop
        , @acc_trk_carryins1         = trk_carryins1
        , @acc_trk_carryins2         = trk_carryins2
        , @acc_cmp_mastercompany     = cmp_mastercompany
        , @acc_trk_minrevpermile     = trk_minrevpermile
        , @acc_trk_maxrevpermile     = trk_maxrevpermile
        , @acc_trk_stp_event         = trk_stp_event
        , @acc_trk_custdoc           = trk_custdoc
        , @acc_trk_partytobill_id    = trk_partytobill_id
        , @acc_trk_thirdparty        = trk_thirdparty
        , @acc_trk_lghtype2          = trk_lghtype2
        , @acc_trk_lghtype3          = trk_lghtype3
        , @acc_trk_lghtype4          = trk_lghtype4
        , @acc_trk_thirdpartytype    = trk_thirdpartytype
        , @acc_trk_minsegments       = trk_minsegments
        , @acc_trk_maxsegments       = trk_maxsegments
        , @acc_billto_othertype1     = billto_othertype1
        , @acc_billto_othertype2     = billto_othertype2
        , @acc_stop_othertype1       = stop_othertype1
        , @acc_stop_othertype2       = stop_othertype2
        , @acc_trk_usefor_billable   = trk_usefor_billable
        , @acc_trk_mincarriersvcdays = trk_mincarriersvcdays
        , @acc_trk_maxcarriersvcdays = trk_maxcarriersvcdays
     FROM tariffkey
    WHERE tar_number = @acc_trk_tar_number
      AND trk_number = @acc_trk_trk_number

   --TariffheaderStl for the Accessorial
   UPDATE tariffheaderstl
      SET tar_description        = @acc_tar_description
        , cht_itemcode           = @acc_cht_itemcode
        , cht_unit               = @acc_cht_unit
        , tar_rate               = @acc_tar_rate
        , cht_rateunit           = @acc_cht_rateunit
        , tar_rowbasis           = @acc_tar_rowbasis
        , tar_colbasis           = @acc_tar_colbasis
        , tar_minquantity        = @acc_tar_minquantity
        , tar_mincharge          = @acc_tar_mincharge
        , cht_currunit           = @acc_cht_currunit
        , tar_applyto_asset      = @acc_tar_applyto_asset
        , tar_tblratingoption    = @acc_tar_tblratingoption
        , tar_tro_roworcolumn    = @acc_tar_tro_roworcolumn
        , tar_minqty             = @acc_tar_minqty
        , tar_zerorateisnorate   = @acc_tar_zerorateisnorate
        , tar_external_flag      = @acc_tar_external_flag
        , tar_maxquantity        = @acc_tar_maxquantity
        , tar_maxcharge          = @acc_tar_maxcharge
    WHERE tar_number = @acc_trk_tar_number

   --Tariffkey for the Accessorial
   UPDATE tariffkey
      SET trk_startdate          = @acc_trk_startdate
        , trk_enddate            = @acc_trk_enddate
        , trk_billto             = @acc_trk_billto
        , cmp_othertype1         = @acc_cmp_othertype1
        , cmp_othertype2         = @acc_cmp_othertype2
        , cmd_code               = @acc_cmd_code
        , cmd_class              = @acc_cmd_class
        , trl_type1              = @acc_trl_type1
        , trl_type2              = @acc_trl_type2
        , trl_type3              = @acc_trl_type3
        , trl_type4              = @acc_trl_type4
        , trk_revtype1           = @acc_trk_revtype1
        , trk_revtype2           = @acc_trk_revtype2
        , trk_revtype3           = @acc_trk_revtype3
        , trk_revtype4           = @acc_trk_revtype4
        , trk_originpoint        = @acc_trk_originpoint
        , trk_origincity         = @acc_trk_origincity
        , trk_originzip          = @acc_trk_originzip
        , trk_originstate        = @acc_trk_originstate
        , trk_destpoint          = @acc_trk_destpoint
        , trk_destcity           = @acc_trk_destcity
        , trk_destzip            = @acc_trk_destzip
        , trk_deststate          = @acc_trk_deststate
        , trk_minmiles           = @acc_trk_minmiles
        , trk_minweight          = @acc_trk_minweight
        , trk_minpieces          = @acc_trk_minpieces
        , trk_minvolume          = @acc_trk_minvolume
        , trk_maxmiles           = @acc_trk_maxmiles
        , trk_maxweight          = @acc_trk_maxweight
        , trk_duplicateseq       = @acc_trk_duplicateseq
        , trk_primary            = @acc_trk_primary
        , trk_minstops           = @acc_trk_minstops
        , trk_maxstops           = @acc_trk_maxstops
        , trk_minodmiles         = @acc_trk_minodmiles
        , trk_maxodmiles         = @acc_trk_maxodmiles
        , trk_minvariance        = @acc_trk_minvariance
        , trk_maxvariance        = @acc_trk_maxvariance
        , trk_orderedby          = @acc_trk_orderedby
        , trk_minlength          = @acc_trk_minlength
        , trk_maxlength          = @acc_trk_maxlength
        , trk_minwidth           = @acc_trk_minwidth
        , trk_maxwidth           = @acc_trk_maxwidth
        , trk_minheight          = @acc_trk_minheight
        , trk_maxheight          = @acc_trk_maxheight
        , trk_origincounty       = @acc_trk_origincounty
        , trk_destcounty         = @acc_trk_destcounty
        , trk_company            = @acc_trk_company
        , trk_carrier            = @acc_trk_carrier
        , trk_lghtype1           = @acc_trk_lghtype1
        , trk_load               = @acc_trk_load
        , trk_team               = @acc_trk_team
        , trk_boardcarrier       = @acc_trk_boardcarrier
        , mpp_type1              = @acc_mpp_type1
        , mpp_type2              = @acc_mpp_type2
        , mpp_type3              = @acc_mpp_type3
        , mpp_type4              = @acc_mpp_type4
        , trc_type1              = @acc_trc_type1
        , trc_type2              = @acc_trc_type2
        , trc_type3              = @acc_trc_type3
        , trc_type4              = @acc_trc_type4
        , trk_stoptype           = @acc_trk_stoptype
        , trk_delays             = @acc_trk_delays
        , trk_ooamileage         = @acc_trk_ooamileage
        , trk_ooastop            = @acc_trk_ooastop
        , trk_carryins1          = @acc_trk_carryins1
        , trk_carryins2          = @acc_trk_carryins2
        , cmp_mastercompany      = @acc_cmp_mastercompany
        , trk_minrevpermile      = @acc_trk_minrevpermile
        , trk_maxrevpermile      = @acc_trk_maxrevpermile
        , trk_stp_event          = @acc_trk_stp_event
        , trk_custdoc            = @acc_trk_custdoc
        , trk_partytobill_id     = @acc_trk_partytobill_id
        , trk_thirdparty         = @acc_trk_thirdparty
        , trk_lghtype2           = @acc_trk_lghtype2
        , trk_lghtype3           = @acc_trk_lghtype3
        , trk_lghtype4           = @acc_trk_lghtype4
        , trk_thirdpartytype     = @acc_trk_thirdpartytype
        , trk_minsegments        = @acc_trk_minsegments
        , trk_maxsegments        = @acc_trk_maxsegments
        , billto_othertype1      = @acc_billto_othertype1
        , billto_othertype2      = @acc_billto_othertype2
        , stop_othertype1        = @acc_stop_othertype1
        , stop_othertype2        = @acc_stop_othertype2
        , trk_usefor_billable    = @acc_trk_usefor_billable
        , trk_mincarriersvcdays   = @acc_trk_mincarriersvcdays
        , trk_maxcarriersvcdays   = @acc_trk_maxcarriersvcdays
    WHERE tar_number = @acc_trk_tar_number
      AND trk_number = @acc_trk_trk_number

   --TariffaccessorialStl
   UPDATE tariffaccessorialstl
      SET taa_seq = @taa_taa_seq
    WHERE tar_number = @primary_tar_number
      AND trk_number = @acc_trk_trk_number

END
GO
GRANT EXECUTE ON  [dbo].[ds_tar_edit_stl_accessorial_u_sp] TO [public]
GO
