SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[load_label_incl_definition_sp] 
(
    @definition varchar(20)
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure.  This procedure returns all entries in the labelfile   with the labeldefinition. It is used in 'company group' dw's to populate the drop down datawindow displaying all item types.  This proc differs from load_label_sp in that it also returns the labeldefinition column.  This column is required to populate the labeldefinition field on the record being saved.

*/

BEGIN 

    SELECT name, 
    abbr, 
    code,
    labeldefinition
    FROM labelfile 
    WHERE labeldefinition = @definition 
    ORDER BY name
 END 
 
GO
GRANT EXECUTE ON  [dbo].[load_label_incl_definition_sp] TO [public]
GO
