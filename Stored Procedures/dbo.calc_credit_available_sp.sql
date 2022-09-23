SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*

exec [calc_credit_available_sp] 
*/




CREATE PROC [dbo].[calc_credit_available_sp] 
as
set nocount on

declare @date datetime
set @date = getdate ()

delete from creditcheck

insert into creditcheck (cmp_id, alt_id)
select distinct (cmp_id), cmp_altid
from company 
where cmp_billto = 'Y' and cmp_active = 'Y'
and cmp_id in (select custnmbr from [172.24.16.113].TDR.dbo.rm00103) or cmp_altid in (select custnmbr from [172.24.16.113].TDR.dbo.rm00103)
order by cmp_id


/*
update creditcheck
set cmp_aging1 = isnull (g.agperamt_1,0),  -- a tiempo
cmp_aging2 = isnull (g.agperamt_2,0),  -- 15 dias
cmp_aging3 = isnull (g.agperamt_3,0), -- 30 dias
cmp_aging4 = isnull (g.agperamt_4,0), -- + 30
cmp_aging5 = isnull (g.agperamt_5,0),  --  Por Aplicar
cmp_aging6 = isnull (g.agperamt_6 + g.agperamt_7,0)  -- no use
from [172.24.16.113].TDR.dbo.rm00103 g
join creditcheck c on g.custnmbr = c.cmp_id or g.custnmbr = c.alt_id
*/

update creditcheck
set 
cmp_aging1 = isnull (g.agperamt_1,0),  -- a tiempo
cmp_aging2 = isnull (g.agperamt_2,0),  -- 15 dias
cmp_aging3 = isnull (g.agperamt_3,0), -- 30 dias
cmp_aging4 = isnull (g.agperamt_4,0), -- + 30
cmp_aging5 = isnull (g.agperamt_5,0),  -- no use
cmp_aging6 = isnull (g.agperamt_6 + g.agperamt_7,0)  -- no use
 from [172.24.16.113].TDR.dbo.CuentasPorCobrarDoctoBuckets g
 join creditcheck c on g.custnmbr = c.cmp_id or g.custnmbr = c.alt_id



update company  
   set cmp_creditavail = IsNull(cmp_creditlimit, 0) - IsNull((Select IsNull(creditcheck.cmp_aging1, 0) + IsNull(creditcheck.cmp_aging2, 0) + IsNull(creditcheck.cmp_aging3, 0) + IsNull(creditcheck.cmp_aging4, 0)-- + IsNull(creditcheck.cmp_aging5, 0) + IsNull(creditcheck.cmp_aging6, 0) 
                                                                from creditcheck 
                                                               where creditcheck.cmp_id = company.cmp_id), 0)

 where IsNull(cmp_billto, 'N') = 'Y'
  
update company 
   set cmp_creditavail = cmp_creditavail - IsNull((Select sum(ivh_totalcharge) 
                                                     from invoiceheader  WITH (NOLOCK) 
                                                    where ivh_billto = cmp_id 
                                                      and ivh_invoicestatus  not in ('CAN','XFR','ntp')),0)
													  
													  /* (select abbr 
                                                                                  from labelfile 
                                                                                 where labeldefinition = 'InvoiceStatus' 
                                                                                   and IsNull(exclude_from_creditcheck, 'N') = 'N')), 0) 
 where IsNull(cmp_billto, 'N') = 'Y'*/

--KPM - PTS #13894 ADD ORDERS COMPLETED BUT NOT YET INVOICED TO THE UPDATING OF THE AVAILABLE CREDIT FIELDS.
update company 
   set cmp_creditavail = cmp_creditavail - IsNull((Select sum(ord_totalcharge) 
                                                     from orderheader WITH (NOLOCK) 
                                                    where ord_billto = cmp_id 
                                                      and ord_invoicestatus in ('AVL','PND') 
                                                      and ord_hdrnumber > 0 
                                                      and ord_status in (select abbr 
                                                                           from labelfile 
                                                                          where labeldefinition = 'DispStatus' 
                                                                            and Isnull(exclude_from_creditcheck,'N') = 'N')), 0)
 where IsNull(cmp_billto, 'N') = 'Y'



GO
GRANT EXECUTE ON  [dbo].[calc_credit_available_sp] TO [public]
GO
