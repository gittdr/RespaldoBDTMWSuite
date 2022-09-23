SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vTTSTMW_TrailerAccessories]

As

SELECT           ta_type as 'Trailer Accessory Type', 
                 ta_id as 'Ta Id', 
                 ta_cost as 'Cost', 
                 ta_hours as 'Hours', 
                 ta_dateacquired as 'Trailer Accessory Date Acquired', 
                 ta_opercost as 'Operational Cost', 
                 ta_fueltype as 'Fuel Type', 
                 ta_quantity as 'Quantity',
	         vTTSTMW_TrailerProfile.*

FROM         dbo.trlaccessories Inner Join vTTSTMW_TrailerProfile On vTTSTMW_TrailerProfile.[Trailer ID] = ta_trailer




GO
GRANT SELECT ON  [dbo].[vTTSTMW_TrailerAccessories] TO [public]
GO
