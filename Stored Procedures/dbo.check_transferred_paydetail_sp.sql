SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[check_transferred_paydetail_sp] 
( @mov_number int )
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Check if any transferred pay detail exists for the given mov_number.

*/

    IF EXISTS ( SELECT 1 FROM paydetail WHERE mov_number = @mov_number AND pyd_status = 'XFR')
       SELECT  'XFR' 
    ELSE
       SELECT  'NO XFR'

GO
GRANT EXECUTE ON  [dbo].[check_transferred_paydetail_sp] TO [public]
GO
