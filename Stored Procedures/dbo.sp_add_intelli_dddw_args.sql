SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_add_intelli_dddw_args] 
( @window               VARCHAR(100)
, @datawindow           VARCHAR(100)
, @dwcolname            VARCHAR(50)
, @seqno                INT
, @arg                  VARCHAR(50)
) AS
/**
 *
 * NAME:
 * dbo.sp_add_intelli_dddw_args
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for adding rows into intelli_dddw_args
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @window               VARCHAR(100)
 * 002 @datawindow           VARCHAR(100)
 * 003 @dwcolname            VARCHAR(50)
 * 004 @seqno                INT
 * 005 @arg                  VARCHAR(50)
 *
 * REVISION HISTORY:
 * PTS 56318 SPN 05/25/11 - Initial Version Created
 * 
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @intelli_dddw_id      INT

   SELECT @intelli_dddw_id = intelli_dddw_id
     FROM intelli_dddw
    WHERE window     = @window
      AND datawindow = @datawindow
      AND dwcolname  = @dwcolname
   IF @intelli_dddw_id IS NOT NULL
   BEGIN
      IF NOT EXISTS (SELECT 1
                       FROM intelli_dddw_args
                      WHERE intelli_dddw_id= @intelli_dddw_id
                        AND seqno = @seqno
                    )
         INSERT INTO intelli_dddw_args(intelli_dddw_id, seqno, arg)
         VALUES(@intelli_dddw_id, @seqno, @arg)
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_add_intelli_dddw_args] TO [public]
GO
