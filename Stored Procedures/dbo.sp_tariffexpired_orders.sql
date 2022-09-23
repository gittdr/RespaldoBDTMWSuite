SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_tariffexpired_orders]
as

delete tariff_expired_report 

insert into tariff_expired_report

select ord_billto, ord_hdrnumber, ord_completiondate, ord_totalcharge, ord_shipper, ord_consignee,

(select cty_nmstct from city where cty_code =  ord_origincity) as ciudadorigen,
(select cty_nmstct from city where cty_code =  ord_destcity) as ciudaddestino,
ord_origincity,
ord_destcity,
ord_fromorder,
tar_number,
(select trc_number_row from tariffrate_expired tr where tr.tar_number = orderheader.tar_number and [row]= cast(ord_origincity as varchar(20)) and [column]  = cast(ord_destcity as varchar(20))) as [row],
(select trc_number_col from tariffrate_expired tr where tr.tar_number = orderheader.tar_number and [row]= cast(ord_origincity as varchar(20)) and [column]  = cast(ord_destcity as varchar(20))) as [column],
(select max(tra_retired) from tariffrate_expired tr where tr.tar_number = orderheader.tar_number and [row]= cast(ord_origincity as varchar(20)) and [column]  = cast(ord_destcity as varchar(20))) as vencio,
NULL,
NULL
from orderheader where year(ord_completiondate) > 2018 and tar_number in 
(select tar_number from tariffrate_expired where active = 'Yes')

order by tar_number  desc


update tariff_expired_report  set vencio =  (select max(tra_retired) from tariffrate_expired tr where tr.tar_number = tarifa and [row]= cast(ord_shipper as varchar(20)) and [column]  = cast(ord_consignee as varchar(20)))
where vencio is null
update tariff_expired_report set [row]   =  (select trc_number_row    from tariffrate_expired tr where tr.tar_number = tarifa and [row]= cast(ord_shipper as varchar(20)) and [column]  = cast(ord_consignee as varchar(20)))
where [row] is null
update tariff_expired_report set [column] = (select trc_number_col   from tariffrate_expired tr where tr.tar_number = tarifa and [row]= cast(ord_shipper as varchar(20)) and [column]  = cast(ord_consignee as varchar(20)))
where [column] is null


update tariff_expired_report  set vencio =  (select max(tra_retired)  from tariffrate_expired tr where tr.tar_number = tarifa and [row]= cast(copiade as varchar(20)) and [column]  = cast(ord_origincity as varchar(20)))
where vencio is null
update tariff_expired_report set [row]   =  (select trc_number_row     from tariffrate_expired tr where tr.tar_number = tarifa and [row]= cast(copiade as varchar(20)) and [column]  = cast(ord_origincity as varchar(20)))
where [row] is null
update tariff_expired_report set [column] = (select trc_number_col     from tariffrate_expired tr where tr.tar_number = tarifa and [row]= cast(copiade as varchar(20)) and [column]  = cast(ord_origincity as varchar(20)))
where [column] is null



update tariff_expired_report  set vencio =  (select max(tra_retired) from tariffrate_expired tr where tr.tar_number = tarifa and [column]= cast(ord_origincity as varchar(20)) and [row]  = cast(ord_destcity as varchar(20)))
where vencio is null
update tariff_expired_report set [row]   =  (select   trc_number_row from tariffrate_expired tr where tr.tar_number = tarifa and [column]= cast(ord_origincity as varchar(20)) and [row]  = cast(ord_destcity as varchar(20)))
where [row] is null
update tariff_expired_report set [column]=  (select   trc_number_col from tariffrate_expired tr where tr.tar_number = tarifa and [column]= cast(ord_origincity as varchar(20)) and [row]  = cast(ord_destcity as varchar(20)))
where [column] is null



update tariff_expired_report  set vencio =  (select max(tra_retired) from tariffrate_expired tr where tr.tar_number = tarifa and [column]= cast(ord_origincity as varchar(20)) and [row]  = cast(ord_consignee as varchar(20)))
where vencio is null
update tariff_expired_report set [row]    = (select trc_number_row   from tariffrate_expired tr where tr.tar_number = tarifa and [column]= cast(ord_origincity as varchar(20)) and [row]  = cast(ord_consignee as varchar(20)))
where [row] is null 
update tariff_expired_report set [column] = (select trc_number_col   from tariffrate_expired tr where tr.tar_number = tarifa and [column]= cast(ord_origincity as varchar(20)) and [row]  = cast(ord_consignee as varchar(20)))
where [column] is null



update tariff_expired_report  set vencio =  (select max(tra_retired) from tariffrate_expired tr where tr.tar_number = tarifa and [column] like  '%'+ cast(ord_shipper as varchar(20))+'%'  and [row]  = cast(ord_destcity as varchar(20)))
where vencio is null
update tariff_expired_report set [row]    = (select trc_number_row   from tariffrate_expired tr where tr.tar_number = tarifa and [column] like  '%'+ cast(ord_shipper as varchar(20))+'%'  and [row]  = cast(ord_destcity as varchar(20)))
where [row] is null
update tariff_expired_report set [column] = (select trc_number_col   from tariffrate_expired tr where tr.tar_number = tarifa and [column] like  '%'+ cast(ord_shipper as varchar(20))+'%'  and [row]  = cast(ord_destcity as varchar(20)))
where [column] is null



--------------------------Obtener historia de quien y cuando modifico la tarifa-----------------------------------------------------------------------------------------------------
update tariff_expired_report set updated_on  = (select last_updatedate from tariffrate tr where tr.tar_number = tarifa and trc_number_col = [column] and trc_number_row = [row])


update tariff_expired_report set updated_by  = (select last_updateby from tariffrate tr where tr.tar_number = tarifa and trc_number_col = [column] and trc_number_row = [row])



--------------------------Borrar registros de los cuales no se encontro fecha de vencimiento por que la ruta no ha vencido----------------------------------------------------------

delete tariff_expired_report  where vencio is null

delete tariff_expired_report  where cast(tarifa as varchar(20))+cast([row] as varchar(20)) + cast([column] as varchar(20)) in (select cast(tar_number as varchar(20))+cast(trc_number_row as varchar(20)) +cast(trc_number_col as varchar(20))  from tariffrate_expired where active = 'No' ) 

GO
