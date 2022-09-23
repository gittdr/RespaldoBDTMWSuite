SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE View [dbo].[vSSRSRB_StopFreightDetail]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_StopFreightDetail
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED  created 
 * 3/31/2014 DW		Changed inner join to outer join
 **/

SELECT *
FROM vSSRSRB_StopDetail
LEFT JOIN vSSRSRB_FreightDetail
	ON vSSRSRB_StopDetail.[Stop Number] = vSSRSRB_FreightDetail.[Freight Detail Stop Number]
	

GO
GRANT SELECT ON  [dbo].[vSSRSRB_StopFreightDetail] TO [public]
GO
