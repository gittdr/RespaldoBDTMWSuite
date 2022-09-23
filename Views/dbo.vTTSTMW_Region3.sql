SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vTTSTMW_Region3]

As

select rgh_id,rgh_name

from   regionheader (NOLOCK)
where  rgh_type = 3



GO
GRANT SELECT ON  [dbo].[vTTSTMW_Region3] TO [public]
GO
