SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cleanup_asgns] 
AS 

return

/*delete assetassignment
from (SELECT DISTINCT lgh_number 
	FROM assetassignment WHERE asgn_date >= GetDate() -5) newlegs
where not exists (select * from legheader where newlegs.lgh_number = legheader.lgh_number) and
	assetassignment.lgh_number = newlegs.lgh_number*/

GO
GRANT EXECUTE ON  [dbo].[cleanup_asgns] TO [public]
GO
