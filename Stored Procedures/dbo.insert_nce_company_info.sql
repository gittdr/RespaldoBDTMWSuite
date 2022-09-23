SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[insert_nce_company_info]
(
    @p_parent_id varchar(50),
    @p_cmp_id varchar(50),
    @p_contact_type  varchar(6)
)

AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Insert data into nce_company_info table.

EXEC insert_nce_company_info 'TEST', 'CHILD', 'C'

*/

BEGIN

    INSERT INTO dbo.nce_company_info
             ( ncec_cmp_parent_id,
               ncec_cmp_child_id,
               ncec_contact_type )
      VALUES ( @p_parent_id,
               @p_cmp_id,
               @p_contact_type )
    
    return 0

END
GO
GRANT EXECUTE ON  [dbo].[insert_nce_company_info] TO [public]
GO
