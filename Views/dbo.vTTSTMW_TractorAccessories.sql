SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   View [dbo].[vTTSTMW_TractorAccessories]

As

SELECT           tca_type as 'Tractor Accessory Type', 
                 tca_id as 'Ta Id', 
                 tca_cost as 'Cost', 
                 tca_hours as 'Hours', 
                 tca_dateaquired as 'Tractor Accessory Date Acquired', 
                 tca_opercost as 'Operational Cost', 
                 tca_fueltype as 'Fuel Type', 
		 tca_quantitiy as 'Quantity',
		 vTTSTMW_TractorProfile.*

FROM         tractoraccesories Inner Join vTTSTMW_TractorProfile On vTTSTMW_TractorProfile.[Tractor] = tca_tractor






GO
GRANT SELECT ON  [dbo].[vTTSTMW_TractorAccessories] TO [public]
GO
