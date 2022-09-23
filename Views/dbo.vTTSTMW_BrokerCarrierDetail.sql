SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--select top 100 * from vTTSTMW_BrokerCarrierDetail

CREATE View [dbo].[vTTSTMW_BrokerCarrierDetail]

As

/* modification log
06/18/03 BLM	17421	replace getdate with dbo.TMW_GETDATE.
11/12/03  BLM		add settlement currency
*/


select pyd_amount as [Amount], 
       pyd_description as [Description], 
       pyt_itemcode as [Pay Type], 
       TempOrder.* ,
       [Pay Currency] = isNull(pyd_currency, '')

from   paydetail (NOLOCK),
(

select
	vTTSTMW_Orders.*
        --lgh_carrier as [Carrier ID]
from  LegHeader (NOLOCK),
      vTTSTMW_Orders (NOLOCK)  
where vTTSTMW_Orders.[Order Header Number] = LegHeader.ord_hdrnumber
      And
      lgh_outstatus = 'CMP'

) As TempOrder

where Paydetail.ord_hdrnumber = TempOrder.[Order Header Number]
      and 
      paydetail.pyt_itemcode in (select pyt_itemcode from paytype where pyt_basis = 'LGH') 
   







GO
GRANT SELECT ON  [dbo].[vTTSTMW_BrokerCarrierDetail] TO [public]
GO
