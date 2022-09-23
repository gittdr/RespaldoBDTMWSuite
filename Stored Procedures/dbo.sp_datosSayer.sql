SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--select * from invoiceheader where ord_hdrnumber = 224449





--ivh_billdate between @fechaIni and @fechaFin and 
---Sp utilizado para generar el reporte de Sayer

--execute sp_datosSayer '2013-01-01 00:00:00.000', '2013-10-29 00:00:00.000','HLD'
--select * from tblsayer where orden = 233509


--drop procedure sp_datosSayer
 CREATE PROCEDURE [dbo].[sp_datosSayer]
	-- Add the parameters for the stored procedure here
	@fechaIni datetime,
	@fechaFin datetime,
    @Statusinv varchar(5)
    --,@statusFactura varchar(20)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	delete  tblSayer
	--Variables para almacenar datos del stored procedure y cálculos
	Declare
	@invoice varchar(10),
    @invstatus varchar(4),
	@contador int,
	@referencia varchar(100),
	@orden int,
	@mov_number int,
	@unidad varchar (50),
	@operador varchar(100),
	@caja varchar (50),
	@origen varchar (50),
	@rep1 varchar(50),
	@rep2 varchar(50),
	@rep3 varchar(50),
	@rep4 varchar(50),
	@rep5 varchar(50),
	@reposicionamiento varchar(50),
	@toneladas int,
	@km1 int,
	@km2 int,
	@km3 int,
	@km4 int,
	@km5 int,
	@kmRep int,
	@kmsTotales float,
	@Casetas float,
	@Maniobras float,
	@fuel float,
	@cmp varchar (50),
	@millas int,
	@evento varchar (50),
	@tipo varchar (50),
	@cargo varchar (50),
	@totalCargo float,
	@maniobras1 float,
	@maniobras2 float,
	@maniobras3 float,
	@maniobras4 float,
	@maniobras5 float,
	@comp varchar(20),
	@caseta1 float,
	@caseta2 float,
	@caseta3 float,
	@caseta4 float,
	@caseta5 float,
	@toll float,
	@casetaReposicionamiento float
	
	--Inicialización de los kms,reposicionamientos y maniobras
	select @km1 = 0
	select @km2 = 0
	select @km3 = 0
	select @km4 = 0
	select @km5 = 0
	select @kmRep = 0
	select @rep1 = ' '
	select @rep2 = ' '
	select @rep3 = ' '
	select @rep4 = ' '
	select @rep5 = ' '	
	select @contador = 0
	select @maniobras1  = 0
	select @maniobras2  = 0
	select @maniobras3  = 0
	select @maniobras4  = 0
	select @maniobras5  = 0
	select @caseta1 = 0
	select @caseta2 = 0
	select @caseta3 = 0
	select @caseta4 = 0
	select @caseta5 = 0
	select @casetaReposicionamiento = 0
	select @Casetas = 0
	
	

--Verifica segmentos de la orden
	Declare factura2 cursor for select ord_refnum,ivh_invoicenumber,ivh_invoicestatus,ord_hdrnumber,mov_number,mpp_lastname + ' ' + mpp_firstname as operador,ord_tractor,ord_trailer,cty_name,ord_totalweight from (
select * from (select ord_refnum,ivh_invoicenumber,ivh_invoicestatus,orderheader.ord_hdrnumber,orderheader.mov_number,ord_driver1,ord_trailer,ord_tractor,ord_bookdate,ord_origincity,ord_destcity,ord_totalweight from orderheader left outer join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ord_billto = 'SAYER'  and (ord_startdate between @fechaIni and @fechaFin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader p where p.ivh_invoicenumber not like 'S%') and ivh_billto = 'SAYER'    
and (ivh_invoicestatus in ('HLD','HLA')) --or ivh_mbstatus = 'HLD') 
 and orderheader.ord_status != 'CAN'

union

select ord_refnum,'0','NFAC',orderheader.ord_hdrnumber,orderheader.mov_number,ord_driver1,ord_trailer,
ord_tractor,ord_bookdate,ord_origincity,ord_destcity,ord_totalweight from orderheader  where  orderheader.ord_status != 'CAN' and orderheader.ord_status = 'CMP' and ord_billto = 'SAYER' 
and (ord_startdate between @fechaIni and @fechaFin)
and orderheader.ord_hdrnumber not in (select ord_hdrnumber from invoiceheader where ivh_invoicenumber not like 'S%'))

 as tbl1  left outer join manpowerprofile on mpp_id = ord_driver1) as tbl2 left outer join city on cty_code = ord_origincity order by ord_hdrnumber
	
open factura2
	fetch factura2 into @referencia,@invoice,@invstatus,@orden,@mov_number,@operador,@unidad,@caja,@origen,@toneladas
	while @@FETCH_STATUS = 0
		begin
			 select @contador = @contador + 1
			
			--Llenado de kms y descargas.
			Declare paradas cursor for select cty_name,stp_ord_mileage,stp_event,stp_type,stp_ord_toll_cost from stops left outer join city on cty_code = stp_city  where ord_hdrnumber = @orden order by stp_sequence
			open paradas
			fetch paradas into 	@cmp,@millas,@evento,@tipo, @toll
			while @@FETCH_STATUS = 0
				begin
					--print 'contadorParadas:  '+ cast(@contador as nvarchar(100))
					IF @evento = 'IEMT'
						begin
							select @kmRep = @millas
							select @reposicionamiento = @cmp
							if isnull (@toll,0) = 0
								begin
									select @casetaReposicionamiento = 0	
								end
							else 
								begin
									select @casetaReposicionamiento = @toll	
								end
						end
					else if @rep1 = ' ' and @tipo = 'DRP'
						begin
							--print 'Compañia1:  '+ cast(@cmp as nvarchar(100))
							--print 'Evento1:  '+ cast(@tipo as nvarchar(100))
							select @km1 = @millas
							select @rep1 = @cmp
							if isnull (@toll,0) = 0
								begin
									select @caseta1 = 0	
								end
							else 
								begin
									select @caseta1 = @toll	
								end

						end
					else if @rep2 = ' ' and @tipo = 'DRP'
						begin
							--print 'Compañia2:  '+ cast(@cmp as nvarchar(100))
							--print 'Evento2:  '+ cast(@tipo as nvarchar(100))
							select @km2 = @millas
							select @rep2 = @cmp
							if isnull (@toll,0) = 0
								begin
									select @caseta2 = 0	
								end
							else 
								begin
									select @caseta2 = @toll	
								end
							
						end
					else if @rep3 = ' ' and @tipo = 'DRP'
						begin
							--print 'Compañia3:  '+ cast(@cmp as nvarchar(100))
							--print 'Evento3:  '+ cast(@tipo as nvarchar(100))
							select @km3 = @millas
							select @rep3 = @cmp
							if isnull (@toll,0) = 0
								begin
									select @caseta3 = 0	
								end
							else 
								begin
									select @caseta3 = @toll	
								end
						end 
					else if @rep4 = ' ' and @tipo = 'DRP'
						begin
							--print 'Compañia4:  '+ cast(@cmp as nvarchar(100))
							--print 'Evento4:  '+ cast(@tipo as nvarchar(100))
							select @km4 = @millas
							select @rep4 = @cmp
							
							if isnull (@toll,0) = 0
								begin
									select @caseta4 = 0	
								end
							else 
								begin
									select @caseta4 = @toll	
								end	
			
						end
					else if @rep5 = ' ' and @tipo = 'DRP'
						begin
							--print 'Compañia5:  '+ cast(@cmp as nvarchar(100))
							--print 'Evento5:  '+ cast(@tipo as nvarchar(100))
							select @km5 = @millas
							select @rep5 = @cmp
							if isnull (@toll,0) = 0
								begin
									select @caseta5 = 0	
								end
							else 
								begin
									select @caseta5 = @toll	
								end
						end
						
					FETCH NEXT FROM paradas into @cmp,@millas,@evento,@tipo,@toll
				end

				CLOSE paradas 
				DEALLOCATE paradas
				--print 'contadorGeneral:  '+ cast(@contador as nvarchar(100))
				--Lenado de datos de Casetas, Maniobras y Fuel
				
				Declare conceptos cursor for select cht_itemcode,ivd_charge from invoicedetail where ord_hdrnumber = @orden and not cht_itemcode in ('GST', 'PST', 'MODESC')
				open conceptos
				fetch conceptos into @cargo, @totalCargo
				while @@FETCH_STATUS = 0
				begin
					--print 'contadorConceptos:  '+ cast(@contador as nvarchar(100))
					if @cargo = 'TOLL'
						begin
							select @Casetas = @totalCargo
						end	
					else if @cargo = 'CPAC'
						begin
							select @fuel =  @totalCargo
						end
					else if @cargo in ('VIAJE','LHF') --En sayer tambien se cobran los vacios LHF y se aniaden al valor de los kms
						begin
							select @kmsTotales = @totalCargo
						end
					
						
					FETCH NEXT FROM conceptos INTO @cargo, @totalCargo
				end
				CLOSE conceptos 
				DEALLOCATE conceptos

				--Obtener datos de maniobras agrupado por reparto
				

				Declare maniobrasCursor cursor for select cht_itemcode,cmp_id,sum (ivd_charge) from invoicedetail where ord_hdrnumber = @orden group by cmp_id, cht_itemcode
				open maniobrasCursor
				fetch maniobrasCursor into @cargo,@comp, @totalCargo
				while @@FETCH_STATUS = 0
				begin
					print 'maniobras1:  '+ cast(@maniobras1 as nvarchar(100))
					if @maniobras1 = 0 and (@cargo = 'MODESC' or @cargo = 'MOCARG')
						begin
							print 'Entromaniobras1:  '+ cast(@cargo as nvarchar(100))
							select @maniobras1 = @totalCargo
							print 'Entromaniobras1value:  '+ cast(@maniobras1 as nvarchar(100))
						end
					else if @maniobras2 = 0 and (@cargo = 'MODESC' or @cargo = 'MOCARG')
						begin
							select @maniobras2 = @totalCargo
						end	
					else if @maniobras3 = 0 and (@cargo = 'MODESC' or @cargo = 'MOCARG')
						begin
							select @maniobras3 = @totalCargo
						end
					else if @maniobras4 = 0 and (@cargo = 'MODESC' or @cargo = 'MOCARG')
						begin
							select @maniobras4 = @totalCargo
						end
					else if @maniobras5 = 0 and (@cargo = 'MODESC' or @cargo = 'MOCARG')
						begin
							select @maniobras5 = @totalCargo
						end
						
					FETCH NEXT FROM maniobrasCursor INTO @cargo,@comp, @totalCargo
				end
				CLOSE maniobrasCursor 
				DEALLOCATE maniobrasCursor


				
				print 'm1:  '+ cast(@maniobras1 as nvarchar(100))
				print 'm2:  '+ cast(@maniobras2 as nvarchar(100))
				print 'm3:  '+ cast(@maniobras3 as nvarchar(100))
				
				select @Maniobras = @maniobras1 + @maniobras2 + @maniobras3 + @maniobras4 + @maniobras5
				
                select @Casetas =  @Casetas 

				--select @Casetas = @caseta1+@caseta2+@caseta3+@caseta4+@caseta5+@casetaReposicionamiento

				 insert into tblSayer(invoice,invstatus,contador,referencia,orden,mov_number,unidad,operador,caja,origen,rep1,rep2,
					rep3,rep4,rep5,reposicionamiento,toneladas,km1,km2,km3,km4,km5,kmRep,kmsTotales,casetas1,casetas2,casetas3,casetas4,casetas5,casetaRep,Casetas,maniobras1,maniobras2,maniobras3,maniobras4,maniobras5,Maniobras,fuel)
					values (@invoice,@invstatus,@contador,@referencia,@orden,@mov_number,@unidad,@operador,@caja,@origen,@rep1,@rep2,
					@rep3,@rep4,@rep5,@reposicionamiento,@toneladas,@km1,@km2,@km3,@km4,@km5,@kmRep,@kmsTotales,@caseta1,@caseta2,@caseta3,@caseta4,@caseta5,@casetaReposicionamiento,@Casetas,@maniobras1,@maniobras2,@maniobras3,@maniobras4,@maniobras5,@Maniobras,@fuel)
				
				select @rep1 = ' '
				select @rep2 = ' '
				select @rep3 = ' '
				select @rep4 = ' '
				select @rep5 = ' '
				select @km1 = 0
				select @km2 = 0
				select @km3 = 0
				select @km4 = 0
				select @km5 = 0
				select @kmRep = 0
				select @maniobras1 = 0
				select @maniobras2 = 0
				select @maniobras3 = 0
				select @maniobras4 = 0
				select @maniobras5 = 0
				select @caseta1 = 0
				select @caseta2 = 0
				select @caseta3 = 0
				select @caseta4 = 0
				select @caseta5 = 0
				select @casetaReposicionamiento = 0
				select @Casetas = 0

			FETCH NEXT FROM factura2 INTO  @referencia,@invoice,@invstatus,@orden,@mov_number,@operador,@unidad,@caja,@origen,@toneladas

		end
	CLOSE factura2
	DEALLOCATE factura2
	--select @contador = 0
	--print 'contadorFinal:  '+ cast(@contador as nvarchar(100))
 
  if @Statusinv = 'Todos'
    BEGIN
     select * from tblSayer where invstatus in ('HLD','HLA')
    END
ELSE IF @Statusinv = 'NFAC'
   BEGIN
	select * from tblSayer where invstatus in ('NFAC')
  END
ELSE
	select * from tblSayer where invstatus in (@Statusinv)

END


















GO
