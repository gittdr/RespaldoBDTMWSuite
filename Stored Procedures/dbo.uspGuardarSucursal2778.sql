SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGuardarSucursal2778]
@folio varchar(100),
@motivo varchar(10),
@uuid varchar(max),
@status varchar(100),
@descripcion varchar(max)
as 
begin
insert into canceladascartap(Folio,motivo,uuid,status,descripcion)
values(@Folio,@motivo,@uuid,@status,@descripcion)

end
GO
