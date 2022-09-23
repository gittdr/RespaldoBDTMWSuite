SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGuardarSucursal277]
@motivo varchar(10),
@uuid varchar(max),
@status varchar(100),
@descripcion varchar(max)
as 
begin
insert into canceladascpi(motivo,uuid,status,descripcion)
values(@motivo,@uuid,@status,@descripcion)

end
GO
