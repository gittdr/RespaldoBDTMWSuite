SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vSSRSRB_TrailerAccessories]
As

/*****************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_TrailerAccessories]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old [vSSRSRB_TrailerAccessories]
 *
******************************************************************

Sample call
	
select * from [vSSRSRB_TrailerAccessories]

******************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created new view
 *****************************************************************/

SELECT ta_type as 'Trailer Accessory Type', 
       ta_id as 'Ta Id', 
       ta_cost as 'Cost', 
       ta_hours as 'Hours', 
       ta_dateacquired as 'Trailer Accessory Date Acquired', 
       ta_opercost as 'Operational Cost', 
       ta_fueltype as 'Fuel Type', 
       ta_quantity as 'Quantity',
	   vSSRSRB_TrailerProfile.*
FROM dbo.trlaccessories 
Inner Join vSSRSRB_TrailerProfile 
	On vSSRSRB_TrailerProfile.[Trailer ID] = ta_trailer

GO
