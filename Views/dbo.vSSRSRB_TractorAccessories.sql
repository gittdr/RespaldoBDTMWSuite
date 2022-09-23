SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   View [dbo].[vSSRSRB_TractorAccessories]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_TractorAccessories
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for TractorAccessories
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/
 
SELECT           tca_type  as 'Tractor Accessory Type', 
                 tca_id    as 'Ta Id', 
                 tca_cost  as 'Cost', 
                 tca_hours as 'Hours', 
                 tca_dateaquired as 'Tractor Accessory Date Acquired', 
                 tca_opercost    as 'Operational Cost', 
                 tca_fueltype    as 'Fuel Type', 
		         tca_quantitiy   as 'Quantity',
		         vSSRSRB_TractorProfile.*

FROM  tractoraccesories Inner Join vSSRSRB_TractorProfile On vSSRSRB_TractorProfile.[Tractor] = tca_tractor

GO
