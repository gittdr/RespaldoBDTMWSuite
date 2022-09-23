SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Procedimiento para 'liberar' las ordenes de sus evidencias
-- solo del cliente de liverpool ID = LIVERPOL y ALMLIVER

--DROP PROCEDURE sp_LiberaEvidencias_JR 
--GO

-- exec sp_LiberaEvidencias_JR  '2017-05-05', '2017-12-12'

CREATE PROCEDURE [dbo].[sp_LiberaEvidencias_JR]  @fechaini datetime, @fechafin datetime
AS
Declare @Ffin1	varchar(20),
		@Ffin2	datetime,
		@V_documento varchar(6),
		@V_orden Numeric,
		@li_totaldoc Numeric

Select @Ffin1 = convert(Varchar(20),@fechafin,102)

Select @Ffin1 = @Ffin1+' 23:59'
--SELECT CONVERT(Datetime, '2011-09-28 18:01:00', 120)
select @Ffin2 = Convert(DateTime,@Ffin1,102)

--print 'uno ' + @Ffin1
--print 'dos ' + convert(varchar(20),@Ffin2,102)


DECLARE @Ordenes_a_liberar TABLE(
		Orden_liberada		numeric NULL,
		fecha_inicial		datetime Null,
		fecha_final			datetime Null)


DECLARE @conceptosRequeridos TABLE(
TipoDocumento varchar(6) null)

SET NOCOUNT ON

BEGIN --1 Principal

-- llena tabla de conceptos requeridos
INSERT Into @conceptosRequeridos 
SELECT bdt_doctype
FROM            BillDoctypes d (nolock) LEFT OUTER JOIN
                         labelfile l ON l.abbr = d .bdt_doctype AND l.labeldefinition = 'Paperwork' AND IsNULL(l.retired, 'N') <> 'Y'
						 where cmp_id ='LIVERPOL' and bdt_inv_required = 'Y'


-- Llena tabla de las ordenes pendientes por liberar.
	INSERT Into @Ordenes_a_liberar
		select ord_hdrnumber, @fechaini, @Ffin2  
						 from orderheader (nolock)
						 where ord_billto in ( 'LIVERPOL', 'ALMLIVER') and
								ord_revtype4 = 'DED' and ord_bookdate between @fechaini and @Ffin2 and ord_status = 'CMP' 
								

	-- Se declara un cursor para ir leyendo la tabla de los documentos
		DECLARE documentos_Cursor CURSOR FOR 
		SELECT TipoDocumento
		FROM @conceptosRequeridos 
	
		OPEN documentos_Cursor 
		FETCH NEXT FROM documentos_Cursor INTO @V_documento
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )

		BEGIN -- del cursor de los documentos

				-- Se declara un cursor para ir leyendo la tabla de las ORDENES
				DECLARE ordenes_Cursor CURSOR FOR 
				SELECT Orden_liberada
				FROM @Ordenes_a_liberar 
	
				OPEN ordenes_Cursor 

				FETCH NEXT FROM ordenes_Cursor INTO @V_orden

				IF @@FETCH_STATUS <> 0
				print 'documento ' + @V_documento
				print 'Orden '  + convert(varchar(20),@V_orden)
				--Mientras la lectura sea correcta y el contador sea menos al total de registros
				WHILE (@@FETCH_STATUS = 0 )
				BEGIN -- del cursor de las ordenes

					

					-- Revisa si existe de la orden el documento
					select  @li_totaldoc = count(*)
					from paperwork
					where ord_hdrnumber = @V_orden and abbr = @V_documento 

					IF  @li_totaldoc > 0
					Begin

						Update paperwork set pw_received = 'Y', Last_updatedby = 'MOPE2',
						pw_dt =getdate() 
						where ord_hdrnumber = @V_orden and abbr = @V_documento 

					End	
					Else
					begin
						Insert paperwork (abbr, pw_received, ord_hdrnumber, pw_dt, last_updatedby, last_updateddatetime, lgh_number, pw_imaged,mov_number)
						values (@V_documento,'Y', @V_orden,getdate(),'AUTO', getdate(),0,'N',0 )
					end

					FETCH NEXT FROM ordenes_Cursor INTO @V_orden -- de las ordenes
				END -- fin del cursor de las ordenes
				close ordenes_cursor
				DEALLOCATE ordenes_cursor
				
	FETCH NEXT FROM documentos_Cursor INTO @V_documento -- de los documentos
	
	END -- fin del cursor de los documentos
	close documentos_Cursor
	DEALLOCATE documentos_Cursor
Select * from @Ordenes_a_liberar





/*
select distinct(ord_hdrnumber), '2017-10-01', '2017-12-01' from paperwork where pw_received = 'N' and 
			ord_hdrnumber in (select ord_hdrnumber 
						 from orderheader 
						 where ord_billto in ( 'LIVERPOL', 'ALMLIVER') and
	ord_revtype4 = 'DED' and 
	ord_bookdate between '2017-01-01' and '2018-12-01' and
	ord_status = 'CMP'  )

select * from paperwork where ord_hdrnumber = 531608 and abbr in (SELECT bdt_doctype
FROM            BillDoctypes d LEFT OUTER JOIN
                         labelfile l ON l.abbr = d .bdt_doctype AND l.labeldefinition = 'Paperwork' AND IsNULL(l.retired, 'N') <> 'Y'
						 where cmp_id ='LIVERPOL' and bdt_inv_required = 'Y')
*/

END --1 Principal





GO
