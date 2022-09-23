SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[orderstoinvoice_sp]
AS
SELECT orderheader.ord_number, orderheader.ord_hdrnumber 
FROM orderheader
WHERE 	( orderheader.ord_invoicestatus = 'AVL' ) AND 
	( orderheader.ord_startdate between '19500101 0:0:0.000' and '20491231 23:59:59.000' ) AND 
	( orderheader.ord_completiondate between '19500101 0:0:0.000' and '20491231 23:59:59.000' ) 
order by ord_hdrnumber, ord_completiondate

GO
GRANT EXECUTE ON  [dbo].[orderstoinvoice_sp] TO [public]
GO
