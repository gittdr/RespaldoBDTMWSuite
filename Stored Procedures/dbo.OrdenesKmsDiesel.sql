SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DROP PROCEDURE OrdenesKmsDiesel
--GO
-- Procedimiento para obtener las ordenes del proyecto de EUCOMEX
-- 

CREATE   PROCEDURE [dbo].[OrdenesKmsDiesel]
	@OrdProyecto 				Varchar(5),
	@DiasAnt				INT
AS

DECLARE	@li_nomovimiento	INT,
	@ls_nummov		varchar(6),
	@ls_tipoviaje		varchar(6),
	@date_ini		DateTime,
	@date_fin		DateTime,
	@li_kms			real,
	@li_litros		real,
	@ls_kms			varchar(6),
	@ls_litros		varchar(6),
	@ld_rendimiento		real,
	@ls_rendimiento		varchar(6),
	@lsContenido		Varchar(100), 
	@li_count		INT,
	@li_tbl_SN		INT,
	@li_defaultdriver	INT,
	@liFolder 		INT,
	@lsDeliverTo		Varchar(10),
	@li_flota			INT


DECLARE @TTOrdenRend TABLE(
	mov_numero 	INT	NULL,
	tipoviaje	Varchar(6) NULL)

IF @DiasAnt = 0
	SELECT @DiasAnt= 1

select @li_count = 1

IF @li_count > 0

-- Get the hoursback and  hoursout into variables
SELECT @date_ini = DATEADD(day, -@DiasAnt, GETDATE())
SELECT @date_fin = DATEADD(day,  0, GETDATE())

BEGIN --Begin Principal --1
	INSERT INTO	@TTOrdenRend 
	SELECT orderheader.mov_number, lgh_type1
	FROM   orderheader, legheader 
	WHERE 	orderheader.mov_number 	 = legheader.mov_number and 
		ord_revtype3 		 = 'EUC' and 
		ord_status 		 <> 'MST' and
		orderheader.ord_bookdate > @date_ini and 
		orderheader.ord_bookdate <= @date_fin
	Order by 1


-- Toma los valores fijos de la unidad 501

	SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
	       @liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
	       @li_flota = Trucks.CurrentDispatcher
	FROM TMWSuite..tblTrucks Trucks, TMWSuite..tblCabUnits Cab 
	WHERE 	Trucks.Truckname = '501'  and Cab.SN = Trucks.DefaultCabUnit

--Hacer un barrido de cada unos de los renglones de la tabla @TTOrdenRend para
-- insertar correo si es su caso.

	--'Abrir un cursor y recorrelo 
	DECLARE ordenes_Cursor CURSOR FOR 
		SELECT mov_numero, tipoviaje
		FROM @TTOrdenRend 
	
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @li_nomovimiento, @ls_tipoviaje
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor ordenes --2
		SELECT @li_nomovimiento, @ls_tipoviaje


	-- Aqui se revisa que el movimiento sea mayor a 0
	IF @li_nomovimiento > 0
	BEGIN 	-- de cuando el movimiento es mayor a 0 --3
		-- obtiene los datos del kilometraje y de los litros de diesel.
		Select @li_kms	  = sum(IsNull(stp_lgh_mileage,0)) 
		From stops 
		Where mov_number  = @li_nomovimiento

		Select @li_litros = sum(IsNull(pyd_quantity,0))    
		From paydetail 
		Where mov_number  = @li_nomovimiento and pyt_itemcode = 'VALECO' 

		IF @li_kms > 0  and  @li_litros > 0-- tramos por terminar
		BEGIN -- Inicio existe una parada facturable > 0 --4

			-- Rendimiento
			Select @ld_rendimiento = @li_kms/@li_litros

			-- por el momento no considero el tipo FULL 
			-- Pregunta que el rendimento este arriba del 2.18
				IF @ld_rendimiento < 2.18
				BEGIN
					Select @ls_nummov   	= convert(varchar(6),@li_nomovimiento)
					Select @ls_kms		= convert(varchar(6),@li_kms)
					Select @ls_litros	= convert(varchar(6),@li_litros)
--					Select @ls_rendimiento  = convert(varchar(6),convert(float,(@ld_rendimiento)))
					select @lsContenido = 'Mov: ' + @ls_nummov + ', Kms:' +@ls_kms + ', Litros: '+@ls_litros

					INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
									FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN , OrigMsgSN, ReplyFormID, ReplyPriority )
					Values(1, 1, 2, 1, 2, GetDate(), Null, 
						365, @lsContenido, '501', @lsContenido , 'aestrada@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0 , 0, 2)


					-- copia para mi
					INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
									FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN , OrigMsgSN, ReplyFormID, ReplyPriority )
					Values(1, 1, 2, 1, 2, GetDate(), Null, 
						365, @lsContenido, '501', @lsContenido , 'jrlopez@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0 , 0, 2)

				END

		END -- minutos mayor a 60 --6
	END

	FETCH NEXT FROM ordenes_Cursor INTO @li_nomovimiento , @ls_tipoviaje
	
END -- curso de la unidades --2??

CLOSE ordenes_Cursor 
DEALLOCATE ordenes_Cursor 

END --  del Begin Principal --1

GO
