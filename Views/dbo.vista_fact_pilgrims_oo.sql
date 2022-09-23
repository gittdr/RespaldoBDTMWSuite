SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE  view [dbo].[vista_fact_pilgrims_oo]
as
--select ord_company,
--ord_number,
--ord_refnum,
--'http://10.176.167.171/cgi-bin/img-docfind.pl?reftype=ORD&refnum=' + ord_number as imaging,
--ord_status
--from orderheader 
--where ord_refnum in (
--'93009','93051','93173','93595','93610','93615','93617','93618','93627','93629','93632','93634','93638','93651','93653','93654','93656','93662','93664','93665','93667','93673','93677','93680','93682','93686','93690','93688','93692','93691','93689','93693','93670','93694','93696','93699','93704','93705','93710','93711','93714','93674','93717','93725','93731','93732','93726','93734'

--)
--and ord_billto = 'pilgrims' and ord_status = 'CMP'
--union 
select ord_company,
ord_number,
ord_refnum,
'http://10.176.167.171/cgi-bin/img-docfind.pl?reftype=ORD&refnum=' + ord_number as imaging,
ord_status
from orderheader
where ord_hdrnumber in
 (select ord_hdrnumber from paperwork
where ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = 'pilgrims' and ord_completiondate > '2020-01-01')
and cast(paperwork.pw_dt as date) >= cast(getdate() as date)
and abbr = 'bi' and last_updatedby = 'PWReceivedY002_sp') --and ord_hdrnumber = '988619'-- and ord_hdrnumber = '988619' 
GO
