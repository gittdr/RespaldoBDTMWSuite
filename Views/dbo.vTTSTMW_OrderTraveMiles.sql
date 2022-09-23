SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--select top 500 * from vTTSTMW_OrderTraveMiles

CREATE View [dbo].[vTTSTMW_OrderTraveMiles]

As



Select vTTSTMW_Orders.*,
       'Total Travel Miles' = dbo.fnc_TMWRN_MilesForOrder([Order Header Number],'ALL','DivideEvenly'),
       'Loaded Travel Miles' = dbo.fnc_TMWRN_MilesForOrder([Order Header Number],'LD','DivideEvenly'),
       'Empty Travel Miles' = dbo.fnc_TMWRN_MilesForOrder([Order Header Number],'MT','DivideEvenly')


From vTTSTMW_Orders


GO
GRANT SELECT ON  [dbo].[vTTSTMW_OrderTraveMiles] TO [public]
GO
