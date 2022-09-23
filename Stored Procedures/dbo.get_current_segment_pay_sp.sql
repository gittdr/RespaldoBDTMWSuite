SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_current_segment_pay_sp]
(
@lgh_number int
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    SELECT pyd_number,
       pyt_itemcode,
       pyd_amount,
       ivd_number,
       'N' 'checked'
    FROM paydetail
    WHERE lgh_number = @lgh_number

GO
GRANT EXECUTE ON  [dbo].[get_current_segment_pay_sp] TO [public]
GO
