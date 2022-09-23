SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_add_ConfirmChoice_args]
( @source_window        VARCHAR(100)
, @source_datawindow    VARCHAR(100)
, @source_dwcolname     VARCHAR(50)
, @seqno                INT
, @arg                  VARCHAR(50)
) AS
/**
 *
 * NAME:
 * dbo.sp_add_ConfirmChoice_args
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for adding rows into confirmchoice_args
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @source_window        VARCHAR(100)
 * 002 @source_datawindow    VARCHAR(100)
 * 003 @source_dwcolname     VARCHAR(50)
 * 004 @seqno                INT
 * 005 @arg                  VARCHAR(50)
 *
 * REVISION HISTORY:
 * PTS 60176 SPN 01/30/12 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @confirmchoice_id      INT

   SELECT @confirmchoice_id = confirmchoice_id
     FROM confirmchoice
    WHERE source_window     = @source_window
      AND source_datawindow = @source_datawindow
      AND source_dwcolname  = @source_dwcolname
   IF @confirmchoice_id IS NOT NULL
   BEGIN
      IF NOT EXISTS (SELECT 1
                       FROM confirmchoice_args
                      WHERE confirmchoice_id= @confirmchoice_id
                        AND seqno = @seqno
                    )
         BEGIN
            INSERT INTO confirmchoice_args(confirmchoice_id, seqno, arg)
            VALUES(@confirmchoice_id, @seqno, @arg)
         END
      ELSE
         BEGIN
            UPDATE confirmchoice_args
               SET arg = @arg
             WHERE confirmchoice_id= @confirmchoice_id
               AND seqno = @seqno
               AND arg <> @arg
         END
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_add_ConfirmChoice_args] TO [public]
GO
