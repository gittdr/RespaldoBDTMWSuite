SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Fecha: 28 Oct 2021 13:04 hrs
Version 1.0

Stored Proc que valida la cadena para formar el txt
de uan carta porte desarrolado con base al layout  Carta porte V3 de Tralix

Recibe como parametro el numero de de legheader
dado que en una orden segmentado son varios los recursos involucrados.

Modifico: JR Lopez
fecha: 11 de mayo 2022 16:30
ahora toma los datos de la factura

Sentencia de prueba



exec sp_validaCFDICartaporte 1223622

exec sp_validaCFDICartaporte 1236769

---DEBUG CON SALTOS DE LINEA PARA MEJOR VISUALIZACION
 sp_DebugvalidaCFDICartaporte  1236769


select lgh_primary_pup, * from legheader where lgh_number = '1190299'
select * from trailerprofile where trl_numbeR = 'UNKNOWN'


*/

CREATE proc [dbo].[sp_validaCFDICartaporte] @lgh_hdrnumber varchar(20)
as

declare @lgh_hdrnumber2 varchar(20),
		@num_factura int,
		@num_movimiento int
		, @esunafactura bit

/* factura
select @esunafactura = 0

if @lgh_hdrnumber > 1330170 
begin
select @esunafactura = 1
end
if @esunafactura = 1

begin
select @num_factura = cast(@lgh_hdrnumber as int)
select @num_movimiento = mov_number from invoiceheader where ivh_hdrnumber = @num_factura
select @lgh_hdrnumber2 = MIN(lgh_number) from legheader where mov_number = @num_movimiento AND lgh_driver1 <> 'UNKNOWN'

select replace(Mensaje,'^','') as Mensaje, case when Mensaje like '%^%' then 'Error' else 'OK' end as Validacion from (


		select 

		  case when 
			  (select count(Folio) from VISTA_Carta_Porte where LegNum = @lgh_hdrnumber) >=1 then '<br> <br> ****Ya existe un CFDI Complemento Carta Porte Generado 
																								   para el número de factura '+ '<b style='+''''+'color:black;'+''''+'>' + @lgh_hdrnumber+ ' </b> *****'  + '<br>'+  
																								   '<br>' + 
																								  '<b style='+''''+'color:red;'+''''+'> Si el viaje se segmento con otra unidad/operador es necesario
																								   ingresar el número del nuevo segmento y cancelar el CFDI previo. ^</b>' 
		  else

   
		   case when len(isnull((select replace(replace(cmp_taxid,'|',''),'-','') from company where cmp_id = orderheader.ord_billto),'')) < 11 then '<br> <br> El RFC del Billto' + orderheader.ord_billto +'<b style='+''''+'color:red;'+''''+'> no correcto len(13) ^</b>'  else '<br> <br> RFC Billto '+ + orderheader.ord_billto +' OK' end + '<br>'+
		   --case when convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) = 0 then  '<b style='+''''+'color:red;'+''''+'>El monto a facturar del viaje es 0 no puede generarse comprobante en 0 (totalchage0)^</b>' else 'Monto Factura Orden Ok'  end + '<br>'+
		   case when convert(decimal (10,2),isnull(invoiceheader.ivh_totalcharge,0)) = 0 then  '<b style='+''''+'color:red;'+''''+'>El monto a facturar del viaje es 0 no puede generarse comprobante en 0 (totalchage0)^</b>' else 'Monto Factura Orden Ok'  end + '<br>'+

		   case when (select cmp_zip from company where cmp_id = ivh_originpoint)  is null then 'El codigo postal del origen del viaje ' + isnull(ivh_originpoint,'')  + '<b style='+''''+'color:red;'+''''+'> no valido^</b>'  else 'CP Origen viaje ' + isnull(ivh_originpoint,'') + '  Zip OK' end + '<br>'+
		   case when (select municipio from satcpcat where cp = (select cmp_zip from company where cmp_id = ivh_originpoint))  is null then 'El codigo de municipio del origen del viaje ' + isnull(ivh_originpoint,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>' else 'CP Origen ' + isnull(ivh_originpoint,'') + ' Municipio OK' end + '<br>'+
		   case when (select estado from satcpcat where cp = (select cmp_zip from company where cmp_id = ivh_originpoint))  is null then 'El codigo de estado del origen del viaje ' + isnull(ivh_originpoint,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>'else 'CP Origen ' +  isnull(ivh_originpoint,'') +' Estado OK' end + '<br>' +  




		   replace( (STUFF(( 

			select 
	
		   (select 
			 case when (cmp_zip)  is null then 'El codigo postal de ' + isnull(cmp_id,'')  + '<b style='+''''+'color:red;'+''''+'> es invalido(null)^</b>' else 'CP para ' + isnull(cmp_id,'') + ' Zip OK no es nulo' end  +'ºçº' +
			 case when len(cmp_zip) < 5 then 'El codigo postal de ' + isnull(cmp_id,'')  + '<b style='+''''+'color:red;'+''''+'> con longitud no valida^</b>' else 'CP para ' + isnull(cmp_id,'') + ' Zip OK longitud' end  +'ºçº' +
			 case when (select municipio from satcpcat where cp = cmp_zip)  is null then 'El codigo de municipio  para ' + isnull(cmp_id,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>' else 'CP para ' + isnull(cmp_id,'') +' Municipio OK' end +'ºçº'  +                                                   
			 case when (select estado from satcpcat where cp = cmp_zip)  is null then 'El codigo de estado para ' + isnull(cmp_id,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>' else 'CP para ' + isnull(cmp_id,'')  + ' Estado OK' end  +'ºçº' 
			from company where company.cmp_id = stops.cmp_id) 
	
	
			  +
	

   			case when (select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')

				 from company where company.cmp_id = stops.cmp_id) is null then 'RFC locación '+ isnull(stops.cmp_id,'') + ' es nulo, Se usara RFC de facturación cliente'

				  when (select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')

				 from company where company.cmp_id = stops.cmp_id) = '' then  'RFC locación '+ isnull(stops.cmp_id,'') + ' en blanco, Se usara RFC facturación cliente'

				 when len((select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')

				 from company where company.cmp_id = stops.cmp_id))  < 12 then  'El RFC de '+ isnull(stops.cmp_id,'') + '<b style='+''''+'color:red;'+''''+'> tiene una longitud no valida^</b>'

				 else ''

				 end   +     'ºçº'  														         
                                                                         
	
                                                 
	                                                                                                             
			from stops 
			left join company on company.cmp_id = stops.cmp_id
			where lgh_number = @lgh_hdrnumber2
			and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
			and stp_type <> 'NONE'
			order by stp_sequence
			FOR XML PATH('')),1,0,'')
			),'ºçº' ,'<br>')   + 



	

			case when (select sum(case stp_lgh_mileage when 0 then 0.01 when '-1' then 0.01 else stp_lgh_mileage  end)                                                                                                            
			from stops 
			where lgh_number = @lgh_hdrnumber2
			and stp_sequence <> 1
			and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')) <= 0 then 'Los kms facturables a recorrer en el segmento ' + @lgh_hdrnumber2 + '<b style='+''''+'color:red;'+''''+'> no son validos^</b>'  else 'Kms segmento ' + @lgh_hdrnumber2 + ' OK' end + '<br>'+

			' Distancia Header Segmento:' + casT( (select cast(sum (case when stp_lgh_mileage = 0 then 0.01  when stp_lgh_mileage IS NULL  
			then 0.01  when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage) end)   as varchar(20))                                                                                                               
			from stops 
			where stops.ord_hdrnumber = orderheader.ord_hdrnumber
			and stp_type = 'DRP'
			and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')) as varchar(20))+  '<br>'+


			--case when 	(select SUM(fgt_weight) from freightdetail where stp_number in  (select stp_number from stops where stp_type  ='PUP'  and lgh_number= @lgh_hdrnumber2))  <= 0 then 'Peso del segmento ' + @lgh_hdrnumber2 + '<b style='+''''+'color:red;'+''''+'> no valido^</b>' else 'Peso segmento ' + @lgh_hdrnumber2 + ' Ok' end  + '<br>'+ 
--			case cast (isnull(ivd_wgt,0) as int) when 0 then 'Cantidad Mercancia no valida'  else ' Cantidad Mercancia OK' end 		  +  


	

	
		 --isnull(replace( (STUFF(( 

			--select distinct 

																			
			--case when replace(isnull(f.cmd_code,''),'|','') not in (select cmd_code from commodity where cmd_updatedby = 'SATIMPORT') then 'Codigo Producto ' +  isnull(f.cmd_code,'') + '<b style='+''''+'color:red;'+''''+'>Nno valido en Catalogo SAT^</b>'  + '<br>'  else  'Codigo Producto ' + isnull(f.cmd_code,'') + ' OK'        end     +   'ºçº' +                                                                                                                        
																		       

		 --  case  isnull(replace(f.fgt_description,'|',''),'NA')   when  'Na' then  '<b style='+''''+'color:red;'+''''+'> Des no valida^ºç</b>'  + '<br>'   when null then '<b style='+''''+'color:red;'+''''+'>Des no valida^</b>'  + '<br>'  else  ' Descripcion Ok' end   +   'ºçº' +                                                                                                                         
																		      
		 --  case cast(isnull(f.fgt_count,0) as int)  when 0  then 'Cantidad mercancia ' + cast(f.fgt_count as varchar(20)) + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'   when null then '<b style='+''''+'color:red;'+''''+'> Cantidad Mercancia no valida^</b>'  + '<br>'    else ' Cantidad Mercancia OK' end     +   'ºçº' +                                                                                        
																	          
		 --  case when replace(isnull(f.fgt_countunit,''),'|','') not in (select abbr from labelfile where labeldefinition = 'CountUnits' and param1 = 'SATIMPORT') then 'Clave unidad ' + f.fgt_countunit + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'  else ' Clave Unidad Ok' end +      'ºçº' +                                                                                                                                 
																	         																         
		 --  isnull(' Volumen: ' + isnull(cast(replace(isnull(f.fgt_volume,0),0,'') as varchar(10)),'No incuido pero no mandatorio'), 'Volumen no incluido pero no mandatorio') +     'ºçº'  +
                                                                                                               
		 --  case when (select  isnull(SUM(fgt_weight),0) from freightdetail r where f.cmd_code =r.cmd_code and  stp_number in  (select stp_number from stops where stp_type  ='PUP'  and lgh_number= @lgh_hdrnumber2))  = 0  then '<b style='+''''+'color:red;'+''''+'> Cantidad Mercancia no valida^</b>'  + '<br>'     else ' Cantidad Mercancia OK' end 		  +     'ºçº'  														         
                                                                         
			--from stops
			--left join freightdetail f on stops.stp_number = f.stp_number
			--where lgh_number = @lgh_hdrnumber2
			--and stp_type = 'PUP'
			--and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
			---- order by stp_sequence
			--FOR XML PATH('')),1,0,'')
			--),'ºçº' , '<br>' ) ,'El segmento no tiene evento carga de mencancias PICKUP <br>')
			isnull(replace( (STUFF(( 

			select distinct 

																			
			case when replace(isnull(f.cmd_code,''),'|','') not in (select cmd_code from commodity where cmd_updatedby = 'SATIMPORT') then 'Codigo Producto ' +  isnull(f.cmd_code,'') + '<b style='+''''+'color:red;'+''''+'>Nno valido en Catalogo SAT^</b>'  + '<br>'  else  'Codigo Producto ' + isnull(f.cmd_code,'') + ' OK'        end     +   'ºçº' +                                                                                                                        
																		       

		   case  isnull(replace(f.ivd_description,'|',''),'NA')   when  'Na' then  '<b style='+''''+'color:red;'+''''+'> Des no valida^ºç</b>'  + '<br>'   when null then '<b style='+''''+'color:red;'+''''+'>Des no valida^</b>'  + '<br>'  else  ' Descripcion Ok' end   +   'ºçº' +                                                                                                                         
																		      
		   case cast(isnull(f.ivd_count,0) as int)  when 0  then 'Cantidad mercancia ' + cast(f.ivd_count as varchar(20)) + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'   when null then '<b style='+''''+'color:red;'+''''+'> Cantidad Mercancia no valida^</b>'  + '<br>'    else ' Cantidad Mercancia OK' end     +   'ºçº' +                                                                                        
																	          
		   case when replace(isnull(f.ivd_countunit,''),'|','') not in (select abbr from labelfile where labeldefinition = 'CountUnits' and param1 = 'SATIMPORT') then 'Clave unidad ' + f.ivd_countunit + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'  else ' Clave Unidad Ok' end +      'ºçº' +                                                                                                                                 
																	         																         
		   isnull(' Volumen: ' + isnull(cast(replace(isnull(f.ivd_volume,0),0,'') as varchar(10)),'No incuido pero no mandatorio'), 'Volumen no incluido pero no mandatorio') +     'ºçº'  
                                                                                                               
		   +case cast (isnull(ivd_wgt,0) as int) when 0 then 'Cantidad Mercancia no valida'  else ' Cantidad Mercancia OK' end 		  +     'ºçº' 
                                                                         
		from invoicedetail f where ivh_hdrnumber = @num_factura and cht_itemcode = 'DEL' and ivd_wgt > 0
		FOR XML PATH('')),1,0,'')
	),'ºçº' , '\n' ),'No tiene mercancia <br>')


			+ 


			case when tractorprofile.trc_licnum  ='UNKNOWN' then 'Placas Tractor '+ trc_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 when tractorprofile.trc_licnum  =''        then 'Placas Tractor '+ trc_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 when tractorprofile.trc_licnum  IS NULL    then 'Placas Tractor '+ trc_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 else 'Placas Tractor ' + trc_number + ' OK' end + '<br>' + 


			case when  trl1.trl_licnum ='UNKNOWN' then 'Placas Trailer '+ trl1.trl_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 when  trl1.trl_licnum =''        then 'Placas Trailer '+ trl1.trl_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 when  trl1.trl_licnum IS NULL    then 'Placas Trailer '+ isnull(trl1.trl_number,'NULA') + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 else 'Placas Trailer ' + trl1.trl_number+ ' OK' end + '<br>'+
		 
		 
		 
				 case when  trl2.trl_licnum ='UNKNOWN' and trl2.trl_number <> 'UNKNOWN' then 'Placas Trailer '+ trl2.trl_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 when  trl2.trl_licnum =''  and trl2.trl_number <> 'UNKNOWN'       then 'Placas Trailer '+ trl2.trl_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 when  trl2.trl_licnum IS NULL   and trl2.trl_number <> 'UNKNOWN' then 'Placas Trailer '+ isnull(trl2.trl_number,'NULA') + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
				 else 'Placas Trailer ' + trl2.trl_number+ ' OK' end + '<br>'
		 
		 
		
		 
				  + 
		 

	
				case when 
		
				(
		 			case when tractorprofile.trc_type1 = 'THORT' 
			then 'C' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3))  
			else 'T' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3)) +

				case when trl2.trl_number = 'UNKNOWN' then  'S' +
				cast( replace(isnull(trl1.trl_axles,2),0,2)  as varchar(3))  
	
				else  
				'S' +
				cast(isnull(replace(2,0,2),2) as varchar(3)) + 'R' +
				cast(isnull(replace(trl1.trl_axles,0,2),2) + isnull(trl2.trl_axles,2) as varchar(3))
				end
			end )                                                                  
		
				like '%0%' then '<b style='+''''+'color:red;'+''''+'> Verificar ejes o asiganción correcta de  tractor,dolly, y cajas - Configuracion vehicular invalida^</b>'  else 'Configuracion vehicular OK ' end

	
				+ 

					case when tractorprofile.trc_type1 = 'THORT' 
			then 'C' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3))  
			else 'T' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3)) +

				case when trl2.trl_number = 'UNKNOWN' then  'S' +
				cast( replace(isnull(trl1.trl_axles,2),0,2)  as varchar(3))  
	
				else  
				'S' +
				cast(isnull(replace(2,0,2),2) as varchar(3)) + 'R' +
				cast(isnull(replace(trl1.trl_axles,0,2),2) + isnull(trl2.trl_axles,2) as varchar(3))
				end
			end                                                                   
				   + '<br>' +


			case when isnull(len((select mpp_misc4 from company where cmp_id =  orderheader.ord_billto)),0) > 3 then 
			'Se declara seguro de carga del cliente: ' + isnull((select isnull(cmp_misc4,'') from company where cmp_id =  orderheader.ord_billto),'') + '<br>'+ 
			'con poliza #: ' + isnull((select cmp_misc5 from company where cmp_id =  orderheader.ord_billto),'')  else ''  end + '<br>' + 




			case when mpp_id  ='UNKNOWN' then 'Operador ' + mpp_id  +'<b style='+''''+'color:red;'+''''+'> no valido^</b>'  + '<br>'  else 'Operador ' + mpp_id + ' OK' end + '<br>'+ 
			case when len(isnull(REPLACE(mpp_misc3,'|',''),'')) < 12 then 'Longitud 12 caracteres RFC Operador ' +  mpp_id + ' ' + mpp_misc3 + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'  else 'Longitud RFC operador ' + mpp_id + ' OK'  end + '<br>' +
			--case when isnumeric( right(mpp_misc3,1)) = 0  then 'RFC Operador ' +  mpp_id  + ' ' + mpp_misc3 +  '  no valido ult digito homoclave no numerico^' else 'RFC operador ' + mpp_id + ' OK'  end + char(13)+
			case when len(isnull(REPLACE(mpp_licensenumber,'|',''),'')) <8  then 'Licencia Operador ' +  mpp_id + '<b style='+''''+'color:red;'+''''+'> no valido^</b>'  + '<br>' 
				 when len(isnull(REPLACE(mpp_licensenumber,'|',''),'')) = null  then 'Licencia Operador ' +  mpp_id + '<b style='+''''+'color:red;'+''''+'> no valido^</b>'  + '<br>' 
			 else 'Licencia operador ' + mpp_id + ' OK' end + '<br>'end as Mensaje


		from invoiceheader
		left join manpowerprofile      on invoiceheader.ivh_driver           = manpowerprofile.mpp_id
		left join orderheader          on invoiceheader.ord_hdrnumber         = orderheader.ord_hdrnumber
		left join tractorprofile       on invoiceheader.ivh_tractor           = tractorprofile.trc_number
		left join trailerprofile trl1  on invoiceheader.ivh_trailer   = trl1.trl_id
		left join trailerprofile trl2  on invoiceheader.ivh_trailer2       = trl2.trl_id
		--left join trailerprofile dolly on invoiceheader.ivh_dolly             = dolly.trl_number
		left join company billcmp      on orderheader.ord_billto          = billcmp.cmp_id
		--CLAUSULA WHERE EL numero de invoice SEA IGUAL AL PARAMETRO DEL SP
		where ivh_hdrnumber = @num_factura ) as q

end

ELSE
begin
*/
select replace(Mensaje,'^','') as Mensaje, case when Mensaje like '%^%' then 'Error' else 'OK' end as Validacion from (


select 

  case when 
      (select count(Folio) from VISTA_Carta_Porte where  Serie = 'TDRXP' and LegNum = @lgh_hdrnumber) >=1 then '<br> <br> ****Ya existe un CFDI Complemento Carta Porte Generado 
	                                                                                       para el número de segmento '+ '<b style='+''''+'color:black;'+''''+'>' + @lgh_hdrnumber+ ' </b> *****'  + '<br>'+  
	                                                                                       '<br>' + 
																						  '<b style='+''''+'color:red;'+''''+'> Si el viaje se segmento con otra unidad/operador es necesario
																						   ingresar el número del nuevo segmento y cancelar el CFDI previo. ^</b>' 
  else

   
   case when len(isnull((select replace(replace(cmp_taxid,'|',''),'-','') from company where cmp_id = orderheader.ord_billto),'')) < 11 then '<br> <br> El RFC del Billto' + orderheader.ord_billto +'<b style='+''''+'color:red;'+''''+'> no correcto len(13) ^</b>'  else '<br> <br> RFC Billto '+ + orderheader.ord_billto +' OK' end + '<br>'+
   case when convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) = 0 then  '<b style='+''''+'color:red;'+''''+'>El monto a facturar del viaje es 0 no puede generarse comprobante en 0 (totalchage0)^</b>' else 'Monto Factura Orden Ok'  end + '<br>'+

   case when (select cmp_zip from company where cmp_id = cmp_id_rstart)  is null then 'El codigo postal del origen del viaje ' + isnull(cmp_id_rstart,'')  + '<b style='+''''+'color:red;'+''''+'> no valido^</b>'  else 'CP Origen viaje ' + isnull(cmp_id_rstart,'') + '  Zip OK' end + '<br>'+
   case when (select municipio from satcpcat where cp = (select cmp_zip from company where cmp_id = cmp_id_rstart))  is null then 'El codigo de municipio del origen del viaje ' + isnull(cmp_id_rstart,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>' else 'CP Origen ' + isnull(cmp_id_rstart,'') + ' Municipio OK' end + '<br>'+
   case when (select estado from satcpcat where cp = (select cmp_zip from company where cmp_id = cmp_id_rstart))  is null then 'El codigo de estado del origen del viaje ' + isnull(cmp_id_rstart,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>'else 'CP Origen ' +  isnull(cmp_id_rstart,'') +' Estado OK' end + '<br>' +  




   replace( (STUFF(( 

	select 
	
   (select 
	 case when (cmp_zip)  is null then 'El codigo postal de ' + isnull(cmp_id,'')  + '<b style='+''''+'color:red;'+''''+'> es invalido(null)^</b>' else 'CP para ' + isnull(cmp_id,'') + ' Zip OK no es nulo' end  +'ºçº' +
	 case when len(cmp_zip) < 5 then 'El codigo postal de ' + isnull(cmp_id,'')  + '<b style='+''''+'color:red;'+''''+'> con longitud no valida^</b>' else 'CP para ' + isnull(cmp_id,'') + ' Zip OK longitud' end  +'ºçº' +
	 case when (select municipio from satcpcat where cp = cmp_zip)  is null then 'El codigo de municipio  para ' + isnull(cmp_id,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>' else 'CP para ' + isnull(cmp_id,'') +' Municipio OK' end +'ºçº'  +                                                   
     case when (select estado from satcpcat where cp = cmp_zip)  is null then 'El codigo de estado para ' + isnull(cmp_id,'') +  '<b style='+''''+'color:red;'+''''+'> no es valido^</b>' else 'CP para ' + isnull(cmp_id,'')  + ' Estado OK' end  +'ºçº' 
	from company where company.cmp_id = stops.cmp_id) 
	
	
	  +
	

   	case when (select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')

	     from company where company.cmp_id = stops.cmp_id) is null then 'RFC locación '+ isnull(stops.cmp_id,'') + ' es nulo, Se usara RFC de facturación cliente'

		  when (select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')

	     from company where company.cmp_id = stops.cmp_id) = '' then  'RFC locación '+ isnull(stops.cmp_id,'') + ' en blanco, Se usara RFC facturación cliente'

		 when len((select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')

	     from company where company.cmp_id = stops.cmp_id))  < 12 then  'El RFC de '+ isnull(stops.cmp_id,'') + '<b style='+''''+'color:red;'+''''+'> tiene una longitud no valida^</b>'

		 else ''

		 end   +     'ºçº'  														         
                                                                         
	
                                                 
	                                                                                                             
	from stops 
	left join company on company.cmp_id = stops.cmp_id
	where lgh_number = @lgh_hdrnumber
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	and stp_type <> 'NONE'
	order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'<br>')   + 



	

	case when (select sum(case stp_lgh_mileage when 0 then 0.01 when '-1' then 0.01 else stp_lgh_mileage  end)                                                                                                            
	from stops 
	where lgh_number = @lgh_hdrnumber
	and stp_sequence <> 1
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')) <= 0 then 'Los kms facturables a recorrer en el segmento ' + @lgh_hdrnumber + '<b style='+''''+'color:red;'+''''+'> no son validos^</b>'  else 'Kms segmento ' + @lgh_hdrnumber + ' OK' end + '<br>'+

	' Distancia Header Segmento:' + casT( (select cast(sum (case when stp_lgh_mileage = 0 then 0.01  when stp_lgh_mileage IS NULL  
    then 0.01  when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage) end)   as varchar(20))                                                                                                               
    from stops 
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_type = 'DRP'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')) as varchar(20))+  '<br>'+ 


	case when 	(select SUM(fgt_weight) 
	from freightdetail where stp_number in  (select stp_number from stops where stp_type  ='PUP'  and lgh_number= @lgh_hdrnumber))  <= 0 then 'Peso del segmento ' + @lgh_hdrnumber + '<b style='+''''+'color:red;'+''''+'> no valido^</b>' else 'Peso segmento ' + @lgh_hdrnumber + ' Ok' end  + '<br>'+ 


	

	
 isnull(replace( (STUFF(( 

	select distinct 

																			
	case when replace(isnull(f.cmd_code,''),'|','') not in (select cmd_code from commodity where cmd_updatedby = 'SATIMPORT') then 'Codigo Producto ' +  isnull(f.cmd_code,'') + '<b style='+''''+'color:red;'+''''+'>Nno valido en Catalogo SAT^</b>'  + '<br>'  else  'Codigo Producto ' + isnull(f.cmd_code,'') + ' OK'        end     +   'ºçº' +                                                                                                                        
																		       

   case  isnull(replace(f.fgt_description,'|',''),'NA')   when  'Na' then  '<b style='+''''+'color:red;'+''''+'> Des no valida^ºç</b>'  + '<br>'   when null then '<b style='+''''+'color:red;'+''''+'>Des no valida^</b>'  + '<br>'  else  ' Descripcion Ok' end   +   'ºçº' +                                                                                                                         
																		      
   case cast(isnull(f.fgt_count,0) as int)  when 0  then 'Cantidad mercancia ' + cast(f.fgt_count as varchar(20)) + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'   when null then '<b style='+''''+'color:red;'+''''+'> Cantidad Mercancia no valida^</b>'  + '<br>'    else ' Cantidad Mercancia OK' end     +   'ºçº' +                                                                                        
																	          
   case when replace(isnull(f.fgt_countunit,''),'|','') not in (select abbr from labelfile where labeldefinition = 'CountUnits' and param1 = 'SATIMPORT') then 'Clave unidad ' + f.fgt_countunit + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'  else ' Clave Unidad Ok' end +      'ºçº' +                                                                                                                                 
																	         																         
   isnull(' Volumen: ' + isnull(cast(replace(isnull(f.fgt_volume,0),0,'') as varchar(10)),'No incuido pero no mandatorio'), 'Volumen no incluido pero no mandatorio') +     'ºçº'  +
                                                                                                               
   case when (select  isnull(SUM(fgt_weight),0) from freightdetail r where f.cmd_code =r.cmd_code and  stp_number in  (select stp_number from stops where stp_type  ='PUP'  and lgh_number= @lgh_hdrnumber))  = 0  then '<b style='+''''+'color:red;'+''''+'> Cantidad Mercancia no valida^</b>'  + '<br>'     else ' Cantidad Mercancia OK' end 		  +     'ºçº'  														         
                                                                         
	from stops
	left join freightdetail f on stops.stp_number = f.stp_number
	where lgh_number = @lgh_hdrnumber
	and stp_type = 'PUP'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	-- order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' , '<br>' ) ,'El segmento no tiene evento carga de mencancias PICKUP <br>')


	+ 


	case when tractorprofile.trc_licnum  ='UNKNOWN' then 'Placas Tractor '+ trc_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     when tractorprofile.trc_licnum  =''        then 'Placas Tractor '+ trc_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
		 when tractorprofile.trc_licnum  IS NULL    then 'Placas Tractor '+ trc_number + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     else 'Placas Tractor ' + trc_number + ' OK' end + '<br>' + 


	case when  trl1.trl_licnum ='UNKNOWN' AND  tractorprofile.trc_type1 <> 'THORT' then 'Placas Trailer '+ trl1.trl_id + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     when  trl1.trl_licnum ='' AND  tractorprofile.trc_type1 <> 'THORT'       then 'Placas Trailer '+ trl1.trl_id + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     when  trl1.trl_licnum IS NULL AND  tractorprofile.trc_type1 <> 'THORT'    then 'Placas Trailer '+ isnull(trl1.trl_id,'NULA') + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     else 'Placas Trailer ' + trl1.trl_id+ ' OK' end + '<br>'+
		 
		 
		 
		 case when  trl2.trl_licnum ='UNKNOWN' and trl2.trl_id <> 'UNKNOWN' then 'Placas Trailer '+ trl2.trl_id + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     when  trl2.trl_licnum =''  and trl2.trl_id <> 'UNKNOWN'       then 'Placas Trailer '+ trl2.trl_id + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     when  trl2.trl_licnum IS NULL   and trl2.trl_id <> 'UNKNOWN' then 'Placas Trailer '+ isnull(trl2.trl_id,'NULA') + '<b style='+''''+'color:red;'+''''+'> no validas^</b>'
	     else 'Placas Trailer ' + trl2.trl_id+ ' OK' end + '<br>'
		 
		 
		
		 
		  + 
		 

	
		case when 
		
		(
		 	case when tractorprofile.trc_type1 = 'THORT' 
	then 'C' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3))  
	else 'T' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3)) +

		case when trl2.trl_number = 'UNKNOWN' then  'S' +
		cast( replace(isnull(trl1.trl_axles,2),0,2)  as varchar(3))  
	
		else  
		'S' +
		cast(isnull(replace(dolly.trl_axles,0,2),2) as varchar(3)) + 'R' +
		cast(isnull(replace(trl1.trl_axles,0,2),2) + isnull(trl2.trl_axles,2) as varchar(3))
		end
	end )                                                                  
		
		like '%0%' then '<b style='+''''+'color:red;'+''''+'> Verificar ejes o asiganción correcta de  tractor,dolly, y cajas - Configuracion vehicular invalida^</b>'  else 'Configuracion vehicular OK ' end

	
		+ 

			case when tractorprofile.trc_type1 = 'THORT' 
	then 'C' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3))  
	else 'T' + cast(replace(isnull(trc_axles,3),0,3) as varchar(3)) +

		case when trl2.trl_number = 'UNKNOWN' then  'S' +
		cast( replace(isnull(trl1.trl_axles,2),0,2)  as varchar(3))  
	
		else  
		'S' +
		cast(isnull(replace(dolly.trl_axles,0,2),2) as varchar(3)) + 'R' +
		cast(isnull(replace(trl1.trl_axles,0,2),2) + isnull(trl2.trl_axles,2) as varchar(3))
		end
	end                                                                   
		   + '<br>' +


	case when isnull(len((select mpp_misc4 from company where cmp_id =  orderheader.ord_billto)),0) > 3 then 
	'Se declara seguro de carga del cliente: ' + isnull((select isnull(cmp_misc4,'') from company where cmp_id =  orderheader.ord_billto),'') + '<br>'+ 
	'con poliza #: ' + isnull((select cmp_misc5 from company where cmp_id =  orderheader.ord_billto),'')  else ''  end + '<br>' + 




	case when mpp_id  ='UNKNOWN' then 'Operador ' + mpp_id  +'<b style='+''''+'color:red;'+''''+'> no valido^</b>'  + '<br>'  else 'Operador ' + mpp_id + ' OK' end + '<br>'+ 
    case when len(isnull(REPLACE(mpp_misc3,'|',''),'')) < 12 then 'Longitud 12 caracteres RFC Operador ' +  mpp_id + ' ' + mpp_misc3 + '<b style='+''''+'color:red;'+''''+'> no valida^</b>'  + '<br>'  else 'Longitud RFC operador ' + mpp_id + ' OK'  end + '<br>' +
	--case when isnumeric( right(mpp_misc3,1)) = 0  then 'RFC Operador ' +  mpp_id  + ' ' + mpp_misc3 +  '  no valido ult digito homoclave no numerico^' else 'RFC operador ' + mpp_id + ' OK'  end + char(13)+
	case when len(isnull(REPLACE(mpp_licensenumber,'|',''),'')) <8  then 'Licencia Operador ' +  mpp_id + '<b style='+''''+'color:red;'+''''+'> no valido^</b>'  + '<br>' 
	     when len(isnull(REPLACE(mpp_licensenumber,'|',''),'')) = null  then 'Licencia Operador ' +  mpp_id + '<b style='+''''+'color:red;'+''''+'> no valido^</b>'  + '<br>' 
	 else 'Licencia operador ' + mpp_id + ' OK' end + '<br>'end as Mensaje

                   


--OBTECION DE DATOS DE LA TABLA LEGHEADER

from legheader
left join manpowerprofile      on legheader.lgh_driver1           = manpowerprofile.mpp_id
left join orderheader          on legheader.ord_hdrnumber         = orderheader.ord_hdrnumber
left join tractorprofile       on legheader.lgh_tractor           = tractorprofile.trc_number
left join trailerprofile trl1  on legheader.lgh_primary_trailer   = trl1.trl_id
left join trailerprofile trl2  on legheader.lgh_primary_pup       = trl2.trl_id
left join trailerprofile dolly on legheader.lgh_dolly             = dolly.trl_number
left join company billcmp      on orderheader.ord_billto          = billcmp.cmp_id


--CLAUSULA WHERE EL SEGMENTO SEA IGUAL AL PARAMETRO DEL SP
where lgh_number = @lgh_hdrnumber

) as q
--end
GO
