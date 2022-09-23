SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[gettimecalc_shift_wrapper_sp]
      ( @invoice_of_settle CHAR(1)
      , @ord_or_lgh_number CHAR(1)
      , @the_number        INT
      , @retval            MONEY OUT
      )
AS

/*
*
*
* NAME:
* dbo.gettimecalc_shift_wrapper_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return times based upon shift schedule logs data
*
* RETURNS:
*
* RESULTSET
*
* 10/27/2011 PTS58399 SPN - Created Initial Version
* 11/22/2014 PTS84769 SPN - Round once per order
*
*/

SET NOCOUNT ON

BEGIN

   --BEGIN PTS 84769 SPN
   DECLARE @ShiftTimeRounding          CHAR(1)
   --END PTS 84769 SPN

   DECLARE @temp TABLE
   ( mov_number               INT            NULL
   , ord_hdrnumber            INT            NULL
   , lgh_number               INT            NULL
   , stp_event                VARCHAR(6)     NULL
   , ssl_activitydate_start   DATETIME       NULL
   , ssl_activitydate_end     DATETIME       NULL
   , ssl_activity_hrs         DECIMAL(5,2)   NULL
   , break_hours              DECIMAL(5,2)   NULL
   , settle_hours             DECIMAL(5,2)   NULL
   , invoice_hours            DECIMAL(5,2)   NULL
   )

   --BEGIN PTS 84769 SPN
   SELECT @ShiftTimeRounding = gi_string1 FROM generalinfo WHERE gi_name = 'ShiftTimeRounding'
   --END PTS 84769 SPN

   BEGIN TRY
      INSERT INTO @temp ( mov_number
                        , ord_hdrnumber
                        , lgh_number
                        , stp_event
                        , ssl_activitydate_start
                        , ssl_activitydate_end
                        , ssl_activity_hrs
                        , break_hours
                        , settle_hours
                        , invoice_hours
                        )
      EXEC gettimecalc_shift_sp @ord_or_lgh_number, @the_number
   END TRY
   BEGIN CATCH
      DELETE FROM @temp
   END CATCH

   --BEGIN PTS 84769 SPN
   IF @invoice_of_settle = 'S'
      BEGIN
         SELECT @retval = SUM(settle_hours)
           FROM @temp
      END
   ELSE
      BEGIN
         SELECT @retval = SUM(invoice_hours)
           FROM @temp
         IF @ShiftTimeRounding = 'Y'
            SELECT @retval = dbo.fnc_QuarterRound(@retval,'ROUND')
      END
   --END PTS 84769 SPN

   SELECT @retval = IsNull(@retval,0)

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[gettimecalc_shift_wrapper_sp] TO [public]
GO
