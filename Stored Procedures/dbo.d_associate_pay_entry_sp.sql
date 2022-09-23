SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_pay_entry_sp] 
    (@mov_number int)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    SELECT
        entry_id          ,
        mov_number        ,
        processed_date    ,
        processed_by      ,
        transferred_date  ,
        notes             ,
        entry_type        ,
        accounting_year   ,
        accounting_period ,
        accounting_week   ,
        ape_status
    FROM associate_pay_entry
    WHERE mov_number = @mov_number

GO
GRANT EXECUTE ON  [dbo].[d_associate_pay_entry_sp] TO [public]
GO
