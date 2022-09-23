SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[MileagetableByIdentity] @ID int
As  
/*   
SR 22841 DPETE created 8/16/04
  Pass new mileagetable identity to get back the information
  8/26/04 drop city name s we cache the location with the name rather than code
 
 * REVISION HISTORY:
 * Date ? 	PTS# - 	AuthorName	 ? Revision Description
 * 11/22/2006	35219	SLM		Add column mt_tolls_cost 
 
*/ 

Select mt_type
,mt_origintype
,mt_origin
,mt_destinationtype
,mt_destination
,mt_miles
,mt_hours
,mt_updatedby
,mt_updatedon
,mt_verified
,mt_old_miles
,mt_route
,mt_Authorized = IsNull(mt_Authorized,'N')
,mt_AuthorizedBy = IsNull(mt_AuthorizedBY,'')
,Mt_authorizedDate
,mt_identity
,mt_tolls_cost
,mt_haztype
From mileagetable
Where mt_identity = @ID


GO
GRANT EXECUTE ON  [dbo].[MileagetableByIdentity] TO [public]
GO
