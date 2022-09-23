SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION [dbo].[tmwf_scroll_assignments_concat_new]
( @mov_number  INT
)
RETURNS VARCHAR(5000)
AS

/**
 *
 * NAME:
 * dbo.tmwf_scroll_assignments_concat_new
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure used for returning Trip Description for a given move
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @mov_number                  INT
 *
 * REVISION HISTORY:
 * PTS 66553 SPN 04/03/2013 - Initial Version Created
 *
 **/


BEGIN

   DECLARE @ls_tripdesc VARCHAR(5000)

   SET @ls_tripdesc = ''

   SELECT @ls_tripdesc = @ls_tripdesc + '/' + rtrim(ord_number)
     FROM orderheader
    WHERE mov_number = @mov_number
      AND ord_number IS NOT NULL
   ORDER BY ord_number

   SELECT @ls_tripdesc = SUBSTRING(@ls_tripdesc,2,DATALENGTH(@ls_tripdesc))
    WHERE DATALENGTH(@ls_tripdesc) > 0

   RETURN @ls_tripdesc

END
GO
GRANT EXECUTE ON  [dbo].[tmwf_scroll_assignments_concat_new] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmwf_scroll_assignments_concat_new] TO [public]
GO
