SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[EntreFechasAñoMesDia] (
@CadenaInicio AS DATETIME,
@CadenaFin AS DATETIME
                                    )
RETURNS NVARCHAR (100)
AS
BEGIN
        DECLARE @AñoInicio INT
        DECLARE @MesInicio INT
        DECLARE @DiaInicio INT
        DECLARE @AñoFin INT
        DECLARE @MesFin INT
        DECLARE @DiaFin INT
        DECLARE @Años INT
        DECLARE @Meses INT
        DECLARE @Dias INT
        DECLARE @FechaInicio DATETIME
        DECLARE @FechaFin DATETIME
        DECLARE @Texto NVARCHAR(100)
 
        --Para comprobar las fechas
        --IF isdate(@CadenaInicio)=0 return('La fecha de Inicio no es correcta')
        --IF isdate(@CadenaFin)=0 return ('La fecha de Fin no es correcta')
        IF DATEDIFF(dd, @CadenaInicio, @CadenaFin) = 0 RETURN('La fecha de Inicio es igual que la de Fin')
        --Asigna las cadenas a las fechas, inviertiéndolas si es necesario y cambiando el mensaje de salida.-
 
        IF DATEDIFF(dd, @CadenaInicio, @CadenaFin) > 0
 
        BEGIN
                SET @FechaInicio = @CadenaInicio
                SET @FechaFin = @CadenaFin
               
        END
        ELSE
        BEGIN
                SET @FechaInicio = @CadenaFin
                SET @FechaFin = @CadenaInicio
                
        END
 
        --Asigna los valores individuales de día, mes y año, para hacer los cálculos.-
        SET @DiaInicio = DAY(@FechaInicio)
       
 
        SET @DiaFin = DAY(@FechaFin)
       
 
 
        --Comprueba si el día es menor o igual al de fin.-
        IF @DiaFin - @DiaInicio >= 0
        BEGIN
                SET @Dias = @DiaFin - @DiaInicio
        END
        --Si no, calcula la suma en días, desde el día de Inicio a fin de mes, mas los días de Fin, y le resta uno al mes de Fin.-
        ELSE
        BEGIN
                SET @Dias = (@DiaFin - @DiaInicio)+30
                SET @MesFin = @MesFin - 1
        END
        --Lo mismo con el mes.-
        IF @MesFin - @MesInicio >= 0
        BEGIN
                SET @Meses = @MesFin - @MesInicio
        END
        ELSE
        BEGIN
                SET @Meses = (@MesFin - @MesInicio) + 12
                SET @AñoFin = @AñoFin - 1
        END


	return @Dias
        
END
GO
