SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[load_label_fee_schd_item_sp] 
(
 @name varchar(20), 
 @branch varchar(8)
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns labelfile info for a given branch, itemcode pair.

*/
   SELECT distinct l.name,
            l.abbr,
            l.code
    FROM labelfile l INNER JOIN associate_fee_schedule a
        ON l.abbr = a.fee_schedule_itemcode
    WHERE a.active = 'Y'
    and l.labeldefinition = @name
    and a.brn_id = @branch
    ORDER BY l.name
    
GO
GRANT EXECUTE ON  [dbo].[load_label_fee_schd_item_sp] TO [public]
GO
