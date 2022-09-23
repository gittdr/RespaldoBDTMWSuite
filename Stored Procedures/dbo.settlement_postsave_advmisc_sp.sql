SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[settlement_postsave_advmisc_sp]
( @Action         VARCHAR(15)
, @pyd_number     INT
, @pyh_number     INT
, @lgh_number     INT
, @asgn_number    INT
, @asgn_type      VARCHAR(6)
, @asgn_id        VARCHAR(13)
, @pyt_itemcode   VARCHAR(6)
, @pyd_quantity   FLOAT
, @pyd_rate       MONEY
, @pyd_amount     MONEY
, @pyd_status     VARCHAR(6)
, @pyh_payperiod  DATETIME
, @RetVal         INT OUTPUT
, @RetMsg         VARCHAR(MAX) OUTPUT
)
AS

/*
*
*
* NAME:
* dbo.settlement_postsave_advmisc_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Wrapper Stored Procedure for any custom Post Save process of Advance Miscellaneous Labor Window
*
* RETURNS:
*
* NOTHING:
*
* 12/13/2012 PTS65642 SPN - Created Initial Version
*
*/

BEGIN

   DECLARE @Process VARCHAR(60)

   SELECT @Process = ',' + ISNULL(gi_string2,'-') + ','
     FROM generalinfo
    WHERE gi_name = 'PostSaveAdvMisc'

   SELECT @RetVal = 0
   SELECT @RetMsg = NULL

   --sp_advmisc_log
   IF CHARINDEX(',sp_advmisc_log,', @Process) > 0
      BEGIN TRY
         EXEC @RetVal = sp_advmisc_log @Action = @action, @pyd_number = @pyd_number
      END TRY
      BEGIN CATCH
         SELECT @RetVal = -1
         SELECT @RetMsg = error_message()
      END CATCH

   RETURN 0

END
GO
GRANT EXECUTE ON  [dbo].[settlement_postsave_advmisc_sp] TO [public]
GO
