SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[backofficeview_get_sp]
( @bov_type                CHAR(6)
, @bov_id                  CHAR(6)
, @bov_billto              VARCHAR(MAX)   OUTPUT
, @bov_acct_type           CHAR(1)        OUTPUT
, @bov_booked_revtype1     VARCHAR(MAX)   OUTPUT
, @bov_rev_type1           VARCHAR(MAX)   OUTPUT
, @bov_rev_type2           VARCHAR(MAX)   OUTPUT
, @bov_rev_type3           VARCHAR(MAX)   OUTPUT
, @bov_rev_type4           VARCHAR(MAX)   OUTPUT
, @bov_lgh_type1           VARCHAR(MAX)   OUTPUT
, @bov_company             VARCHAR(MAX)   OUTPUT
, @bov_fleet               VARCHAR(MAX)   OUTPUT
, @bov_division            VARCHAR(MAX)   OUTPUT
, @bov_terminal            VARCHAR(MAX)   OUTPUT
, @bov_paperwork_received  INT            OUTPUT
, @bov_driver_incl         CHAR(3)        OUTPUT
, @bov_driver_id           VARCHAR(MAX)   OUTPUT
, @bov_mpp_type1           VARCHAR(MAX)   OUTPUT
, @bov_mpp_type2           VARCHAR(MAX)   OUTPUT
, @bov_mpp_type3           VARCHAR(MAX)   OUTPUT
, @bov_mpp_type4           VARCHAR(MAX)   OUTPUT
, @bov_mpp_branch          VARCHAR(MAX)   OUTPUT
, @bov_tractor_incl        CHAR(3)        OUTPUT
, @bov_tractor_id          VARCHAR(MAX)   OUTPUT
, @bov_trc_type1           VARCHAR(MAX)   OUTPUT
, @bov_trc_type2           VARCHAR(MAX)   OUTPUT
, @bov_trc_type3           VARCHAR(MAX)   OUTPUT
, @bov_trc_type4           VARCHAR(MAX)   OUTPUT
, @bov_trc_branch          VARCHAR(MAX)   OUTPUT
, @bov_trailer_incl        CHAR(3)        OUTPUT
, @bov_trailer_id          VARCHAR(MAX)   OUTPUT
, @bov_trl_type1           VARCHAR(MAX)   OUTPUT
, @bov_trl_type2           VARCHAR(MAX)   OUTPUT
, @bov_trl_type3           VARCHAR(MAX)   OUTPUT
, @bov_trl_type4           VARCHAR(MAX)   OUTPUT
, @bov_trl_branch          VARCHAR(MAX)   OUTPUT
, @bov_carrier_incl        CHAR(3)        OUTPUT
, @bov_carrier_id          VARCHAR(MAX)   OUTPUT
, @bov_car_type1           VARCHAR(MAX)   OUTPUT
, @bov_car_type2           VARCHAR(MAX)   OUTPUT
, @bov_car_type3           VARCHAR(MAX)   OUTPUT
, @bov_car_type4           VARCHAR(MAX)   OUTPUT
, @bov_car_branch          VARCHAR(MAX)   OUTPUT
, @bov_tpr_incl            CHAR(3)        OUTPUT
, @bov_tpr_id              VARCHAR(MAX)   OUTPUT
, @bov_tpr_type            VARCHAR(MAX)   OUTPUT
, @bov_inv_status          VARCHAR(MAX)   OUTPUT
, @bov_ivh_rev_type1       VARCHAR(MAX)   OUTPUT
) AS

/*
*
*
* NAME:
* dbo.backofficeview_get_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to get values from backofficeview and backofficeview_temp
*
* RETURNS:
*
* NOTHING:
*
* 10/31/2012 PTS63020 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

DECLARE @tmwuser  VARCHAR(255)

EXEC gettmwuser @tmwuser OUTPUT

   IF EXISTS(SELECT 1
               FROM backofficeview_temp
              WHERE bov_id = @bov_id
                AND bov_type = @bov_type
                AND tmwuser = @tmwuser
            )
      BEGIN
         SELECT @bov_billto            = CASE ISNULL(RTRIM(bov_billto), '')                WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_billto + ',') END
              , @bov_acct_type         = IsNull(bov_acct_type, 'X')
              , @bov_booked_revtype1   = CASE ISNULL(RTRIM(bov_booked_revtype1), '')       WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_booked_revtype1 + ',') END
              , @bov_rev_type1         = CASE ISNULL(RTRIM(bov_rev_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type1 + ',') END
              , @bov_rev_type2         = CASE ISNULL(RTRIM(bov_rev_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type2 + ',') END
              , @bov_rev_type3         = CASE ISNULL(RTRIM(bov_rev_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type3 + ',') END
              , @bov_rev_type4         = CASE ISNULL(RTRIM(bov_rev_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type4 + ',') END
              , @bov_lgh_type1         = CASE ISNULL(RTRIM(bov_lgh_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_lgh_type1 + ',') END
              , @bov_company           = CASE ISNULL(RTRIM(bov_company), '')               WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_company + ',')   END
              , @bov_fleet             = CASE ISNULL(RTRIM(bov_fleet), '')                 WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_fleet + ',')     END
              , @bov_division          = CASE ISNULL(RTRIM(bov_division), '')              WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_division + ',')  END
              , @bov_terminal          = CASE ISNULL(RTRIM(bov_terminal), '')              WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_terminal + ',')  END
              , @bov_paperwork_received= CASE ISNULL(RTRIM(bov_paperwork_received), 'N/A') WHEN 'Y' THEN 1     WHEN 'N'       THEN -1  ELSE 0 END
              , @bov_driver_incl       = CASE ISNULL(bov_driver_incl, 'N')                 WHEN 'N' THEN 'XXX' ELSE 'DRV' END
              , @bov_driver_id         = CASE ISNULL(RTRIM(bov_driver_id), '')             WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_driver_id + ',') END
              , @bov_mpp_type1         = CASE ISNULL(RTRIM(bov_mpp_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type1 + ',') END
              , @bov_mpp_type2         = CASE ISNULL(RTRIM(bov_mpp_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type2 + ',') END
              , @bov_mpp_type3         = CASE ISNULL(RTRIM(bov_mpp_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type3 + ',') END
              , @bov_mpp_type4         = CASE ISNULL(RTRIM(bov_mpp_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type4 + ',') END
              , @bov_mpp_branch        = CASE ISNULL(RTRIM(bov_mpp_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_mpp_branch + ',') END
              , @bov_tractor_incl      = CASE ISNULL(bov_tractor_incl, 'N')                WHEN 'N' THEN 'XXX' ELSE 'TRC' END
              , @bov_tractor_id        = CASE ISNULL(RTRIM(bov_tractor_id), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_tractor_id + ',') END
              , @bov_trc_type1         = CASE ISNULL(RTRIM(bov_trc_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type1 + ',') END
              , @bov_trc_type2         = CASE ISNULL(RTRIM(bov_trc_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type2 + ',') END
              , @bov_trc_type3         = CASE ISNULL(RTRIM(bov_trc_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type3 + ',') END
              , @bov_trc_type4         = CASE ISNULL(RTRIM(bov_trc_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type4 + ',') END
              , @bov_trc_branch        = CASE ISNULL(RTRIM(bov_trc_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_trc_branch + ',') END
              , @bov_trailer_incl      = CASE ISNULL(bov_trailer_incl, 'N')                WHEN 'N' THEN 'XXX' ELSE 'TRL' END
              , @bov_trailer_id        = CASE ISNULL(RTRIM(bov_trailer_id), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_trailer_id + ',') END
              , @bov_trl_type1         = CASE ISNULL(RTRIM(bov_trl_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type1 + ',') END
              , @bov_trl_type2         = CASE ISNULL(RTRIM(bov_trl_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type2 + ',') END
              , @bov_trl_type3         = CASE ISNULL(RTRIM(bov_trl_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type3 + ',') END
              , @bov_trl_type4         = CASE ISNULL(RTRIM(bov_trl_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type4 + ',') END
              , @bov_trl_branch        = CASE ISNULL(RTRIM(bov_trl_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_trl_branch + ',') END
              , @bov_carrier_incl      = CASE ISNULL(bov_carrier_incl, 'N')                WHEN 'N' THEN 'XXX' ELSE 'CAR' END
              , @bov_carrier_id        = CASE ISNULL(RTRIM(bov_carrier_id), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_carrier_id + ',') END
              , @bov_car_type1         = CASE ISNULL(RTRIM(bov_car_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type1 + ',') END
              , @bov_car_type2         = CASE ISNULL(RTRIM(bov_car_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type2 + ',') END
              , @bov_car_type3         = CASE ISNULL(RTRIM(bov_car_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type3 + ',') END
              , @bov_car_type4         = CASE ISNULL(RTRIM(bov_car_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type4 + ',') END
              , @bov_car_branch        = CASE ISNULL(RTRIM(bov_car_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_car_branch + ',') END
              , @bov_tpr_incl          = CASE ISNULL(bov_tpr_incl, 'N')                    WHEN 'N' THEN 'XXX' ELSE 'TPR' END
              , @bov_tpr_id            = CASE ISNULL(RTRIM(bov_tpr_id), '')                WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_tpr_id + ',') END
              , @bov_tpr_type          = CASE ISNULL(RTRIM(bov_tpr_type), '')              WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_tpr_type + ',') END
              , @bov_inv_status        = CASE ISNULL(RTRIM(bov_car_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type4 + ',') END
              , @bov_ivh_rev_type1     = CASE ISNULL(RTRIM(bov_ivh_rev_type1), '')         WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_ivh_rev_type1 + ',') END
           FROM backofficeview_temp
          WHERE bov_id = @bov_id
            AND bov_type = @bov_type
            AND tmwuser = @tmwuser
      END
   ELSE
      BEGIN
         SELECT @bov_billto            = CASE ISNULL(RTRIM(bov_billto), '')                WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_billto + ',') END
              , @bov_acct_type         = IsNull(bov_acct_type, 'X')
              , @bov_booked_revtype1   = CASE ISNULL(RTRIM(bov_booked_revtype1), '')       WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_booked_revtype1 + ',') END
              , @bov_rev_type1         = CASE ISNULL(RTRIM(bov_rev_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type1 + ',') END
              , @bov_rev_type2         = CASE ISNULL(RTRIM(bov_rev_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type2 + ',') END
              , @bov_rev_type3         = CASE ISNULL(RTRIM(bov_rev_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type3 + ',') END
              , @bov_rev_type4         = CASE ISNULL(RTRIM(bov_rev_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_rev_type4 + ',') END
              , @bov_lgh_type1         = CASE ISNULL(RTRIM(bov_lgh_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_lgh_type1 + ',') END
              , @bov_company           = CASE ISNULL(RTRIM(bov_company), '')               WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_company + ',')   END
              , @bov_fleet             = CASE ISNULL(RTRIM(bov_fleet), '')                 WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_fleet + ',')     END
              , @bov_division          = CASE ISNULL(RTRIM(bov_division), '')              WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_division + ',')  END
              , @bov_terminal          = CASE ISNULL(RTRIM(bov_terminal), '')              WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_terminal + ',')  END
              , @bov_paperwork_received= CASE ISNULL(RTRIM(bov_paperwork_received), 'N/A') WHEN 'Y' THEN 1     WHEN 'N'       THEN -1  ELSE 0 END
              , @bov_driver_incl       = CASE ISNULL(bov_driver_incl, 'N')                 WHEN 'N' THEN 'XXX' ELSE 'DRV' END
              , @bov_driver_id         = CASE ISNULL(RTRIM(bov_driver_id), '')             WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_driver_id + ',') END
              , @bov_mpp_type1         = CASE ISNULL(RTRIM(bov_mpp_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type1 + ',') END
              , @bov_mpp_type2         = CASE ISNULL(RTRIM(bov_mpp_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type2 + ',') END
              , @bov_mpp_type3         = CASE ISNULL(RTRIM(bov_mpp_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type3 + ',') END
              , @bov_mpp_type4         = CASE ISNULL(RTRIM(bov_mpp_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_mpp_type4 + ',') END
              , @bov_mpp_branch        = CASE ISNULL(RTRIM(bov_mpp_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_mpp_branch + ',') END
              , @bov_tractor_incl      = CASE ISNULL(bov_tractor_incl, 'N')                WHEN 'N' THEN 'XXX' ELSE 'TRC' END
              , @bov_tractor_id        = CASE ISNULL(RTRIM(bov_tractor_id), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_tractor_id + ',') END
              , @bov_trc_type1         = CASE ISNULL(RTRIM(bov_trc_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type1 + ',') END
              , @bov_trc_type2         = CASE ISNULL(RTRIM(bov_trc_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type2 + ',') END
              , @bov_trc_type3         = CASE ISNULL(RTRIM(bov_trc_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type3 + ',') END
              , @bov_trc_type4         = CASE ISNULL(RTRIM(bov_trc_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trc_type4 + ',') END
              , @bov_trc_branch        = CASE ISNULL(RTRIM(bov_trc_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_trc_branch + ',') END
              , @bov_trailer_incl      = CASE ISNULL(bov_trailer_incl, 'N')                WHEN 'N' THEN 'XXX' ELSE 'TRL' END
              , @bov_trailer_id        = CASE ISNULL(RTRIM(bov_trailer_id), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_trailer_id + ',') END
              , @bov_trl_type1         = CASE ISNULL(RTRIM(bov_trl_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type1 + ',') END
              , @bov_trl_type2         = CASE ISNULL(RTRIM(bov_trl_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type2 + ',') END
              , @bov_trl_type3         = CASE ISNULL(RTRIM(bov_trl_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type3 + ',') END
              , @bov_trl_type4         = CASE ISNULL(RTRIM(bov_trl_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_trl_type4 + ',') END
              , @bov_trl_branch        = CASE ISNULL(RTRIM(bov_trl_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_trl_branch + ',') END
              , @bov_carrier_incl      = CASE ISNULL(bov_carrier_incl, 'N')                WHEN 'N' THEN 'XXX' ELSE 'CAR' END
              , @bov_carrier_id        = CASE ISNULL(RTRIM(bov_carrier_id), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_carrier_id + ',') END
              , @bov_car_type1         = CASE ISNULL(RTRIM(bov_car_type1), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type1 + ',') END
              , @bov_car_type2         = CASE ISNULL(RTRIM(bov_car_type2), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type2 + ',') END
              , @bov_car_type3         = CASE ISNULL(RTRIM(bov_car_type3), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type3 + ',') END
              , @bov_car_type4         = CASE ISNULL(RTRIM(bov_car_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type4 + ',') END
              , @bov_car_branch        = CASE ISNULL(RTRIM(bov_car_branch), '')            WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_car_branch + ',') END
              , @bov_tpr_incl          = CASE ISNULL(bov_tpr_incl, 'N')                    WHEN 'N' THEN 'XXX' ELSE 'TPR' END
              , @bov_tpr_id            = CASE ISNULL(RTRIM(bov_tpr_id), '')                WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_tpr_id + ',') END
              , @bov_tpr_type          = CASE ISNULL(RTRIM(bov_tpr_type), '')              WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_tpr_type + ',') END
              , @bov_inv_status        = CASE ISNULL(RTRIM(bov_car_type4), '')             WHEN ''  THEN '%'   WHEN 'UNK'     THEN '%' ELSE (',' + bov_car_type4 + ',') END
              , @bov_ivh_rev_type1     = CASE ISNULL(RTRIM(bov_ivh_rev_type1), '')         WHEN ''  THEN '%'   WHEN 'UNKNOWN' THEN '%' ELSE (',' + bov_ivh_rev_type1 + ',') END
           FROM backofficeview
          WHERE bov_id   = @bov_id
            AND bov_type = @bov_type
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[backofficeview_get_sp] TO [public]
GO
