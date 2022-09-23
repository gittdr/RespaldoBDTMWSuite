SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411ws_purge]
( @DAYS_OLD   INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_carrier411ws_purge
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to delete rows from carrier411ws, carrier411wslog and carrier411data for the DAYS_OLD
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @DAYS_OLD   INT
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 02/10/12
 *
 **/

SET NOCOUNT ON

BEGIN
   BEGIN TRAN sp_carrier411ws_purge
      DELETE FROM carrier411data
      WHERE BATCH_ID IN (SELECT BATCH_ID
                           FROM carrier411ws
                          WHERE DATEDIFF(DD, LastUpdateDate, GetDate()) >= @DAYS_OLD
                        )
      DELETE FROM carrier411wslog
      WHERE BATCH_ID IN (SELECT BATCH_ID
                           FROM carrier411ws
                          WHERE DATEDIFF(DD, LastUpdateDate, GetDate()) >= @DAYS_OLD
                        )
      DELETE FROM carrier411ws
      WHERE DATEDIFF(DD, LastUpdateDate, GetDate()) >= @DAYS_OLD
   COMMIT TRAN sp_carrier411ws_purge
END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411ws_purge] TO [public]
GO
