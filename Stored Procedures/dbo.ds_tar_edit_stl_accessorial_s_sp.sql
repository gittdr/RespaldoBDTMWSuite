SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_tar_edit_stl_accessorial_s_sp]
( @primary_tar_number      INT
) AS

/**
 *
 * NAME:
 * dbo.ds_tar_edit_stl_accessorial_s_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for inserting into tables tariffaccessorialstl, tariffkey and tariffheaderstl
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @primary_tar_number      INT
 *
 *
 * REVISION HISTORY:
 * PTS 62530 SPN Created 05/23/12
 *
 **/

SET NOCOUNT ON

BEGIN

   SELECT a.tar_number              AS primary_tar_number
        , k.tar_number              AS acc_trk_tar_number
        , k.trk_number              AS acc_trk_trk_number
        , h.tar_description         AS acc_tar_description
        , h.cht_itemcode            AS acc_cht_itemcode
        , h.cht_unit                AS acc_cht_unit
        , h.tar_rate                AS acc_tar_rate
        , h.cht_rateunit            AS acc_cht_rateunit
        , a.taa_seq                 AS taa_taa_seq
        , k.trk_startdate           AS acc_trk_startdate
        , k.trk_enddate             AS acc_trk_enddate
        , h.tar_rowbasis            AS acc_tar_rowbasis
        , h.tar_colbasis            AS acc_tar_colbasis
        , h.tar_incremental         AS acc_tar_incremental
        , h.tar_nextbreak           AS acc_tar_nextbreak
        , h.tar_minquantity         AS acc_tar_minquantity
        , h.tar_mincharge           AS acc_tar_mincharge
        , h.tar_tro_roworcolumn     AS acc_tar_tro_roworcolumn
        , h.tar_minqty              AS acc_tar_minqty
        , h.tar_maxquantity         AS acc_tar_maxquantity
        , h.tar_maxcharge           AS acc_tar_maxcharge
        , k.trk_billto              AS acc_trk_billto
        , k.cmp_othertype1          AS acc_cmp_othertype1
        , k.cmp_othertype2          AS acc_cmp_othertype2
        , k.cmd_code                AS acc_cmd_code
        , k.cmd_class               AS acc_cmd_class
        , k.trl_type1               AS acc_trl_type1
        , k.trl_type2               AS acc_trl_type2
        , k.trl_type3               AS acc_trl_type3
        , k.trl_type4               AS acc_trl_type4
        , k.trk_revtype1            AS acc_trk_revtype1
        , k.trk_revtype2            AS acc_trk_revtype2
        , k.trk_revtype3            AS acc_trk_revtype3
        , k.trk_revtype4            AS acc_trk_revtype4
        , k.trk_originpoint         AS acc_trk_originpoint
        , k.trk_origincity          AS acc_trk_origincity
        , k.trk_originzip           AS acc_trk_originzip
        , k.trk_originstate         AS acc_trk_originstate
        , k.trk_destpoint           AS acc_trk_destpoint
        , k.trk_destcity            AS acc_trk_destcity
        , k.trk_destzip             AS acc_trk_destzip
        , k.trk_deststate           AS acc_trk_deststate
        , k.trk_minmiles            AS acc_trk_minmiles
        , k.trk_minweight           AS acc_trk_minweight
        , k.trk_minpieces           AS acc_trk_minpieces
        , k.trk_minvolume           AS acc_trk_minvolume
        , k.trk_maxmiles            AS acc_trk_maxmiles
        , k.trk_maxweight           AS acc_trk_maxweight
        , k.trk_duplicateseq        AS acc_trk_duplicateseq
        , k.trk_primary             AS acc_trk_primary
        , k.trk_minstops            AS acc_trk_minstops
        , k.trk_maxstops            AS acc_trk_maxstops
        , k.trk_minodmiles          AS acc_trk_minodmiles
        , k.trk_maxodmiles          AS acc_trk_maxodmiles
        , k.trk_minvariance         AS acc_trk_minvariance
        , k.trk_maxvariance         AS acc_trk_maxvariance
        , k.trk_orderedby           AS acc_trk_orderedby
        , k.trk_minlength           AS acc_trk_minlength
        , k.trk_maxlength           AS acc_trk_maxlength
        , k.trk_minwidth            AS acc_trk_minwidth
        , k.trk_maxwidth            AS acc_trk_maxwidth
        , k.trk_minheight           AS acc_trk_minheight
        , k.trk_maxheight           AS acc_trk_maxheight
        , k.trk_origincounty        AS acc_trk_origincounty
        , k.trk_destcounty          AS acc_trk_destcounty
        , k.trk_company             AS acc_trk_company
        , k.trk_carrier             AS acc_trk_carrier
        , k.trk_load                AS acc_trk_load
        , k.trk_team                AS acc_trk_team
        , k.trk_boardcarrier        AS acc_trk_boardcarrier
        , k.mpp_type1               AS acc_mpp_type1
        , k.mpp_type2               AS acc_mpp_type2
        , k.mpp_type3               AS acc_mpp_type3
        , k.mpp_type4               AS acc_mpp_type4
        , k.trc_type1               AS acc_trc_type1
        , k.trc_type2               AS acc_trc_type2
        , k.trc_type3               AS acc_trc_type3
        , k.trc_type4               AS acc_trc_type4
        , k.trk_stoptype            AS acc_trk_stoptype
        , k.trk_delays              AS acc_trk_delays
        , k.trk_ooamileage          AS acc_trk_ooamileage
        , k.trk_ooastop             AS acc_trk_ooastop
        , k.trk_carryins1           AS acc_trk_carryins1
        , k.trk_carryins2           AS acc_trk_carryins2
        , k.cmp_mastercompany       AS acc_cmp_mastercompany
        , k.trk_minrevpermile       AS acc_trk_minrevpermile
        , k.trk_maxrevpermile       AS acc_trk_maxrevpermile
        , k.trk_stp_event           AS acc_trk_stp_event
        , k.trk_custdoc             AS acc_trk_custdoc
        , k.trk_partytobill_id      AS acc_trk_partytobill_id
        , k.trk_lghtype1            AS acc_trk_lghtype1
        , k.trk_lghtype2            AS acc_trk_lghtype2
        , k.trk_lghtype3            AS acc_trk_lghtype3
        , k.trk_lghtype4            AS acc_trk_lghtype4
        , k.trk_thirdparty          AS acc_trk_thirdparty
        , k.trk_thirdpartytype      AS acc_trk_thirdpartytype
        , k.trk_minsegments         AS acc_trk_minsegments
        , k.trk_maxsegments         AS acc_trk_maxsegments
        , k.billto_othertype1       AS acc_billto_othertype1
        , k.billto_othertype2       AS acc_billto_othertype2
        , k.stop_othertype1         AS acc_stop_othertype1
        , k.stop_othertype2         AS acc_stop_othertype2
        , k.trk_usefor_billable     AS acc_trk_usefor_billable
        , k.trk_mincarriersvcdays   AS acc_trk_mincarriersvcdays
        , k.trk_maxcarriersvcdays   AS acc_trk_maxcarriersvcdays
    FROM tariffaccessorialstl a
    JOIN tariffkey k ON a.trk_number = k.trk_number
    JOIN tariffheaderstl h ON k.tar_number = h.tar_number
   WHERE a.tar_number = @primary_tar_number
  ORDER BY a.tar_number
         , a.trk_number
END
GO
GRANT EXECUTE ON  [dbo].[ds_tar_edit_stl_accessorial_s_sp] TO [public]
GO
