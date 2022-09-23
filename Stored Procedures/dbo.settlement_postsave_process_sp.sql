SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[settlement_postsave_process_sp]
( @Settlement_PostSave_Process   VARCHAR(MAX)
, @pyh_pyhnumber                 INT
, @asgn_type                     VARCHAR(6)
, @asgn_id                       VARCHAR(13)
, @pyh_payperiod                 DATETIME
, @pyh_paystatus                 VARCHAR(6)
, @psd_id                        INT
, @RetVal                        INT OUTPUT
, @RetMsg                        VARCHAR(255) OUTPUT
)
AS

/*
*
*
* NAME:
* dbo.settlement_postsave_process_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Wrapper Stored Procedure for any custom Post Save process of Final Settlement
*
* RETURNS:
*
* NOTHING:
*
* 10/22/2012 PTS63193 SPN - Created Initial Version
*
*/

BEGIN

   DECLARE @ls_msg VARCHAR(255)

   SELECT @Settlement_PostSave_Process = ',' + ISNULL(@Settlement_PostSave_Process,'-') + ','
   SELECT @RetVal = 0
   SELECT @RetMsg = NULL

   --Guranteed Pay
   IF CHARINDEX(',GuaranteedPay,', @Settlement_PostSave_Process) > 0
      IF IsNull(@pyh_pyhnumber,0) > 0 AND IsNull(@pyh_paystatus,'XFR') = 'COL'
         BEGIN
            EXEC @RetVal = guaranteedpay_final_settltment_sp @pyh_pyhnumber, @ls_msg OUT
            If IsNull(@RetVal,0) < 0
               BEGIN
                  SELECT @RetMsg = @ls_msg
                  RETURN
               END
         END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[settlement_postsave_process_sp] TO [public]
GO
