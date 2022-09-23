SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para obtener el precio mensual de la tabla FUEL..price_gral_hist
-- sera la tabla numero 6

-- exec Sp_obtiene_precio_Fuel_JR


CREATE PROCEDURE [dbo].[Sp_obtiene_precio_Fuel_JR] 
AS
SET NOCOUNT ON

Declare @ld_fechaActual date,
@ld_fecha_Sig_Mes date,
@ld_fecha_fin_Mes date,
@l_mes integer,
@l_año integer,
@s_mes varchar(2),
@s_año varchar(4),
@lf_precio float,
@l_precio_existe integer,
@ls_descripcion varchar(30),
@li_existe_dato integer


-- Obtiene la fecha del dia de hoy.

select @ld_fechaActual  = getdate()
---- pruebas
--select @ld_fechaActual  = DATEADD(month,-4,getdate())
-- Obtengo el Mes y el año
select @l_mes = DatePart(month, @ld_fechaActual)
select @l_año = DatePart(year, @ld_fechaActual)

--select @l_mes = DatePart(month, getdate())
--select @l_año = DatePart(year, getdate())

-- se considera el mes 12
--IF @l_mes = 12 
--	begin
--		select @l_mes = 1
--		select @l_año = @l_año + 1
--	end 
--	else
--	select @l_mes = @l_mes

select @s_mes	= cast(@l_mes as varchar(2))
select @s_año	= cast(@l_año as varchar(4))


-- formamos la fecha del mes siguiente
select @ld_fecha_Sig_Mes = Convert(datetime, ('01'+'/'+@s_mes +'/'+@s_año),103)


---- Le restamos un dia a la fecha del mes siguiente
--select @ld_fecha_fin_Mes = DATEADD(dd,-1,@ld_fecha_Sig_Mes)

select @l_precio_existe = count(price_avg) from FUEL..price_gral_hist where date = @ld_fecha_Sig_Mes

IF @l_precio_existe > 0 
begin
	select @lf_precio = price_avg from FUEL..price_gral_hist where date = @ld_fecha_Sig_Mes
	
	-- sacamos el nombre de la tabla
		SELECT	@ls_descripcion = max(averagefuelprice.afp_description) 		FROM averagefuelprice 		WHERE ( averagefuelprice.afp_tableid = '6' )

		-- pregunta si ya esta dado de alta el dato en la tabla
		
				SELECT	@li_existe_dato = count(averagefuelprice.afp_tableid)				FROM averagefuelprice 				WHERE averagefuelprice.afp_tableid = '6' and averagefuelprice.afp_date = @ld_fecha_Sig_Mes

				IF @li_existe_dato = 0
				begin
					Insert averagefuelprice(afp_tableid, afp_description,  afp_date, afp_price)
					Values (6, @ls_descripcion, @ld_fecha_Sig_Mes, @lf_precio )
				end
	end -- de cuando aun no esta el precio 








GO
