SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[stlmnt_epaylog_resend_sp] 
      ( @Query_ID          VARCHAR(30)
      , @reference_number  VARCHAR(30)
      , @voucher_number    VARCHAR(30)
      , @ErrorMessage      NVARCHAR(250) OUT
      )
AS

/*
*
*
* NAME:
* dbo.stlmnt_epaylog_resend_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to setup paydetail and epaytransadd_log for resend
*
* RETURNS:
*
* NOTHING:
*
* 05/16/2011 PTS55706 SPN - Created Initial Version
*
*/ 

SET NOCOUNT ON

DECLARE @Is_TMW_ord_number INT
      , @Is_TMW_lgh_number INT
      , @ll_Count          INT

BEGIN

   BEGIN
      SELECT @Is_TMW_ord_number = IsNumeric(reference_number)
           , @Is_TMW_lgh_number = IsNumeric(voucher_number)
        FROM epaytransadd_log
       WHERE query_id = @Query_id
         AND reference_number = @reference_number
         AND voucher_number = @voucher_number
      IF @Is_TMW_ord_number <> 1
      BEGIN
         SELECT @ErrorMessage = 'Not a valid Order#'
         RETURN
      END
      IF @Is_TMW_lgh_number <> 1
      BEGIN
         SELECT @ErrorMessage = 'Not a valid Trip#'
         RETURN
      END

      SELECT @ll_Count = COUNT(1)
        FROM orderheader
       WHERE ord_number = @reference_number
      IF @ll_Count <= 0
      BEGIN
         SELECT @ErrorMessage = 'Not a valid TMW Suite Order#'
         RETURN
      END

      SELECT @ll_Count = COUNT(1)
        FROM legheader
       WHERE lgh_number = @voucher_number
      IF @ll_Count <= 0
      BEGIN
         SELECT @ErrorMessage = 'Not a valid TMW Suite Trip#'
         RETURN
      END

      SELECT @ll_Count = COUNT(1)
        FROM paydetail
       WHERE lgh_number = @voucher_number
      IF @ll_Count <= 0
      BEGIN
         SELECT @ErrorMessage = 'No Paydetail found for this TMW Suite Trip#'
         RETURN
      END

      SELECT @ll_Count = COUNT(1)
        FROM paydetail
       WHERE lgh_number = @voucher_number
         AND pyd_status = 'REL'
      IF @ll_Count > 0
      BEGIN
         SELECT @ErrorMessage = 'Paydetail closed for this TMW Suite Trip# and it can not be reset'
         RETURN
      END

      BEGIN TRAN epayresend
      BEGIN TRY
            UPDATE epaytransadd_log
               SET error_flag = 'Y'
                 , msgtext = 'Resending...'
             WHERE query_id = @Query_id
               AND reference_number = @reference_number
               AND voucher_number = @voucher_number
            UPDATE paydetail
               SET pyd_status = 'HLD'
             WHERE lgh_number = @voucher_number
      END TRY
      BEGIN CATCH
         ROLLBACK TRAN epayresend
      END CATCH
      COMMIT TRAN epayresend
         
   END

   SELECT @ErrorMessage = NULL
   RETURN
      
END
GO
GRANT EXECUTE ON  [dbo].[stlmnt_epaylog_resend_sp] TO [public]
GO
