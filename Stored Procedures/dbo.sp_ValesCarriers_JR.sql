SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_ValesCarriers_JR] @fecha date as 
/*
Identifica Ordenes de carriers con vales de combustible
exec sp_ValesCarriers_JR '2017-01-01'

se deja en la tabla el nombre del campo ORD_numero, pero realmente es el movimiento
*/

Declare @Ordenes table(
		ID_operador		varchar(8),
		ORD_numero		Integer,
		Unidad_numero	Integer,
		Litros			Integer,
		documento		varchar(10),
		nombre_doc		varchar(100),
		Billto			varchar(15),
		nombre_bill		varchar(100),
		fecha_orden		datetime)

declare	@V_ID_operador  varchar(8),
		@V_ORD_numero	Integer, 
		@V_Doc_Id		varchar(10), 
		@V_nombre_doc	varchar(100),
		@V_Billto		varchar(15),
		@V_nombre_bill	varchar(100),
		@V_fechaorden	datetime

	insert into @Ordenes (ID_operador,ORD_numero,Unidad_numero,Litros,documento,nombre_doc,Billto,nombre_bill, fecha_orden)
	select drv_id, mov_number, trc_id,sum(ftk_liters),null,null,null,null, null
	from fuelticket 
	where lgh_number in (select lgh_number from paydetail PD where  lgh_number in (select lgh_number from legheader where  lgh_carrier <> 'UNKNOWN' and lgh_startdate >  @fecha and mov_number >0 and lgh_driver1 = 'UNKNOWN')
	and asgn_id = 'PROVEEDO' and pyd_quantity > 0 and pyt_itemcode = 'VALEEL')  --and ftk_recycled = 'N'
	group by drv_id, mov_number, trc_id
	order by 2
--
--Recorre cada uno de los renglones de los Operadores

If Exists ( Select count(*) From  @Ordenes )
	BEGIN -- 1 inicio del barrido de las ordenes
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE ordenes_Cursor CURSOR FOR 
		SELECT ID_operador,ORD_numero,Unidad_numero
		FROM @Ordenes 
	
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @V_ID_operador, @V_ORD_numero, @V_Doc_Id
		WHILE @@FETCH_STATUS = 0 
		BEGIN --2 del cursor operadores_Cursor --2

			-- obtiene los datos de la orden
			
			Select @V_Billto = ord_billto, 
			@V_Doc_Id		 = ord_bookedby , 
			@V_nombre_bill	 =  cmp_name, 
			@V_nombre_doc	 =  usr_fname +' '+ usr_lname,
			@V_fechaorden	 = ord_bookdate 
			From orderheader, company , ttsusers
			Where 
			cmp_id = ord_billto and 
			usr_userid = ord_bookedby and 
			mov_number = @V_ORD_numero;


			-- Hace el update de los anticipos del operadore con los nuevos datos.
				Update @Ordenes 
				Set documento	= @V_Doc_Id,
				nombre_doc		= @V_nombre_doc,
				Billto			= @V_Billto,
				nombre_bill		= @V_nombre_bill,
				fecha_orden		= @V_fechaorden
				Where ID_operador = @V_ID_operador and 
				ORD_numero		  = @V_ORD_numero

	


			FETCH NEXT FROM ordenes_Cursor INTO @V_ID_operador, @V_ORD_numero, @V_Doc_Id
		
		END --2

	CLOSE ordenes_Cursor 
	DEALLOCATE ordenes_Cursor
	
	
	select * from @Ordenes order by 2; 

END --1
GO
