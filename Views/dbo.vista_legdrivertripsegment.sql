SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vista_legdrivertripsegment]
as

select
[Driver1 ID] as Resource,
[Driver1 Name] as DriverName,
[Total Miles] as TravelMiles,
[Loaded Miles] as LoadedMiles,
[Empty Miles] as EmptyMiles,
[Segment Start Date Only] as lgh_startdate,
[Segment End Date Only] as lgh_endate,
day([Order Delivery Date]) as dia,
[Delivery Year] as anio,
DATENAME(month, [Delivery Date Only]) as mes,
DATEPART(ww,[Delivery Date Only]) as semana,
[DrvType1] as equip,
[DrvType2] as drvtype,
TrcType3  as proj,
RevType4 as div,
[Tractor ID] as mpp_tractornumber,
'Orden:'+cast([Order Header Number] as varchar) +'|Cliente:'+[Bill To] + '|Operador:'+ [Driver1 Name]+'Lider:'+ cast([Team Leader ID] as varchar)  as drvtr,
[DrvType3] as mpp_status, --comprobar
[LineHaul Revenue] as lgh_linehaul,
Revenue as lgh_ord_chg_org,
[Total Miles] as lgh_miles,
Revenue as  RevTot,
[Order Header Number] as ord_hdrnumber,
[RevType2] as ord_revtype2,
[LineHaul Revenue]  as ord_rate,
[Order Currency] as ord_currency,
Revenue as LGH_ord_charge,
[Team Leader ID] as mpp_teamleader,
[Segment Status] as ord_status,
[Tractor ID] as ord_tractor,
Fleet as trc_fleet,
case isnull(Fleet,'0')
when '0' then 'UNKNOWN'
when 'UKN' then 'UNKNOWN'
when '1' then 'ABIERTO 1'
when '2' then 'Eucomex'
when '3' then 'ASOCIADOS'
when '4' then 'Home Depot'
when '5' then 'Full Sureste'
when '6' then 'WM MX'
when '7' then 'Kraf Dedicado'
when '8' then 'ABIERTO 2'
when '9' then 'ABIERTO 3'
when '10' then 'SWAT'
when '11' then 'JUMEX'
when '12' then 'Sayer'
when '13' then 'Sureste Sencillo'
when '14' then 'Tolvas'
when '15' then 'WM VH'
when '16' then 'Liverpool'
when '17' then 'Ventas'
when '18' then 'Lad Monterrey'
when '19' then 'WM MTY'
when '20' then 'DHLX'
when '21' then 'Quintas Mty'
END 


as name,
[Bill To] as ord_billto,
RevenuePerLoadedMile as costokm


from vista_revvspayventas
where 
 [Segment Status] in ('CMP','STD')


GO
