SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[order_paperwork_query] @ord_number char ( 12 ) AS

Select bdt_doctype
From billdoctypes, orderheader
Where orderheader.ord_number = @ord_number
And ord_billto <> 'UNKNOWN'
And billdoctypes.cmp_id = orderheader.ord_billto
And IsNull(billdoctypes.bdt_inv_required,'Y')='Y' --PTS 36989

GO
GRANT EXECUTE ON  [dbo].[order_paperwork_query] TO [public]
GO
