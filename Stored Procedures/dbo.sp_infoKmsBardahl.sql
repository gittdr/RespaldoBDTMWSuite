SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que ordena la informacion de la facturable del cliente de Bardahl

--DROP PROCEDURE sp_infoKmsBardahl
--GO

--  exec sp_infoKmsBardahl

CREATE PROCEDURE [dbo].[sp_infoKmsBardahl]

AS
DECLARE	
	@V_orden			Integer,
	@V_ordenAnt			Integer,
	@V_idcompania		Varchar(10), 
	@V_nomcompania		Varchar(250), 
	@V_Ciudad			Integer,
	@V_Kms				Integer,
	@V_registros		integer,
	@V_i				integer,
	@V_a				integer,
	@V_secuencia		Integer,
	@VnomCiudad			Varchar(18),
	@VNomEdo			Varchar(6)

DECLARE @TTKmsBarda TABLE(
		KMB_orden			Int null,
		KMB_idcompania		Varchar(10) NULL,
		KMB_nomcompania		Varchar(250) NULL,
		KMS_Idcity			Int Null,
		KMB_Ciudad			Varchar(18) null,
		KMS_estado			Varchar(6)NUll,
		KMB_Kms				Int NULL)

--KMB_orden, KMB_idcompania, KMB_nomcompania, KMS_Idcity, KMB_Ciudad, KMS_estado, KMB_Kms

DECLARE @TTkmsOri_Dest TABLE(
		Orden				Integer Null,
		Origen1				Varchar(10) NULL,
		id_ciudad1			Integer Null,
		Ciudad1				Varchar(18) null,
		Estado1				Varchar(6) Null,
		Kms1				Integer Null,
		Origen2				Varchar(10) NULL,
		id_ciudad2			Integer Null,
		Ciudad2				Varchar(18) null,
		Estado2				Varchar(6) Null,
		Kms2				Integer Null,
		Origen3				Varchar(10) NULL,
		id_ciudad3			Integer Null,
		Ciudad3				Varchar(18) null,
		Estado3				Varchar(6) Null,
		Kms3				Integer Null,
		Origen4				Varchar(10) NULL,
		id_ciudad4			Integer Null,
		Ciudad4				Varchar(18) null,
		Estado4				Varchar(6) Null,
		Kms4				Integer Null,
		Origen5				Varchar(10) NULL,
		id_ciudad5			Integer Null,
		Ciudad5				Varchar(18) null,
		Estado5				Varchar(6) Null,
		Kms5				Integer Null)
--Orden, Origen1, Kms1, Origen2, Kms2, Origen3, Kms3, Origen4, Kms4, Origen5, Kms5


SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTKmsBarda 
SELECT ord_hdrnumber, cmp_id, cmp_name, stp_city, cty_name, cty_state,  stp_ord_mileage
FROM stops, City
WHERE stp_type in ('PUP','DRP') and ord_hdrnumber in (
				select ord_hdrnumber from orderheader 
				where ord_status = 'CMP' and ord_billto = 'BARDAHL' and
				ord_startdate > '01-01-2012')
and stp_city = cty_code order by ord_hdrnumber
--and ord_hdrnumber = 183612



--Se obtiene el total de registros de la tabla temporal
select @V_registros =  (Select count(*) From  @TTKmsBarda)
--print @V_registros
--Se inicializa el contador en 1
select @V_i = 1

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTKmsBarda )
	BEGIN --3 Si hay movimientos de posiciones

		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT KMB_orden, KMB_idcompania, KMB_nomcompania, KMS_Idcity, KMB_Ciudad, KMS_estado, KMB_Kms
		FROM @TTKmsBarda 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_idcompania, @V_nomcompania, @V_Ciudad, @VnomCiudad, @VNomEdo, @V_Kms
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 and @V_i <= @V_registros)
		BEGIN -- del cursor Unidades_Cursor --3
			--SELECT @V_orden, @V_idcompania, @V_nomcompania, @V_Ciudad, @V_Kms
		IF @V_i = 1
			Begin
			 Select @V_a = 1
			 Select @V_OrdenAnt = @V_orden
			End
		IF @V_i > 1
			IF @V_OrdenAnt <> @V_orden
				Begin
					Select @V_a = 1
					Select @V_OrdenAnt = @V_orden
				End
			Else
				Begin
					Select @V_a = @V_a + 1
				End
		---

				
				IF @V_a = 1
					Begin
						select @V_OrdenAnt = @V_orden
						Insert @TTkmsOri_Dest (Orden, Origen1, Kms1,Ciudad1, Estado1, id_ciudad1 )
						Values (@V_orden, @V_idcompania, @V_Kms, @VnomCiudad, @VNomEdo, @V_Ciudad)
					end
				IF @V_a = 2
					Update  @TTkmsOri_Dest Set Origen2 = @V_idcompania , Kms2 = @V_Kms, Ciudad2 = @VnomCiudad, Estado2 = @VNomEdo,id_ciudad2 = @V_Ciudad
					Where orden = @V_orden
				IF @V_a = 3
					Update  @TTkmsOri_Dest Set Origen3 = @V_idcompania , Kms3 = @V_Kms, Ciudad3 = @VnomCiudad, Estado3 = @VNomEdo,id_ciudad3 = @V_Ciudad
					Where orden = @V_orden
				IF @V_a = 4
					Update  @TTkmsOri_Dest Set Origen4 = @V_idcompania , Kms4 = @V_Kms, Ciudad4 = @VnomCiudad, Estado4 = @VNomEdo,id_ciudad4 = @V_Ciudad
					Where orden = @V_orden
				IF @V_a = 5
					Update  @TTkmsOri_Dest Set Origen5 = @V_idcompania , Kms5 = @V_Kms, Ciudad5 = @VnomCiudad, Estado5 = @VNomEdo,id_ciudad5 = @V_Ciudad
					Where orden = @V_orden

				--Se aumenta el contador en 1.
				select @V_i = @V_i + 1

		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_idcompania, @V_nomcompania, @V_Ciudad, @VnomCiudad, @VNomEdo, @V_Kms
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 

END -- 2 si hay movimientos del RC
Select Orden, Origen1, Kms1,id_ciudad1,Ciudad1, Estado1, Origen2, Kms2, id_ciudad2, Ciudad2, Estado2, Origen3, Kms3, id_ciudad3, Ciudad3, Estado3,
Origen4, Kms4, id_ciudad4, Ciudad4, Estado4, Origen5, Kms5, id_ciudad5, Ciudad5, Estado5 from @TTkmsOri_Dest

END --1 Principal


GO
