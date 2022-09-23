SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_branch]
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Retrieves all Trimac Branches.

*/

BEGIN

    select name, abbr, code, brn_orgtype1
      from labelfile
        INNER JOIN branch ON abbr = brn_id
     where labeldefinition = 'RevType1' 
    order by name

END

GO
GRANT EXECUTE ON  [dbo].[d_load_branch] TO [public]
GO
