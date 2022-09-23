SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Author,,Name> Linda
-- Create date: <Create Date,,> 26/11/19
-- Description:	<Description,,> Ingresa el historico de las unidades, especificando nel proyecto y driver día con día.

-- Exec [dbo].[sp_TractorProyHistory] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_TractorProyHistory] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
		INSERT INTO TractorProyHistory ([trc_number], [trc_driver], [trc_status], [fecha], [trc_type3], [proyecto],[equipo_colaborativo])
			SELECT trc_number,trc_driver,trc_status,CAST(GETDATE() AS date) AS Fecha,trc_fleet,(SELECT name FROM labelfile 
			WHERE labeldefinition = 'Fleet' AND abbr = trc_fleet ) AS Proyecto,
			trc_division
			FROM tractorprofile
			WHERE trc_status<>'OUT'
	END
END
GO
