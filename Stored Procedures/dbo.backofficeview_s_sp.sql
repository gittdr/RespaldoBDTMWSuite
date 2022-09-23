SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[backofficeview_s_sp]
( @mode                    VARCHAR(10)
, @bov_id                  CHAR(6)
, @bov_type                CHAR(6)
) AS

/*
*
*
* NAME:
* dbo.backofficeview_s_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to select rows from backofficeview or backofficeview_temp
*
* RETURNS:
*
* RESULTSET:
*
* 10/31/2012 PTS63020 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

DECLARE @tmwuser  VARCHAR(255)

EXEC gettmwuser @tmwuser OUTPUT

   IF @mode = 'RESTRICT' AND EXISTS(SELECT 1
                                      FROM backofficeview_temp
                                     WHERE bov_id = @bov_id
                                       AND bov_type = @bov_type
                                       AND tmwuser = @tmwuser
                                   )
      BEGIN
         SELECT @mode                  AS mode
              , bov_appid              AS bov_appid
              , bov_type               AS bov_type
              , bov_id                 AS bov_id
              , bov_name               AS bov_name
              , bov_billto             AS bov_billto
              , bov_acct_type          AS bov_acct_type
              , bov_booked_revtype1    AS bov_booked_revtype1
              , bov_company            AS bov_company
              , bov_fleet              AS bov_fleet
              , bov_division           AS bov_division
              , bov_terminal           AS bov_terminal
              , bov_paperwork_received AS bov_paperwork_received
              , bov_lgh_type1          AS bov_lgh_type1
              , bov_rev_type1          AS bov_rev_type1
              , bov_rev_type2          AS bov_rev_type2
              , bov_rev_type3          AS bov_rev_type3
              , bov_rev_type4          AS bov_rev_type4
              , bov_driver_incl        AS bov_driver_incl
              , bov_driver_id          AS bov_driver_id
              , bov_mpp_type1          AS bov_mpp_type1
              , bov_mpp_type2          AS bov_mpp_type2
              , bov_mpp_type3          AS bov_mpp_type3
              , bov_mpp_type4          AS bov_mpp_type4
              , bov_mpp_branch         AS bov_mpp_branch
              , bov_tractor_incl       AS bov_tractor_incl
              , bov_tractor_id         AS bov_tractor_id
              , bov_trc_type1          AS bov_trc_type1
              , bov_trc_type2          AS bov_trc_type2
              , bov_trc_type3          AS bov_trc_type3
              , bov_trc_type4          AS bov_trc_type4
              , bov_trc_branch         AS bov_trc_branch
              , bov_trailer_incl       AS bov_trailer_incl
              , bov_trailer_id         AS bov_trailer_id
              , bov_trl_type1          AS bov_trl_type1
              , bov_trl_type2          AS bov_trl_type2
              , bov_trl_type3          AS bov_trl_type3
              , bov_trl_type4          AS bov_trl_type4
              , bov_trl_branch         AS bov_trl_branch
              , bov_carrier_incl       AS bov_carrier_incl
              , bov_carrier_id         AS bov_carrier_id
              , bov_car_type1          AS bov_car_type1
              , bov_car_type2          AS bov_car_type2
              , bov_car_type3          AS bov_car_type3
              , bov_car_type4          AS bov_car_type4
              , bov_car_branch         AS bov_car_branch
              , bov_tpr_incl           AS bov_tpr_incl
              , bov_tpr_id             AS bov_tpr_id
              , bov_tpr_type           AS bov_tpr_type
              , 'Branch'               AS bov_booked_revtype1_t
              , 'CarType1'             AS bov_car_type1_t
              , 'CarType2'             AS bov_car_type2_t
              , 'CarType3'             AS bov_car_type3_t
              , 'CarType4'             AS bov_car_type4_t
              , 'DrvType1'             AS bov_mpp_type1_t
              , 'DrvType2'             AS bov_mpp_type2_t
              , 'DrvType3'             AS bov_mpp_type3_t
              , 'DrvType4'             AS bov_mpp_type4_t
              , 'RevType1'             AS bov_rev_type1_t
              , 'RevType2'             AS bov_rev_type2_t
              , 'RevType3'             AS bov_rev_type3_t
              , 'RevType4'             AS bov_rev_type4_t
              , 'TrcType1'             AS bov_trc_type1_t
              , 'TrcType2'             AS bov_trc_type2_t
              , 'TrcType3'             AS bov_trc_type3_t
              , 'TrcType4'             AS bov_trc_type4_t
              , 'TrlType1'             AS bov_trl_type1_t
              , 'TrlType2'             AS bov_trl_type2_t
              , 'TrlType3'             AS bov_trl_type3_t
              , 'TrlType4'             AS bov_trl_type4_t
              , 'LghType1'             AS bov_lgh_type1_t
              , bov_inv_status         AS bov_inv_status
              , bov_ivh_rev_type1      AS bov_ivh_rev_type1
              , 'RevType1'             AS bov_ivh_rev_type1_t
           FROM backofficeview_temp
          WHERE bov_id = @bov_id
            AND bov_type = @bov_type
            AND tmwuser = @tmwuser
      END
   ELSE
      BEGIN
         SELECT @mode                  AS mode
              , bov_appid              AS bov_appid
              , bov_type               AS bov_type
              , bov_id                 AS bov_id
              , bov_name               AS bov_name
              , bov_billto             AS bov_billto
              , bov_acct_type          AS bov_acct_type
              , bov_booked_revtype1    AS bov_booked_revtype1
              , bov_company            AS bov_company
              , bov_fleet              AS bov_fleet
              , bov_division           AS bov_division
              , bov_terminal           AS bov_terminal
              , bov_paperwork_received AS bov_paperwork_received
              , bov_lgh_type1          AS bov_lgh_type1
              , bov_rev_type1          AS bov_rev_type1
              , bov_rev_type2          AS bov_rev_type2
              , bov_rev_type3          AS bov_rev_type3
              , bov_rev_type4          AS bov_rev_type4
              , bov_driver_incl        AS bov_driver_incl
              , bov_driver_id          AS bov_driver_id
              , bov_mpp_type1          AS bov_mpp_type1
              , bov_mpp_type2          AS bov_mpp_type2
              , bov_mpp_type3          AS bov_mpp_type3
              , bov_mpp_type4          AS bov_mpp_type4
              , bov_mpp_branch         AS bov_mpp_branch
              , bov_tractor_incl       AS bov_tractor_incl
              , bov_tractor_id         AS bov_tractor_id
              , bov_trc_type1          AS bov_trc_type1
              , bov_trc_type2          AS bov_trc_type2
              , bov_trc_type3          AS bov_trc_type3
              , bov_trc_type4          AS bov_trc_type4
              , bov_trc_branch         AS bov_trc_branch
              , bov_trailer_incl       AS bov_trailer_incl
              , bov_trailer_id         AS bov_trailer_id
              , bov_trl_type1          AS bov_trl_type1
              , bov_trl_type2          AS bov_trl_type2
              , bov_trl_type3          AS bov_trl_type3
              , bov_trl_type4          AS bov_trl_type4
              , bov_trl_branch         AS bov_trl_branch
              , bov_carrier_incl       AS bov_carrier_incl
              , bov_carrier_id         AS bov_carrier_id
              , bov_car_type1          AS bov_car_type1
              , bov_car_type2          AS bov_car_type2
              , bov_car_type3          AS bov_car_type3
              , bov_car_type4          AS bov_car_type4
              , bov_car_branch         AS bov_car_branch
              , bov_tpr_incl           AS bov_tpr_incl
              , bov_tpr_id             AS bov_tpr_id
              , bov_tpr_type           AS bov_tpr_type
              , 'Branch'               AS bov_booked_revtype1_t
              , 'CarType1'             AS bov_car_type1_t
              , 'CarType2'             AS bov_car_type2_t
              , 'CarType3'             AS bov_car_type3_t
              , 'CarType4'             AS bov_car_type4_t
              , 'DrvType1'             AS bov_mpp_type1_t
              , 'DrvType2'             AS bov_mpp_type2_t
              , 'DrvType3'             AS bov_mpp_type3_t
              , 'DrvType4'             AS bov_mpp_type4_t
              , 'RevType1'             AS bov_rev_type1_t
              , 'RevType2'             AS bov_rev_type2_t
              , 'RevType3'             AS bov_rev_type3_t
              , 'RevType4'             AS bov_rev_type4_t
              , 'TrcType1'             AS bov_trc_type1_t
              , 'TrcType2'             AS bov_trc_type2_t
              , 'TrcType3'             AS bov_trc_type3_t
              , 'TrcType4'             AS bov_trc_type4_t
              , 'TrlType1'             AS bov_trl_type1_t
              , 'TrlType2'             AS bov_trl_type2_t
              , 'TrlType3'             AS bov_trl_type3_t
              , 'TrlType4'             AS bov_trl_type4_t
              , 'LghType1'             AS bov_lgh_type1_t
              , bov_inv_status         AS bov_inv_status
              , bov_ivh_rev_type1      AS bov_ivh_rev_type1
              , 'RevType1'             AS bov_ivh_rev_type1_t
           FROM backofficeview
          WHERE bov_id = @bov_id
            AND bov_type = @bov_type
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[backofficeview_s_sp] TO [public]
GO
