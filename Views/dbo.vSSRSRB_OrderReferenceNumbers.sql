SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_OrderReferenceNumbers]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_OrderReferenceNumbers]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_OrderReferenceNumbers
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_OrderReferenceNumbers]

**************************************************************************
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
 * 3/19/2014 DW created view
 ***********************************************************/

Select TempRefs.*,
       (select cmp_name from company WITH (NOLOCK) where [Company ID] = cmp_id) as [Company Name],
       (select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city WITH (NOLOCK) where cty_code = [City Code]) as [CityState]
From
(
Select Orders.*,
       ReferenceNumbers.[Table Key],
       ReferenceNumbers.[Ref Type] as ReferenceType,
       ReferenceNumbers.[Ref Number] as ReferenceNumber,
       (select cmp_id from stops WITH (NOLOCK) where stp_number = [Table Key] and [Table] = 'stops') as [Company ID],
       (select stp_city from stops WITH (NOLOCK) where stp_number = [Table Key] and [Table] = 'stops') as [City Code],
       [Type Desc],
       [Sequence],
       [Table],
       [SID],
       [Pickup]
From   vSSRSRB_Orders Orders
	join vSSRSRB_ReferenceNumbers ReferenceNumbers  on Orders.[Order Header Number] = ReferenceNumbers.[Order Header Number]

) as TempRefs

GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderReferenceNumbers] TO [public]
GO
