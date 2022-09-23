SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[vista_mantenimientos]
as


select id_unidad,fecha_servicio_ultimo, dbo.fnc_tmwrn_formatnumbers(kms_servicio_ultimo,0) as UltimoServicioKm,
dateadd(yy,datediff(yy,fecha_servicio_sig,getdate()),fecha_servicio_sig) as fecha_servicio_sig, 
 dbo.fnc_tmwrn_formatnumbers(kms_servicio_sig,0) as SigServicioKM  from tdrsilt..mtto_unidades
GO
