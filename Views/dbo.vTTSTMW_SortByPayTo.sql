SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vTTSTMW_SortByPayTo] As

Select   Top 100 Percent
         pto_id,pto_lastfirst
From     payto WITH (NOLOCK)
Order By pto_id ASC


GO
GRANT SELECT ON  [dbo].[vTTSTMW_SortByPayTo] TO [public]
GO
