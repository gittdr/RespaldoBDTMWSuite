SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_add_ConfirmChoice]
( @source_window        VARCHAR(100)
, @source_datawindow    VARCHAR(100)
, @source_dwcolname     VARCHAR(50)
, @windowtitle          VARCHAR(50)
, @textlength_below     INT
, @list_dw              VARCHAR(100)
, @list_dw_datacolumn   VARCHAR(100)
) AS
/**
 *
 * NAME:
 * dbo.sp_add_ConfirmChoice
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for adding rows into confirmchoice
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @source_window        VARCHAR(100)
 * 002 @source_datawindow    VARCHAR(100)
 * 003 @source_dwcolname     VARCHAR(50)
 * 004 @windowtitle          VARCHAR(50)
 * 005 @textlength_below     INT
 * 006 @list_dw              VARCHAR(100)
 * 007 @list_dw_datacolumn   VARCHAR(100)
 *
 * REVISION HISTORY:
 * PTS 60176 SPN 02/29/12 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN
   IF NOT EXISTS ( SELECT 1
                     FROM confirmchoice
                    WHERE source_window = @source_window
                      AND source_datawindow = @source_datawindow
                      AND source_dwcolname = @source_dwcolname
                 )
      BEGIN
         INSERT INTO confirmchoice(source_window, source_datawindow, source_dwcolname, windowtitle, textlength_below, list_dw, list_dw_datacolumn, retired)
         VALUES(@source_window, @source_datawindow, @source_dwcolname, @windowtitle, @textlength_below, @list_dw, @list_dw_datacolumn, 'Y')
      END
   ELSE
      BEGIN
         UPDATE confirmchoice
            SET windowtitle         = @windowtitle
              , textlength_below    = @textlength_below
              , list_dw             = @list_dw
              , list_dw_datacolumn  = @list_dw_datacolumn
          WHERE source_window     = @source_window
            AND source_datawindow = @source_datawindow
            AND source_dwcolname  = @source_dwcolname
            AND (  windowtitle <> @windowtitle
                OR list_dw <> @list_dw
                OR list_dw_datacolumn <> @list_dw_datacolumn
                )
      END
   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_add_ConfirmChoice] TO [public]
GO
