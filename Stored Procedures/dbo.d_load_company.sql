SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_company]
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Retrieves all Trimac Companies.

*/

BEGIN

    select brn_orgtype1, brn_id, name
    from labelfile
        INNER JOIN branch ON abbr = brn_orgtype1
    where labeldefinition = 'Company'
    order by name
    
END

GO
GRANT EXECUTE ON  [dbo].[d_load_company] TO [public]
GO
