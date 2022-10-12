SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--exec [dbo].[sp_sl_Pilgrims_CatalogoClientes] 2, 182219
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_CatalogoClientes] (@accion int, @ruta varchar(100) )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
Select ccc.compania_tmw as origenTMW,
		 r.idrutas, cast(cast(r.ruta as int) as varchar) as ruta, r.origen,r.destino,
		 em.Fecha,
		 cc.Origen,cc.Destino,cc.compania_tmw, cc.Nombre_TMW,cc.Ciudad_TMW, cc.DistanciaIdaVuelta,cc.TiempoHrs, cc.SalidaDePlanta, cc.LLegadaADestino,cc.TiempoDeRecorrido,
		--mt.mt_origin,mt.mt_destination,mt.mt_miles,mt.mt_hours,
		r.[Cajas], Cast(r.[CargaTon] as decimal(20,2)) + cast (isnull(r.[CargaTon2],0) as decimal(20,2)) as [CargaTon], r.[clientes],
		isnull((select top 1 mpp_id from manpowerprofile where mpp_firstname +' '+ mpp_lastname = r.Operador),
		isnull((select  top 1 mpp_id from manpowerprofile where r.Operador like '%'+' ' +mpp_lastname and mpp_status = 'USE'),
		(Select top 1 idoperador from Sl_pilgrims_Operadores where alias = r.Operador)
		)) as Operador,
		isnull((select top 1 trl_id FROM trailerprofile where trl_number =  r.Remolque1),(select top 1 trl_id FROM trailerprofile where trl_licnum =  r.Remolque1)) as Remolque1,
		r.Remolque2,r.Dolly,em.tipoViaje as Distancia,em.Fecha as FechaEntregaMax,
		isnull((select top 1 mpp_tractornumber from manpowerprofile where mpp_firstname +' '+ mpp_lastname = r.Operador),
		isnull((select  top 1 mpp_tractornumber from manpowerprofile where r.Operador like '%'+' ' +mpp_lastname and mpp_status = 'USE'),
		(select top 1 mpp_tractornumber from manpowerprofile where mpp_id = (Select idoperador from Sl_pilgrims_Operadores where alias = r.Operador))
		))as Tractor
		-- 'PLGTEPE' + '-'+ Cast(r.idBitacora as Varchar) AS idBitacora,

from [dbo].[sl_Pilgrims_Rutas] r 
				inner join [dbo].[Sl_Pilgrims_Embarque] em on r.ruta = em.ruta 
				--inner join [dbo].[Sl_Pilgrims_Cliente] cl on cl.Embarque_Id = em.Embarque_Id
				INNER JOIN [dbo].[SL_PilgrimsTMW_CatalogoClientes] cc ON  r.destino= cc.Origen
				INNER JOIN [dbo].[SL_PilgrimsTMW_CatalogoClientes] ccc ON  r.origen= ccc.Origen
				--inner join [dbo].[mileagetable] mt on  cc.Compania_TMW = mt.mt_origin or cc.Compania_TMW = mt.mt_destination

		where --(mt.mt_destination = 'PLGTEPE' or mt.mt_origin = 'PLGTEPE')
				--and  
				--cc.DistanciaIdaVuelta is not null
				--r.ruta not in (Select oh.ref_number 
				--						from [dbo].[referencenumber] oh where oh.ref_type = 'BL#' and oh.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto='sayer' and ord_refnum <> '' ))
				--and 
				cast(cast(r.ruta as int) as varchar) not in (Select oh.ord_refnum from orderheader oh where oh.ord_billto  in (select distinct ord_billto from orderheader where ord_billto like '%SAY%' or ord_billto = 'PISA' or ord_billto = 'WALMART') and oh.ord_refnum <> '')
				--and r.Operador <> ''
				--and (select count(*) from expiration where exp_id in (select trc_number from tractorprofile where trc_driver = r.Operador) and exp_completed <> 'Y') < 1

	

END  
IF(@accion = 2)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
		Select DISTINCT ccc.compania_tmw  as origenTMW,
		 r.idrutas, r.ruta, r.origen,r.destino,
		 em.Fecha,
		 cc.Origen,cc.Destino,cc.compania_tmw, cc.Nombre_TMW,cc.Ciudad_TMW, cc.DistanciaIdaVuelta,cc.TiempoHrs, cc.SalidaDePlanta, cc.LLegadaADestino,cc.TiempoDeRecorrido,
		--mt.mt_origin,mt.mt_destination,mt.mt_miles,mt.mt_hours,
		--r.[Cajas], Cast(r.[CargaTon] as decimal(20,2)) + cast (isnull(r.[CargaTon2],0) as decimal(20,2)) as [CargaTon],
		r.[clientes],
		cl.IdClient,cccc.compania_tmw as CompaniaStop,cl.ClienteDescripcion,cl.FechaEntregaMin,cl.FechaEntregaMax,cl.Distancia,ped.Caja,ped.Secuencia,ped.LugarEntrega,ped.Destino,
		isnull((select top 1 mpp_id from manpowerprofile where mpp_firstname +' '+ mpp_lastname = r.Operador),
		isnull((select  top 1 mpp_id from manpowerprofile where r.Operador like '%'+' ' +mpp_lastname and mpp_status = 'USE'),
		(Select top 1 idoperador from Sl_pilgrims_Operadores where alias = r.Operador)
		)) as Operador,
		isnull((select top 1 trl_id FROM trailerprofile where trl_number =  r.Remolque1),(select top 1 trl_id FROM trailerprofile where trl_licnum =  r.Remolque1)) as Remolque1,
		r.Remolque2,r.Dolly,
		isnull((select top 1 mpp_tractornumber from manpowerprofile where mpp_firstname +' '+ mpp_lastname = r.Operador),
		isnull((select  top 1 mpp_tractornumber from manpowerprofile where r.Operador like '%'+' ' +mpp_lastname and mpp_status = 'USE'),
		(select top 1 mpp_tractornumber from manpowerprofile where mpp_id = (Select idoperador from Sl_pilgrims_Operadores where alias = r.Operador))
		))as Tractor,
		(select SUM(cast(PD.Peso as Decimal)) as Peso from [dbo].[Sl_Pilgrims_Embarque] PE
			inner join [dbo].[Sl_Pilgrims_Cliente] PC on PC.Embarque_Id = PE.Embarque_Id
			inner join [dbo].[Sl_Pilgrims_Pedido] PP on PP.Client_Id = PC.Client_Id
			inner join [dbo].[Sl_Pilgrims_Detalle] PD on PD.Pedido_Id = PP.Pedido_Id
			where PD.Pedido_Id= ped.Pedido_Id
			group by PD.Pedido_Id) as CargaTon,
		r.CargaTon2,
		(select SUM(cast(PD.Cantidad as decimal)) as Cantidad from [dbo].[Sl_Pilgrims_Embarque] PE
			inner join [dbo].[Sl_Pilgrims_Cliente] PC on PC.Embarque_Id = PE.Embarque_Id
			inner join [dbo].[Sl_Pilgrims_Pedido] PP on PP.Client_Id = PC.Client_Id
			inner join [dbo].[Sl_Pilgrims_Detalle] PD on PD.Pedido_Id = PP.Pedido_Id
			where PD.Pedido_Id= ped.Pedido_Id
			group by PD.Pedido_Id) Cajas,
		r.Cajas2,r.Dolly,r.FlejePlastico,r.FlejePlastico2,r.ValePlastico,r.ValePlastico2,CL.Client_Id
		--select *
		from [dbo].[sl_Pilgrims_Rutas] r 
				inner join [dbo].[Sl_Pilgrims_Embarque] em on r.ruta = em.ruta 
				inner join [dbo].[Sl_Pilgrims_Cliente] cl on cl.Embarque_Id = em.Embarque_Id
				Left outer join [dbo].[Sl_Pilgrims_Pedido] ped on ped.Client_Id = cl.Client_Id
				inner join [dbo].[SL_PilgrimsTMW_CatalogoClientes] cc ON em.destino = cc.Origen
				INNER JOIN [dbo].[SL_PilgrimsTMW_CatalogoClientes] ccc ON  r.origen= ccc.Origen
				left outer JOIN [dbo].[SL_PilgrimsTMW_CatalogoClientes] cccc ON  cl.IdClient= cccc.Origen
				--inner join [dbo].[mileagetable] mt on  cc.Compania_TMW = mt.mt_origin or cc.Compania_TMW = mt.mt_destination

		where --(mt.mt_destination = 'PLGTEPE' or mt.mt_origin = 'PLGTEPE')
		r.ruta like '%'+ @ruta and
				--and  cc.DistanciaIdaVuelta is not null
				--and  r.ruta not in (Select oh.ref_number 
				--						from [dbo].[referencenumber] oh where oh.ref_type = 'SID' and oh.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto='pilgrims' and ord_refnum <> '' ) )
				
				cast(cast(r.ruta as int) as varchar) not in (Select oh.ord_refnum from orderheader oh where oh.ord_billto  in (select distinct ord_billto from orderheader where ord_billto like '%SAY%' or ord_billto = 'PISA' or ord_billto = 'WALMART') and oh.ord_refnum <> '')
				--and em.Operador <> ''
				--and (select count(*) from expiration where exp_id in (select trc_number from tractorprofile where trc_driver = em.Operador) and exp_completed <> 'Y') < 1
		ORDER BY cl.Client_Id ASC


END

END
GO
