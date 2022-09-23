SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  View [dbo].[vSSRSRB_Region1]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_Region1
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data from regionheader where rgh_type = 1
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Revised 
 **/
 
select rgh_id,rgh_name
	from   regionheader WITH (NOLOCK)
	where  rgh_type = 1

GO
GRANT SELECT ON  [dbo].[vSSRSRB_Region1] TO [public]
GO
