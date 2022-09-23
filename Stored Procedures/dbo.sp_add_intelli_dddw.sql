SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_add_intelli_dddw] 
( @window               VARCHAR(100)
, @datawindow           VARCHAR(100)
, @dwcolname            VARCHAR(50)
, @dddw_name            VARCHAR(100)
, @dddw_displaycolumn   VARCHAR(50)
, @dddw_datacolumn      VARCHAR(50)
) AS
/**
 *
 * NAME:
 * dbo.sp_add_intelli_dddw
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for adding rows into intelli_dddw
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @window               VARCHAR(100)
 * 002 @datawindow           VARCHAR(100)
 * 003 @dwcolname            VARCHAR(50)
 * 004 @dddw_name            VARCHAR(100)
 * 005 @dddw_displaycolumn   VARCHAR(50)
 * 006 @dddw_datacolumn      VARCHAR(50)
 *
 * REVISION HISTORY:
 * PTS 56318 SPN 05/25/11 - Initial Version Created
 * 
 **/

SET NOCOUNT ON

BEGIN
   IF NOT EXISTS ( SELECT 1 
                     FROM intelli_dddw 
                    WHERE window = @window
                      AND datawindow = @datawindow
                      AND dwcolname = @dwcolname
                 )
   BEGIN
      INSERT INTO intelli_dddw(window, datawindow, dwcolname, dddw_name, dddw_displaycolumn, dddw_datacolumn, retired)
      VALUES(@window, @datawindow, @dwcolname, @dddw_name, @dddw_displaycolumn, @dddw_datacolumn, 'Y')
   END
   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_add_intelli_dddw] TO [public]
GO
