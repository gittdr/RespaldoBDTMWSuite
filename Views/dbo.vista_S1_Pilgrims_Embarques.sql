SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [dbo].[vista_S1_Pilgrims_Embarques]

as

select 
Embarque_Id, Ruta, Origen, Destino, TipoUnidad, Proveedor, PlantaPago, Fecha, Comentarios, Remolque, TipoViaje,  UnidadPiezas, CantidadPiezas, Tractor, Remolques, RutaNombre, Distribuidor, IdOrigen, IdDestino, Dolly, Sellos, Operador, Sellos2, ValePlastico, FlejePlastico, ValePlastico2, FlejePlastico2,
 STUFF((SELECT '  |  ' + ped.[Entrega]
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '1'
          FOR XML PATH('')), 1, 1, '') [Clientes],

 STUFF((SELECT '  |  ' + ped.[Factura]
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '1'
          FOR XML PATH('')), 1, 1, '') [Facturas],

 STUFF((SELECT '  |  ' + cast(SUM(cast( det.[Cantidad] as decimal)) as varchar)
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
		  inner join [dbo].[Sl_Pilgrims_Detalle] det
		  on ped.[Pedido_Id] = det.[Pedido_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '1'
		  group by ped.[Entrega], ped.[Client_Id]
		  FOR XML PATH('')), 1, 1, '') [Cajas],

STUFF((SELECT '  |  ' + cast(SUM(cast( det.[Peso] as decimal)) as varchar)
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
		  inner join [dbo].[Sl_Pilgrims_Detalle] det
		  on ped.[Pedido_Id] = det.[Pedido_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '1'
		  group by ped.[Entrega], ped.[Client_Id]
		  FOR XML PATH('')), 1, 1, '') [Peso],

STUFF((SELECT '  |  ' + c.ClienteDescripcion
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
		  inner join [dbo].[Sl_Pilgrims_Detalle] det
		  on ped.[Pedido_Id] = det.[Pedido_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '1'
		  FOR XML PATH('')), 1, 1, '') [ClienteDescripcion],

--2

 STUFF((SELECT '  |  ' + ped.[Entrega]
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
          WHERE c.Embarque_Id = e.Embarque_Id and ped.Caja = '2' 
          FOR XML PATH('')), 1, 1, '') [Clientes2],

 STUFF((SELECT '  |  ' + ped.[Factura]
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
          WHERE c.Embarque_Id = e.Embarque_Id and ped.Caja = '2'
          FOR XML PATH('')), 1, 1, '') [Facturas2],

 STUFF((SELECT '  |  ' + cast(SUM(cast( det.[Cantidad] as decimal)) as varchar)
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
		  inner join [dbo].[Sl_Pilgrims_Detalle] det
		  on ped.[Pedido_Id] = det.[Pedido_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '2'
		  group by ped.[Entrega], ped.[Client_Id]
		  FOR XML PATH('')), 1, 1, '') [Cajas2],

STUFF((SELECT '  |  ' + cast(SUM(cast( det.[Peso] as decimal)) as varchar)
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
		  inner join [dbo].[Sl_Pilgrims_Detalle] det
		  on ped.[Pedido_Id] = det.[Pedido_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '2'
		  group by ped.[Entrega], ped.[Client_Id]
		  FOR XML PATH('')), 1, 1, '') [Peso2],

STUFF((SELECT '  |  ' + c.ClienteDescripcion
          FROM [Sl_Pilgrims_Cliente] C
		  inner join [dbo].[Sl_Pilgrims_Pedido] ped
		  on ped.[Client_Id] = c.[Client_Id]
		  inner join [dbo].[Sl_Pilgrims_Detalle] det
		  on ped.[Pedido_Id] = det.[Pedido_Id]
          WHERE c.Embarque_Id = e.Embarque_Id  and ped.Caja = '2'
		  FOR XML PATH('')), 1, 1, '') [ClienteDescripcion2]

from [dbo].[Sl_Pilgrims_Embarque]  e









GO
