SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vTTSTMW_Region4]

As

select rgh_id,rgh_name

from   regionheader (NOLOCK)
where  rgh_type = 4



GO
GRANT SELECT ON  [dbo].[vTTSTMW_Region4] TO [public]
GO
