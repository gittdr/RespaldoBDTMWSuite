SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[backofficeview_u_sp]
( @mode                    VARCHAR(10)
, @bov_appid               VARCHAR(20)
, @bov_type                CHAR(6)
, @bov_id                  CHAR(6)
, @bov_name                VARCHAR(50)
, @bov_billto              VARCHAR(MAX)
, @bov_acct_type           CHAR(1)
, @bov_booked_revtype1     VARCHAR(MAX)
, @bov_rev_type1           VARCHAR(MAX)
, @bov_rev_type2           VARCHAR(MAX)
, @bov_rev_type3           VARCHAR(MAX)
, @bov_rev_type4           VARCHAR(MAX)
, @bov_lgh_type1           VARCHAR(MAX)
, @bov_company             VARCHAR(MAX)
, @bov_fleet               VARCHAR(MAX)
, @bov_division            VARCHAR(MAX)
, @bov_terminal            VARCHAR(MAX)
, @bov_paperwork_received  CHAR(3)
, @bov_driver_incl         CHAR(1)
, @bov_driver_id           VARCHAR(MAX)
, @bov_mpp_type1           VARCHAR(MAX)
, @bov_mpp_type2           VARCHAR(MAX)
, @bov_mpp_type3           VARCHAR(MAX)
, @bov_mpp_type4           VARCHAR(MAX)
, @bov_mpp_branch          VARCHAR(MAX)
, @bov_tractor_incl        CHAR(1)
, @bov_tractor_id          VARCHAR(MAX)
, @bov_trc_type1           VARCHAR(MAX)
, @bov_trc_type2           VARCHAR(MAX)
, @bov_trc_type3           VARCHAR(MAX)
, @bov_trc_type4           VARCHAR(MAX)
, @bov_trc_branch          VARCHAR(MAX)
, @bov_trailer_incl        CHAR(1)
, @bov_trailer_id          VARCHAR(MAX)
, @bov_trl_type1           VARCHAR(MAX)
, @bov_trl_type2           VARCHAR(MAX)
, @bov_trl_type3           VARCHAR(MAX)
, @bov_trl_type4           VARCHAR(MAX)
, @bov_trl_branch          VARCHAR(MAX)
, @bov_carrier_incl        CHAR(1)
, @bov_carrier_id          VARCHAR(MAX)
, @bov_car_type1           VARCHAR(MAX)
, @bov_car_type2           VARCHAR(MAX)
, @bov_car_type3           VARCHAR(MAX)
, @bov_car_type4           VARCHAR(MAX)
, @bov_car_branch          VARCHAR(MAX)
, @bov_tpr_incl            CHAR(1)
, @bov_tpr_id              VARCHAR(MAX)
, @bov_tpr_type            VARCHAR(MAX)
, @bov_inv_status          VARCHAR(MAX)
, @bov_ivh_rev_type1       VARCHAR(MAX)
) AS

/*
*
*
* NAME:
* dbo.backofficeview_u_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to Update rows into backofficeview and backofficeview_temp
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

   IF @mode = 'MAINTAIN'
      BEGIN
         UPDATE backofficeview
            SET bov_name                  = @bov_name
              , bov_billto                = @bov_billto
              , bov_acct_type             = @bov_acct_type
              , bov_booked_revtype1       = @bov_booked_revtype1
              , bov_rev_type1             = @bov_rev_type1
              , bov_rev_type2             = @bov_rev_type2
              , bov_rev_type3             = @bov_rev_type3
              , bov_rev_type4             = @bov_rev_type4
              , bov_lgh_type1             = @bov_lgh_type1
              , bov_company               = @bov_company
              , bov_fleet                 = @bov_fleet
              , bov_division              = @bov_division
              , bov_terminal              = @bov_terminal
              , bov_paperwork_received    = @bov_paperwork_received
              , bov_driver_incl           = @bov_driver_incl
              , bov_driver_id             = @bov_driver_id
              , bov_mpp_type1             = @bov_mpp_type1
              , bov_mpp_type2             = @bov_mpp_type2
              , bov_mpp_type3             = @bov_mpp_type3
              , bov_mpp_type4             = @bov_mpp_type4
              , bov_mpp_branch            = @bov_mpp_branch
              , bov_tractor_incl          = @bov_tractor_incl
              , bov_tractor_id            = @bov_tractor_id
              , bov_trc_type1             = @bov_trc_type1
              , bov_trc_type2             = @bov_trc_type2
              , bov_trc_type3             = @bov_trc_type3
              , bov_trc_type4             = @bov_trc_type4
              , bov_trc_branch            = @bov_trc_branch
              , bov_trailer_incl          = @bov_trailer_incl
              , bov_trailer_id            = @bov_trailer_id
              , bov_trl_type1             = @bov_trl_type1
              , bov_trl_type2             = @bov_trl_type2
              , bov_trl_type3             = @bov_trl_type3
              , bov_trl_type4             = @bov_trl_type4
              , bov_trl_branch            = @bov_trl_branch
              , bov_carrier_incl          = @bov_carrier_incl
              , bov_carrier_id            = @bov_carrier_id
              , bov_car_type1             = @bov_car_type1
              , bov_car_type2             = @bov_car_type2
              , bov_car_type3             = @bov_car_type3
              , bov_car_type4             = @bov_car_type4
              , bov_car_branch            = @bov_car_branch
              , bov_tpr_incl              = @bov_tpr_incl
              , bov_tpr_id                = @bov_tpr_id
              , bov_tpr_type              = @bov_tpr_type
              , bov_inv_status            = @bov_inv_status
              , bov_ivh_rev_type1         = @bov_ivh_rev_type1
          WHERE bov_appid = @bov_appid
            AND bov_type = @bov_type
            AND bov_id = @bov_id
      END
   ELSE
      BEGIN
         EXEC dbo.backofficeview_i_sp
                    @mode
                  , @bov_appid
                  , @bov_type
                  , @bov_id
                  , @bov_name
                  , @bov_billto
                  , @bov_acct_type
                  , @bov_booked_revtype1
                  , @bov_rev_type1
                  , @bov_rev_type2
                  , @bov_rev_type3
                  , @bov_rev_type4
                  , @bov_lgh_type1
                  , @bov_company
                  , @bov_fleet
                  , @bov_division
                  , @bov_terminal
                  , @bov_paperwork_received
                  , @bov_driver_incl
                  , @bov_driver_id
                  , @bov_mpp_type1
                  , @bov_mpp_type2
                  , @bov_mpp_type3
                  , @bov_mpp_type4
                  , @bov_mpp_branch
                  , @bov_tractor_incl
                  , @bov_tractor_id
                  , @bov_trc_type1
                  , @bov_trc_type2
                  , @bov_trc_type3
                  , @bov_trc_type4
                  , @bov_trc_branch
                  , @bov_trailer_incl
                  , @bov_trailer_id
                  , @bov_trl_type1
                  , @bov_trl_type2
                  , @bov_trl_type3
                  , @bov_trl_type4
                  , @bov_trl_branch
                  , @bov_carrier_incl
                  , @bov_carrier_id
                  , @bov_car_type1
                  , @bov_car_type2
                  , @bov_car_type3
                  , @bov_car_type4
                  , @bov_car_branch
                  , @bov_tpr_incl
                  , @bov_tpr_id
                  , @bov_tpr_type
                  , @bov_inv_status
                  , @bov_ivh_rev_type1
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[backofficeview_u_sp] TO [public]
GO
