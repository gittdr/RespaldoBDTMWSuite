SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE     View [dbo].[vTTSTMW_OrderReferenceNumbers]

As

Select TempRefs.*,
       (select cmp_name from company (NOLOCK) where [Company ID] = cmp_id) as [Company Name],
       (select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city (NOLOCK) where cty_code = [City Code]) as [CityState]
From

(

Select Orders.*,
       ReferenceNumbers.[Table Key],
       ReferenceNumbers.[Ref Type] as ReferenceType,
       ReferenceNumbers.[Ref Number] as ReferenceNumber,
       (select cmp_id from stops (NOLOCK) where stp_number = [Table Key] and [Table] = 'stops') as [Company ID],
       (select stp_city from stops (NOLOCK) where stp_number = [Table Key] and [Table] = 'stops') as [City Code],
       [Type Desc],
       [Sequence],
       [Table],
       [SID],
       [Pickup]

        

From   vTTSTMW_Orders Orders,
       vTTSTMW_ReferenceNumbers ReferenceNumbers

Where  Orders.[Order Header Number] = ReferenceNumbers.[Order Header Number]
   

) as TempRefs









GO
GRANT SELECT ON  [dbo].[vTTSTMW_OrderReferenceNumbers] TO [public]
GO
