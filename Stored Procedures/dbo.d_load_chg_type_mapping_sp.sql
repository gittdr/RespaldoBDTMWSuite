SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_chg_type_mapping_sp] 
(
@brn_id varchar(8) 
)

AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns associate/invoice mapping by branch id.

*/

    SELECT
        brn_id                ,
        fee_schedule_itemcode ,
        cht_itemcode          ,
        created_date          ,
        created_by
    FROM associate_fee_schedule_inv_map
    WHERE brn_id = @brn_id    

GO
GRANT EXECUTE ON  [dbo].[d_load_chg_type_mapping_sp] TO [public]
GO
