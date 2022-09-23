SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DROP PROCEDURE sp_cantidadenletras
--GO

CREATE PROCEDURE [dbo].[sp_cantidadenletras] @li_numeroorden int

as 
DECLARE @s_cantidadenletra varchar(250),
	@ls_part1 varchar(3),
	@ls_part2 varchar(3),
	@ls_part3 varchar(3),
	@ls_part4 varchar(3),
	@ls_part1_1 varchar(50),
	@ls_part2_1 varchar(50),
	@ls_part3_1 varchar(50),
	@ls_part4_1 varchar(50),
	@ls_decimales varchar(50),
	@ls_moneda varchar(50),
	@ls_monedanac varchar(10),
	@ls_leyenda varchar(250),
	@ls_cant_letra varchar(100),
	@ls_iva varchar(10),
	@ls_retencion varchar(10),
	@ld_flete MONEY,
	@ld_totaliva decimal(15,2),
	@ld_totalreten decimal(15,2),
	@li_iva decimal(15,2),
	@li_reten decimal(15,2),
	@ls_cantidad varchar(15),
	@ld_totalcantidad decimal(15,2)

-- limpia la tabla de paso
delete cantidad_letra;

-- Manda llamar los datos de la orden y de los impuestos
IF @li_numeroorden > 0 
	Begin
		SELECT @ld_flete  = (ord_charge +IsNull(ord_accessorial_chrg, 0)),   
		       @ls_moneda = ord_currency
		From  orderheader
		Where ord_hdrnumber = @li_numeroorden
	
		select  @ls_iva 	= gi_string1, 
			@ls_retencion 	= gi_string2 
		FROM generalinfo
		WHERE gi_name = 'PODFormat04Taxes'
	END

-- Si flete es mayor a 0

IF @ld_flete > 0 
	Begin
	  select @li_iva 	= convert(dec,@ls_iva)
	  select @li_reten	= convert(dec,@ls_retencion)
	
--INSERT INTO cantidad_letra (cant_letra)Values (@li_iva)


--INSERT INTO cantidad_letra (cant_letra)Values (@li_reten)


	  select @ld_totaliva	= (@ld_flete * @li_iva)/100

--INSERT INTO cantidad_letra (cant_letra)Values  (@ld_totaliva )

	  select @ld_totalreten	= (@ld_flete * @li_reten)/100

--INSERT INTO cantidad_letra (cant_letra)Values (@ld_totalreten)

	  select @ld_totalcantidad = @ld_flete + @ld_totaliva - @ld_totalreten
--INSERT INTO cantidad_letra (cant_letra)Values (@ld_totalcantidad)
	  
	  Select @ls_cantidad = cast(@ld_totalcantidad as varchar(15))
--INSERT INTO cantidad_letra (cant_letra)Values (@ls_cantidad)

	End

-- pasa el valor del flete a la variable cantidad
--Select 



select @ls_cantidad = RIGHT('000000000000000', 15 -  len( convert(char(15),@ls_cantidad))) + convert(Char(15),(@ls_cantidad))

-- Obtiene las cuatro partes.

Select @ls_part1	= SUBSTRING(@ls_cantidad, 1, 3)
Select @ls_part2 	= SUBSTRING(@ls_cantidad, 4, 3)
Select @ls_part3 	= SUBSTRING(@ls_cantidad, 7, 3)
Select @ls_part4	= SUBSTRING(@ls_cantidad, 10, 3)
Select @ls_decimales 	= SUBSTRING(@ls_cantidad, 14, 2)

exec sp_cantidadtresdig @ls_part1, @ls_part1_1 out
exec sp_cantidadtresdig @ls_part2, @ls_part2_1 out
exec sp_cantidadtresdig @ls_part3, @ls_part3_1 out
exec sp_cantidadtresdig @ls_part4, @ls_part4_1 out


IF @ls_part1_1 <> ' ' 
	Begin
	IF @ls_part1_1 = 'UN'
		Begin
		Select @ls_part1_1 = 'MIL'
		END
	IF @ls_part1_1 <> 'UN'
		Begin
		Select @ls_part1_1 = @ls_part1_1 + ' MIL'
		END
	END


IF @ls_part2_1 <> ' ' 
	Begin
	IF @ls_part2_1 = 'UN' 
		Begin
		Select @ls_part2_1 = @ls_part2_1 + ' MILLON'
		END
	IF @ls_part2_1 <> 'UN'
		Begin
		Select @ls_part2_1 = @ls_part2_1 + ' MILLONES'
		END 
	end
 


IF @ls_part3_1 <> ' ' 
	Begin
	IF @ls_part3_1 = 'UN' 
		Begin
		Select @ls_part3_1 = 'MIL'
		END
	IF @ls_part3_1 <> 'UN' 
		Begin
		Select @ls_part3_1 = @ls_part3_1 + ' MIL'
		END 
	END 

IF @ls_moneda = 'MX$'
	begin
	Select @ls_moneda = ' PESOS '
	select @ls_monedanac = 'M.N **)'
	end

IF @ls_moneda = 'US$'
	begin
	Select @ls_moneda = ' DOLARES '	
	select @ls_monedanac = '**)'
	end

--Select @ls_leyenda = ' ? '
IF (@ls_part1_1)is Null
	Begin
	Select @ls_part1_1 = ''
	end

IF @ls_part2_1 is Null
	Begin
	Select @ls_part2_1 = ''
	end

IF @ls_part3_1 is Null
	Begin
	Select @ls_part3_1 = ''
	end
IF @ls_part4_1 is Null
	Begin
	Select @ls_part4_1 = ''
	end

SELECT @s_cantidadenletra = LTrim(@ls_part1_1 + ' ' + @ls_part2_1 + ' ' + @ls_part3_1 + ' ' + @ls_part4_1)
SELECT @s_cantidadenletra = +'(**'+@s_cantidadenletra +' '+ @ls_moneda + ' '+ @ls_decimales + '/100 ' +@ls_monedanac

INSERT INTO cantidad_letra (cant_letra)
Values (@s_cantidadenletra)


Select cant_letra from cantidad_letra

Return 0
GO
