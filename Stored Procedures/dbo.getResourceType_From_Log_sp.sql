SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[getResourceType_From_Log_sp]
      ( @effective      DATETIME
      , @res_type       VARCHAR(50)
      , @res_id         VARCHAR(13)
      , @lbl_category   VARCHAR(50)
      , @retval         VARCHAR(50) OUTPUT
      )
AS

/*
*
*
* NAME:
* dbo.getResourceType_From_Log_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return info from AssetProfileLog
*
* RETURNS:
*
* NOTHING:
*
* 01/04/2012 PTS58228 SPN - Created Initial Version
* 09/12/2013 PTS72053 SPN - Lookup by Time instead of Date
*
*/

SET NOCOUNT ON

BEGIN

   SELECT @retval = 'UNK'

   IF @res_type IS NULL OR @res_id IS NULL OR @lbl_category IS NULL
      RETURN

   IF @effective IS NULL
      SELECT @effective = GetDate()

   IF @res_type = 'DRV'
      SELECT @res_type = 'Driver'
   ELSE IF @res_type = 'TRC'
      SELECT @res_type = 'Tractor'
   ELSE IF @res_type = 'TRL'
      SELECT @res_type = 'Trailer'
   ELSE IF @res_type = 'CAR'
      SELECT @res_type = 'Carrier'

   SELECT @retval = NULL
   SELECT @retval = lbl_value
     FROM assetprofilelog
    WHERE id = (
               -- PTS 81410 nloke
               SELECT TOP 1 id
				-- end 81410
                 FROM assetprofilelog
                WHERE res_type = @res_type
                  AND res_id = @res_id
                  AND lbl_category = @lbl_category
                  --BEGIN PTS 72053 SPN
                  --AND dateadd(dd,0, datediff(dd,0, effective)) <= @effective
                  AND effective <= @effective
                  --END PTS 72053 SPN
                  order by effective desc	--PTS 81410 nloke
               )

   --Get the value from Profile when no log found
   IF @retval IS NULL
   BEGIN
      IF @res_type = 'Driver'
         BEGIN
            IF @lbl_category = 'DrvType1'
               SELECT @retval = mpp_type1
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'DrvType2'
               SELECT @retval = mpp_type2
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'DrvType3'
               SELECT @retval = mpp_type3
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'DrvType4'
               SELECT @retval = mpp_type4
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'Company'
               SELECT @retval = mpp_company
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'Division'
               SELECT @retval = mpp_division
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'Fleet'
               SELECT @retval = mpp_fleet
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'Terminal'
               SELECT @retval = mpp_terminal
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'TeamLeader'
               SELECT @retval = mpp_teamleader
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE IF @lbl_category = 'Domicile'
               SELECT @retval = mpp_domicile
                 FROM manpowerprofile WHERE mpp_id = @res_id
            ELSE
               SELECT @retval = NULL
         END
      ELSE IF @res_type = 'Tractor'
         BEGIN
            IF @lbl_category = 'TrcType1'
               SELECT @retval = trc_type1
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'TrcType2'
               SELECT @retval = trc_type2
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'TrcType3'
               SELECT @retval = trc_type3
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'TrcType4'
               SELECT @retval = trc_type4
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'Company'
               SELECT @retval = trc_company
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'Division'
               SELECT @retval = trc_division
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'Fleet'
               SELECT @retval = trc_fleet
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE IF @lbl_category = 'Terminal'
               SELECT @retval = trc_terminal
                 FROM tractorprofile WHERE trc_number = @res_id
            ELSE
               SELECT @retval = NULL
         END
      ELSE IF @res_type = 'Trailer'
         BEGIN
            IF @lbl_category = 'TrlType1'
               SELECT @retval = trl_type1
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'TrlType2'
               SELECT @retval = trl_type2
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'TrlType3'
               SELECT @retval = trl_type3
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'TrlType4'
               SELECT @retval = trl_type4
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'Company'
               SELECT @retval = trl_company
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'Division'
               SELECT @retval = trl_division
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'Fleet'
               SELECT @retval = trl_fleet
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE IF @lbl_category = 'Terminal'
               SELECT @retval = trl_terminal
                 FROM trailerprofile WHERE trl_number = @res_id
            ELSE
               SELECT @retval = NULL
         END
      ELSE IF @res_type = 'Carrier'
         BEGIN
            IF @lbl_category = 'CarType1'
               SELECT @retval = car_type1
                 FROM carrier WHERE car_id = @res_id
            ELSE IF @lbl_category = 'CarType2'
               SELECT @retval = car_type2
                 FROM carrier WHERE car_id = @res_id
            ELSE IF @lbl_category = 'CarType3'
               SELECT @retval = car_type3
                 FROM carrier WHERE car_id = @res_id
            ELSE IF @lbl_category = 'CarType4'
               SELECT @retval = car_type4
                 FROM carrier WHERE car_id = @res_id
            ELSE
               SELECT @retval = NULL
         END
      ELSE
         BEGIN
            SELECT @retval = NULL
         END
   END

   IF @retval IS NULL
      SELECT @retval = 'UNK'

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[getResourceType_From_Log_sp] TO [public]
GO
