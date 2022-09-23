SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vSSRSRB_OrderTraveMiles]
AS

/**
 *
 * NAME:
 * dbo.vSSRSRB_OrderTraveMiles
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for OrderTraveMiles
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/
 

Select vSSRSRB_Orders.*,
       'Total Travel Miles' = dbo.fnc_ssrs_MilesForOrder([Order Header Number],'ALL','DivideEvenly'),
       'Loaded Travel Miles' = dbo.fnc_ssrs_MilesForOrder([Order Header Number],'LD','DivideEvenly'),
       'Empty Travel Miles' = dbo.fnc_ssrs_MilesForOrder([Order Header Number],'MT','DivideEvenly')

From vSSRSRB_Orders

GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderTraveMiles] TO [public]
GO
