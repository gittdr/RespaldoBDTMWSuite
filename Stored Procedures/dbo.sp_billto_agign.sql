SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_billto_agign]
as
delete tts_billto_aging

insert into tts_billto_aging

select * from
(
select 


cmp_id as billto,
(select max(ord_startdate) from orderheader where ord_billto = cmp_id and ord_status = 'CMP')  as ultorden,
case when datediff(DAY,(select max(ord_startdate) from orderheader where ord_billto = cmp_id and ord_status = 'CMP'),getdate()) <= 30 then '30 dias.'
      when datediff(MONTH,(select max(ord_startdate) from orderheader where ord_billto = cmp_id and ord_status = 'CMP'),getdate()) between 1 and 3 then '3 meses.'
     when datediff(MONTH,(select max(ord_startdate) from orderheader where ord_billto = cmp_id and ord_status = 'CMP'),getdate()) between 4 and 6 then '3 a 6 meses.'
	 when datediff(month,(select max(ord_startdate) from orderheader where ord_billto = cmp_id and ord_status = 'CMP'),getdate()) >=7 then '1 año.'
	 when (select max(ord_startdate) from orderheader where ord_billto = cmp_id and ord_status = 'CMP') is null then '1 año.'
 else '' end as periodo

from company
where cmp_billto = 'Y' and cmp_active = 'Y') as billto
GO
