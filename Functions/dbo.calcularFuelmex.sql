SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manuel Guillen
-- Create date: 11-09-2014
-- Description:	Obtener el Fuelmex para Eucomex dada la fecha inicial del precio, el monto, el factor de incremento y la fecha que en la que se quiere obtener el precio
-- =============================================
CREATE FUNCTION [dbo].[calcularFuelmex] 
(
	-- Add the parameters for the function here
	@CadenaInicio AS DATETIME,
	@Monto AS FLOAT,
	@Factor AS FLOAT,
	@CadenaFin AS DATETIME
)
RETURNS FLOAT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Fuelmex FLOAT

	DECLARE @FechaInicio DATETIME
	DECLARE @FechaFin DATETIME

	--Verifica que el monto y el factor no sean nulos o menores de cero. Si es el caso, se regresa un valor nulo

		IF @Monto = NULL OR @Factor = NULL OR @Monto < 0 OR @Factor < 0
			RETURN @Fuelmex

    --Asigna las cadenas a las fechas, inviertiéndolas si es necesario y cambiando el mensaje de salida.-
 
        IF DATEDIFF(month, @CadenaInicio, @CadenaFin) > 0
 
        BEGIN
                SET @FechaInicio = @CadenaInicio
                SET @FechaFin = @CadenaFin
               
        END
        ELSE
        BEGIN
                SET @FechaInicio = @CadenaFin
                SET @FechaFin = @CadenaInicio
                
        END

		SET @Fuelmex = @Monto + (SELECT DATEDIFF(month, @FechaInicio, @FechaFin) * @Factor)

	-- Return the result of the function
	RETURN @Fuelmex

END
GO
