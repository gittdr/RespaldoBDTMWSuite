SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[vSSRSRB_Region4]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_Region24 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data from regionheader where rgh_type = 4
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/

select rgh_id,rgh_name
	from   regionheader WITH (NOLOCK)
	where  rgh_type = 4

GO
GRANT SELECT ON  [dbo].[vSSRSRB_Region4] TO [public]
GO
