SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[GetMiscParentNumber_sp]  (@p_invhdrnumber int)
as

/* This proc takes a misc ivh_hdrnumber and retrieves the ivh_hdrnumber for the 'parent' misc invoice from invoiceheader_misc */

SELECT coalesce(t2.ihm_hdrnumber,0) as ivh_hdrnumber
FROM invoiceheader_misc t1
JOIN invoiceheader_misc t2 on t2.ihm_invoicenumber = t1.ihm_misc_number
where t1.ihm_hdrnumber = @p_invhdrnumber

GO
GRANT EXECUTE ON  [dbo].[GetMiscParentNumber_sp] TO [public]
GO
