SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_obtener_xml_integracion] (@dato varchar(1000),@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
			-- aqui se leen los archivos
		SELECT [id_num], [usuario], [narchivo], [fecha], [Estatus] 
		FROM RCSAYER where Estatus is null and cast(fecha as Date) = @dato AND [usuario] = 'SAYER'
END
IF(@accion = 2)
BEGIN
		--aqui va el update para los archivos
		update RCSAYER 
		set Estatus = 'Cargado'
		where [narchivo] = @dato
		
END
END


--exec sp_obtener_xml_integracion '2022/03/14',1 
GO
