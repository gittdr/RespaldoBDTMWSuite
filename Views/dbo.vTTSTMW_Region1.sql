SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vTTSTMW_Region1]

As

select rgh_id,rgh_name

from   regionheader (NOLOCK)
where  rgh_type = 1



GO
GRANT SELECT ON  [dbo].[vTTSTMW_Region1] TO [public]
GO
