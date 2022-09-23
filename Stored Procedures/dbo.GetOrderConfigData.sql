SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetOrderConfigData] (@ordhdr int)

AS
/*   DPETE 10/06/04

 Returns the information needed for making sure we verify the assets assigned
 to an order match those expected by the ord_trlconfiguration

DPETE 40260 recode Pauls

*/
Select
ord_hdrnumber
,ord_trlconfiguration = IsNull(ord_trlconfiguration,'UNK')
,ord_nomincharges
From orderheader 
Where ord_hdrnumber = @ordhdr



GO
GRANT EXECUTE ON  [dbo].[GetOrderConfigData] TO [public]
GO
