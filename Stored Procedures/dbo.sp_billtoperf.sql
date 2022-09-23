SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[sp_billtoperf] (@billto varchar(20), @semana varchar(20), @modo varchar(5) )

as

--exec  sp_billtoperf 'PILGRIMS',0,'MWEEK'


IF (@modo  ='DATA')

begin

	SELECT
	(select cty_name from city where cty_code = ord_origincity) as origen,
	(select cty_name from city where cty_code =ord_destcity) as destino,
	replace(ord_carrier,'UNKNOWN','TDR') as carrier, 
	ord_refnum as ruta,
	'' as bitacora,
	'Bitacora:' + isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'LPID' and ref.ref_tablekey = O.ord_hdrnumber),ord_refnum) 
	+' Ruta:' + isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = O.ord_hdrnumber),'Fuera SDS') 
	+' Orden:' + cast( ord_hdrnumber as varchar(20)) as orden,
	ord_Hdrnumber ord,
	isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = O.ord_hdrnumber),'Fuera SDS')  as FueraSDS,
	format(ord_completiondate,'dd-MM-yyyy') as fecha,
	datepart(week,ord_completiondate) as semana,
	ord_totalmiles as kms,
	(select sum(isnull(stp_ord_toll_cost,0)) from stops where stops.ord_hdrnumber  = o.ord_hdrnumber) as Casetas,
    (select isnull(max(CargaTon),0) + isnull(max(CargaTon2),0) from Sl_Pilgrims_Rutas s where s.ruta =
	 isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = O.ord_hdrnumber),' ') ) as toneladas , 
    (select isnull(max(Cajas),0) + isnull(max(Cajas2),0) from Sl_Pilgrims_Rutas s where s.ruta = 
	isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = O.ord_hdrnumber),' ') ) as Cajas , 
	case when ord_totalmiles = 0 then 0 else round((   (select isnull(max(CargaTon),0) + isnull(max(CargaTon2),0) from Sl_Pilgrims_Rutas s where s.ruta =
	 isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = O.ord_hdrnumber),' ') ) / ord_totalmiles),2) end as kgsxkm,
	replace((select case when min(lgh_type1) = 'FUL' then 'FULL' else min(lgh_type1) end from legheader   l where l.ord_hdrnumber = o.ord_hdrnumber),'UNK','SEN') as tipo,
	(select count(*) from notes where nre_tablekey  = o.ord_hdrnumber  and ntb_table = 'orderheader')  as notas
	 from orderheader o  where ord_billto = @billto
	and  ( cast(YEAR(ord_Completiondate) as varchar(5)) + '-' + cast(DATEPART(WEEK,ORD_COMPLETIONDATE) as varchar(5))) = @semana
	and ord_status = 'CMP'
	order by fecha desc

end

IF (@modo = 'TYPE')
begin


declare @sencillo int, @full int, @todo int


    SELECT
	@todo = count(*) 
	 from orderheader o  where ord_billto = @billto
	and ord_status = 'CMP'
	and  ( cast(YEAR(ord_Completiondate) as varchar(5)) + '-' + cast(DATEPART(WEEK,ORD_COMPLETIONDATE) as varchar(5))) = @semana

	SELECT
	@sencillo = count(*)  
	 from orderheader o  where ord_billto = @billto
	 and 	replace((select min(lgh_type1) from legheader   l where l.ord_hdrnumber = o.ord_hdrnumber),'UNK','SEN')  = 'SEN'
	and ord_status = 'CMP'
	and  ( cast(YEAR(ord_Completiondate) as varchar(5)) + '-' + cast(DATEPART(WEEK,ORD_COMPLETIONDATE) as varchar(5)))= @semana


	SELECT
	@full = count(*) 
	 from orderheader o  where ord_billto = @billto
	 and 	replace((select min(lgh_type1) from legheader   l where l.ord_hdrnumber = o.ord_hdrnumber),'UNK','SEN')  in ( 'FULL','FUL')
	and ord_status = 'CMP'
	and  ( cast(YEAR(ord_Completiondate) as varchar(5)) + '-' + cast(DATEPART(WEEK,ORD_COMPLETIONDATE) as varchar(5))) = @semana


	select @sencillo as SENCILLO, @full AS FUL, @todo AS TODO 



end



IF (@modo = 'WEEK')
begin


    SELECT
	distinct ( cast(YEAR(ord_Completiondate) as varchar(5)) + '-' + cast(DATEPART(WEEK,ORD_COMPLETIONDATE) as varchar(5)))AS SEMANA
	 from orderheader o  where ord_billto = @billto
	and ord_status = 'CMP'
	ORDER BY SEMANA DESC


end

IF (@modo = 'MWEEK')
begin


    SELECT
	MAX( cast(YEAR(ord_Completiondate) as varchar(5)) + '-' + cast(DATEPART(WEEK,ORD_COMPLETIONDATE) as varchar(5))) AS SEMANA
	 from orderheader o  where ord_billto = @billto
	and ord_status = 'CMP'



end






GO
