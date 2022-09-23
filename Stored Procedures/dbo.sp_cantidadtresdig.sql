SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- SP Para obtener el nombre en letra de una cantidad de 3 digitos
-- Drop PROCEDURE sp_cantidadtresdig
CREATE PROCEDURE [dbo].[sp_cantidadtresdig] @as_cantidad varchar(3), @ls_nombre varchar(250) out
as 
DECLARE @ls_part1 varchar(50),
	@ls_part2 varchar(50),
	@ls_part3 varchar(50),
	@ls_car1  varchar(3),
	@ls_car2  varchar(3),
	@ls_car3  varchar(3)


Select @as_cantidad = LTRIM(@as_cantidad)
Select @as_cantidad = RTRIM(@as_cantidad)
--Select @as_cantidad = Right('   ' + (@as_cantidad),3)

Select @ls_car1 = SUBSTRING(@as_cantidad, 1, 1)
Select @ls_car2 = SUBSTRING(@as_cantidad, 2, 1)
Select @ls_car3 = SUBSTRING(@as_cantidad, 3, 1)

--INSERT INTO cantidad_letra (cant_letra) Values (@as_cantidad)

--INSERT INTO cantidad_letra (cant_letra) Values (@ls_car1)
--INSERT INTO cantidad_letra (cant_letra) Values (@ls_car2)
-- INSERT INTO cantidad_letra (cant_letra)Values (@ls_car3)


-- Analiza la parte que está entre 100 y 999
IF @ls_car1 <> '0' 
	BEGIN
		 IF @ls_car1 = '1' 
			BEGIN
			  select @ls_part1 = 'CIENTO '
			
			IF @ls_car2 = '0' AND @ls_car3 = '0' 
			 BEGIN
				   select @ls_part1 = 'CIEN'
			 END 
			 END 

		 IF @ls_car1 = '2'
			BEGIN
				select @ls_part1 = 'DOSCIENTOS '
			END 
		 IF @ls_car1 = '3'
			BEGIN
				select @ls_part1 = 'TRESCIENTOS '
			END 
		 IF @ls_car1 = '4'
			BEGIN
				select @ls_part1 = 'CUATROCIENTOS '
			END 
		 IF @ls_car1 = '5'
			BEGIN
				select @ls_part1 = 'QUINIENTOS '
			END 
		 IF @ls_car1 = '6'
			BEGIN
				select @ls_part1 = 'SEISCIENTOS '
			END 
		 IF @ls_car1 = '7'
			BEGIN
				select @ls_part1 = 'SETECIENTOS '
			END 
		 IF @ls_car1 = '8'
			BEGIN
				select @ls_part1 = 'OCHOCIENTOS '
			END 
		 IF @ls_car1 = '9'
			BEGIN
				select @ls_part1 = 'NOVECIENTOS '
			END 
		 IF @ls_car1 = '0'
			BEGIN
				select @ls_part1 = ' '
			END 
	END 
IF @ls_car1 = '0'
	begin
	SELECT @ls_part1 = ' '
	end


-- Analiza la parte que está entre 10 y 99


IF @ls_car2 <> '0' 
	BEGIN
	IF @ls_car2 = '1'
	   Begin 
		Select @ls_part2 = 'DIECI'
		IF @ls_car3 = '0' 
		   Begin
			Select @ls_part2 = 'DIEZ'
   		    END 		
	     END
	IF @ls_car2 = '2'
		Begin
		  Select @ls_part2 = 'VEINTI'
		END
	IF @ls_car3 = '0' 
		Begin
		    Select @ls_part2 = 'VEINTE'
		END
	IF @ls_car2 = '3'
		Begin
		    Select @ls_part2 = 'TREINTA '
		END
	IF @ls_car2 = '4'
		Begin
		    Select @ls_part2 = 'CUARENTA '
		END
	IF @ls_car2 = '5'
		Begin
		    Select @ls_part2 = 'CINCUENTA '
		END
	IF @ls_car2 = '6'
		Begin
		    Select @ls_part2 = 'SESENTA '
		END
	IF @ls_car2 = '7'
		Begin
		    Select @ls_part2 = 'SETENTA '
		END
	IF @ls_car2 = '8'
		Begin
		    Select @ls_part2 = 'OCHENTA '
		END
	IF @ls_car2 = '9'
		Begin
		    Select @ls_part2 = 'NOVENTA '
		END

	END	
	IF @ls_car2 = '0' 
	begin
		select @ls_part2 = ' '
	end



IF cast(@ls_car2 as int) > 2 AND cast(@ls_car3 as int) > 0  
	BEGIN
	   Select @ls_part2 = @ls_part2 + 'Y '
	END 


-- Analiza la parte que está entre 10 y 99


IF @ls_car3 <> '0'
	BEGIN
	IF @ls_car3 = '1'
		BEGIN
		Select @ls_part3 = 'UN'
		END 
	IF @ls_car3 = '2'
		BEGIN
		Select	@ls_part3 = 'DOS'
		END 
	IF @ls_car3 = '3'
		BEGIN
		Select	@ls_part3 = 'TRES'
		END 
	IF @ls_car3 = '4'
		BEGIN
		Select	@ls_part3 = 'CUATRO'
		END 
	IF @ls_car3 = '5'
		BEGIN
		Select	@ls_part3 = 'CINCO'
		END 
	IF @ls_car3 = '6'
		BEGIN
		Select	@ls_part3 = 'SEIS'
		END 
	IF @ls_car3 = '7'
		BEGIN
		Select	@ls_part3 = 'SIETE'
		END 
	IF @ls_car3 = '8'
		BEGIN
		Select	@ls_part3 = 'OCHO'
		END 
	IF @ls_car3 = '9'
		BEGIN
		Select	@ls_part3 = 'NUEVE'
		END 
END
IF @ls_car3 = '0' 
	Begin
	Select @ls_part3 = ' '
	END
 

-- Cuando está entre 11 y 15
IF @ls_car2 = '1' AND cast(@ls_car3 as Int) > 0 AND cast(@ls_car3 as Int) < 6 
	BEGIN
	 IF @ls_car3 = '1'
		BEGIN
			Select @ls_part2 = 'ONCE'
			Select @ls_part3 = ' '
		END
		IF @ls_car3 = '2'
		   BEGIN
			Select	@ls_part2 = 'DOCE'
			Select  @ls_part3 = ' '
		   END
		IF @ls_car3 = '3'
		   BEGIN
			Select  @ls_part2 = 'TRECE'
			Select  @ls_part3 = ' '
		   END
		IF @ls_car3 =  '4'
		   BEGIN
			Select  @ls_part2 = 'CATORCE'
			Select  @ls_part3 = ' '
		   END
		IF @ls_car3 =  '5'
		   BEGIN
			Select  @ls_part2 = 'QUINCE'
			Select  @ls_part3 = ' '
		   END 
--	Select @ls_part3 = ' '
	END 

Begin
SELECT @ls_nombre = @ls_part1 + @ls_part2 + @ls_part3
end
--SELECT @ls_nombre =  @ls_part3
--INSERT INTO cantidad_letra (cant_letra)
--Values (@ls_nombre)

--Return 0
GO
