SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor : Emilio Olvera
Fecha : 30 Agosto 2021

setencia prueba


exec sp_RptOperaciones 'Semana','sucursal'
exec sp_RptOperaciones 'Semana','fechas'


exec sp_RptOperaciones 'Custom','sucursal'
exec sp_RptOperaciones 'Custom','fechas'

*/

CREATE proc [dbo].[sp_RptOperaciones] @periodo varchar(10), @modo varchar(10)

as

declare @fini datetime
declare @ffin datetime



IF @periodo = 'DIARIO'
begin
  select @fini =   CAST(CAST(DATEADD(day,-1,getdate()) AS DATE) AS DATETIME)   
  select @ffin =   dateadd(SECOND,-1,CAST(CAST(DATEADD(day, 0,getdate()) AS DATE) AS DATETIME))  

  print 'Fecha Inicial: ' + cast( @fini as varchar(120))
  print 'Fecha Final:   ' + cast(@ffin as varchar(120))

end



IF @periodo = 'SEMANA'
begin



   -- 1 domingo, --sabado 7 -- viernes 6 -- jueves 5 -- miercoles 4 - martes 3 -- lunes 2
   DECLARE @numdiahoy int =  DATEPART(WEEKDAY,GETDATE())

   DECLARE @SabadoMasReciente DATETIME =  dateadd(day,-1*@numdiahoy,getdate())

   DECLARE @Domingoinicio  DATETIME = dateadd(day,-6,@SabadoMasReciente)
  
   print @SabadoMasReciente
   print @DomingoInicio

  select @fini =   CAST(CAST(DATEADD(day,0,@Domingoinicio) AS DATE) AS DATETIME) 
  select @ffin =   dateadd(SECOND,86399,CAST(CAST(DATEADD(day, 0,@SabadoMasReciente) AS DATE) AS DATETIME))  

  print 'Sabado mas Reciente: ' + cast(@SabadoMasReciente  as varchar(120))
  print 'Fecha Inicial: ' + cast(@fini  as varchar(120))
  print 'Fecha Final:   ' + cast(@ffin as varchar(120))

end

If @periodo  ='CUSTOM'
begin
  select @ffin =   CAST(CAST(DATEADD(day,0,'2021-09-04') AS DATE) AS DATETIME)  
  select @fini =    dateadd(SECOND,0,CAST(CAST(DATEADD(day, 0,'2021-08-29') AS DATE) AS DATETIME))   


    print 'Fecha Inicial: ' + cast( @fini as varchar(120))
  print 'Fecha Final:   ' + cast(@ffin as varchar(120))


end

declare @ordenes table (Sucursal varchar(40), Proyecto varchar(50), Proy varchar(10), Venta float, KmsTotales int, KmsVacios int, Estancias int, Orden varchar(20))


insert into @ordenes

select 
  (select name from labelfile where labeldefinition = 'RevType2' and abbr = ord_revtype2) as Sucursal,
  (select name from labelfile where labeldefinition = 'RevType3' and abbr = ord_revtype3) as Proyecto,
  ord_revtype3,
  (ord_totalcharge) as Ventas, 
  (select isnull(SUM(isnull(stp_lgh_mileage,0)),0) from stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber  ) as Kmstotales,
  (select isnull(SUM(isnull(stp_lgh_mileage,0)),0) from stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber  and  stp_loadstatus = 'MT') as  KmsVacios,
  (select COUNT(*) from paydetail where paydetail.ord_hdrnumber = orderheader.ord_Hdrnumber and pyt_itemcode in ('COBEST','COMEST','ECC','EM')) as Estancias,

  (ord_hdrnumber) as Orden

from orderheader 
where ord_status = 'CMP'
and  ord_completiondate between @fini and @ffin

----------------------------------------------

if (@modo = 'FECHAS')
begin
  select @fini as fechainicial, @ffin as fechafinal
end

if (@modo = 'SUCURSAL')

begin

select * from (

select Sucursal,
       format(round(SUM(venta),0),'C0') as Venta,
	   format(sum(Kmstotales),'#,#') as Kms,
       format(cast(SUM(venta) as float) / cast(sum(Kmstotales) as float),'C2') as IngresoXKM,
       format(cast(sum(KmsVacios) as float) /  cast(sum(Kmstotales) as float),'P0') as PctVacios, 
       COUNT(orden) as Ordenes, 
       SUM(Estancias) as Estancias
 from @ordenes
where Proyecto = 'BAJIO'
group by Sucursal ) as q 
order by  cast(replace(replace(Venta,'$',''),',','') as float)  desc

end


if (@modo = 'PROYECTO')
begin


select * from (

select Proyecto,  
      format(round(SUM(venta),0) ,'C0')  as Venta,
      format(sum(Kmstotales),'#,#') as Kms,
      format( case when sum(Kmstotales) = 0 then 0 else cast(SUM(venta) as float) / cast(sum(Kmstotales) as float) end,'C2') as IngresoXKM,
      format( case when sum(Kmstotales) = 0 then 0 else cast(sum(KmsVacios) as float) /  cast(sum(Kmstotales) as float) end,'P0') as PctVacios,   
      COUNT(orden) as Ordenes, SUM(Estancias) as Estancias,

      format(case when (SELECT count(*)  FROM vista_tractorscompany  where ProyTrc = REPLACE(REPLACE(REPLACE( Proy, 'PEÑ','PETEC'),'DHLM','BMWF'),'LIVFUL','FULO')) = 0 then 0 else 
      cast((SELECT count(*) FROM vista_tractorscompany  where ProyTrc = REPLACE(REPLACE(REPLACE( Proy, 'PEÑ','PETEC'),'DHLM','BMWF'),'LIVFUL','FULO') and Asignacion = 'Seated') as float) /
      cast((SELECT count(*)       FROM vista_tractorscompany  where ProyTrc = REPLACE(REPLACE(REPLACE( Proy, 'PEÑ','PETEC'),'DHLM','BMWF'),'LIVFUL','FULO')) as float) end,'P0')   as PctTrcAvl
 from @ordenes
where Proyecto not in  ('BROKERAGE')
group by Proyecto, Proy) as q 
order by cast(replace(replace(Venta,'$',''),',','') as float)  desc


end
GO
