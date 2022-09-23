SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[InvoiceKM2018] AS 
SELECT invoicedetail.*, (select oh.ord_currencydate from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as curr_date,
   (select oh.ord_completiondate from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as ord_completiondate,
   (select oh.ord_completiondate from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as ord_dest_latestdate,
     -- (select oh.ord_dest_latestdate from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as ord_dest_latestdate,
      (select oh.ord_tractor from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as ord_tractor,
   (select oh.ord_status from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as ord_status,
    (select oh.ord_revtype2 from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) as ord_revtype2
,ih.ivh_printdate
FROM invoicedetail
left JOIN invoiceheader ih on ih.ord_hdrnumber = invoicedetail.ord_hdrnumber
WHERE (select oh.ord_completiondate from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) > '2019-01-01' and
(select oh.ord_status from orderheader oh where oh.ord_hdrnumber = invoicedetail.ord_hdrnumber) = 'CMP'
--2018 en adelante

GO
