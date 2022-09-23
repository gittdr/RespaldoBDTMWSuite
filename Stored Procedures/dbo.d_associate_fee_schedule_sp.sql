SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_fee_schedule_sp]
(
 @brn_id varchar(8)
)
 AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Provides data for d_assoc_fee_schd datawindow.

*/
    SELECT
        brn_id                ,
        fee_schedule_itemcode ,
        associate_percent     ,
        description           ,
        active                ,
        manual                ,
        allow_rev_allocation_edits,
        created_date          ,
        created_by            ,
        modified_date         ,
        modified_by
    FROM associate_fee_schedule
    WHERE brn_id = @brn_id
    
GO
GRANT EXECUTE ON  [dbo].[d_associate_fee_schedule_sp] TO [public]
GO
