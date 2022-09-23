SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Fecha: 15 Jun 2021 10:17 hrs
Version 1.0

Stored Proc que arma la cadena para formar el txt
de uan carta porte desarrolado con base al layout  Carta porte V3 de Tralix

Recibe como parametro el numero de de legheader
dado que en una orden segmentado son varios los recursos involucrados.


Sentencia de prueba



exec sp_compCartaPorte 1212152

exec sp_compCartaPorte 799031

select lgh_primary_pup, * from legheader where lgh_number = '1190299'
select * from trailerprofile where trl_numbeR = 'UNKNOWN'


*/

CREATE proc [dbo].[sp_compCartaPortev1]  @lgh_hdrnumber varchar(20)

as


Select

--SECION HEADER (1:1)

    '01'                                                                                                             --1 Tipo de Registro   (R)
																		       +'|'+ 
    'TDRXP' + cast(legheader.lgh_number  as varchar(20))                                                             --2 Version  (R)
																	           +'|'+     
    'TDRXP'                                                                                                          --3 Serie (R)     
																	           +'|'+     
    cast(legheader.lgh_number  as varchar(20))                                                                       --4 Folio Num  (R)
																	           +'|'+     
	isnull(replace(format(GETDATE(),'yyyy/MM/dd hh:mm:ss'),'|',''),'')                                               --5 Fecha (R)     
																	           +'|'+     
																		      
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) as varchar(20))			                     --6 Subtotal (R) 
	                                                                           +'|'+    
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*.16,0)) as varchar(20)) 						     --7 Total imp trasladado
																		       +'|'+    
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*.04,0)) as varchar(20)) 							  --8 Total imp retenido
                                                                               +'|'+   
	''																										     	 --9 Descuentos																		     
																		       +'|'+     
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*1.12,0)) as varchar(20)) 	                     --10 Total
																		       +'|'+     
    REPLACE(REPLACE(dbo.NumeroEnLetra(ROUND((abs(isnull(orderheader.ord_totalcharge*1.12,0))), 0, 1))	 + 
	(CASE isnull(orderheader.ord_currency,'M.N') WHEN 'MX$' THEN ' PESOS' ELSE ' DOLARES' END) + ' ' +
	CAST((((ROUND((abs(isnull(orderheader.ord_totalcharge*1.12,0))), 2)))) - (ROUND((abs(isnull(isnull(orderheader.ord_totalcharge*1.12,0),0))), 0, 1)) AS varchar) 
    + ' /100 ' + (CASE isnull(orderheader.ord_currency,'M.N') WHEN 'MX$' THEN 'M.N.' ELSE 'DLS' END), '0.', ''), '	', '')		 
	                                                                                                                 --11 Total con letra	
	    																       +'|'+     
    isnull(replace(billcmp.cmp_misc3,'|',''), '99')                                                         	     --12 Forma de Pago
																		       +'|'+     
    
	rtrim
                             (
							 isnull(
							 (SELECT             replace(PYMTRMID,'|','')
                                 FROM            [172.24.16.113].TDR.DBO.RM00101
                                 WHERE        custnmbr = orderheader.ord_billto)
								,    (SELECT      replace(PYMTRMID,'|','')
                                 FROM            [172.24.16.113].CNVOY.DBO.RM00101
                                 WHERE        custnmbr = orderheader.ord_billto)       
								 )
								 )     																			     --13 Condiciones de pago
															                   +'|'+     
    isnull(replace(billcmp.cmp_misc5,'|',''), 'PPD')                                 							      --14 Metodo de Pago
																		       +'|'+     
    (CASE orderheader.ord_currency WHEN 'MX$' THEN 'MXN' ELSE 'USD' END)											 --15 Moneda
																	           +'|'+     
    (CASE 
		  WHEN (orderheader.ord_currency = 'UNK') THEN '1' 
		  WHEN (orderheader.ord_currency = 'MX$') THEN '1' 
		  WHEN (orderheader.ord_currency = 'US$') THEN
                             (SELECT        cast(round(cex_rate, 2) AS varchar(20))
                               FROM            currency_exchange(nolock)
                               WHERE        cex_date =
                                                             (SELECT        max(cex_Date)
                                                               FROM            currency_exchange(nolock))) WHEN orderheader.ord_currency = 'USDOLLAR' THEN
                             (SELECT        cast(round(cex_rate, 2) AS varchar(20))
                               FROM            currency_exchange(nolock)
                               WHERE        cex_date =
                                                             (SELECT        max(cex_Date)  FROM            currency_exchange(nolock))) 
															   
	END)	                                                                                                         --16 Tipo de Cambio
																		       +'|'+     
    'I'																										     	 --17 Tipo de Comprobante
																		       +'|'+     
    '76240'																										     --18 Lugar Expedicion   
																		       +'|'+     
    isnull(replace(billcmp.cmp_misc6,'|',''), 'G03')															     --20 Tipo gasto
																		       +'|'+     
    ''																										     	 --21 Etiqueta Documento

																		       +'|'+     
  
                                                                               + '\n' +

--SECION RECEPTOR (1:1)

    '02'                                                                                                             --1 Tipo de Registro   (R)
																		       +'|'+ 
    isnull((select replace(cmp_id,'|','') from company where cmp_id = orderheader.ord_billto),'')                    --2 ID Cliente  (R)
																	           +'|'+     
    isnull((select replace(replace(cmp_taxid,'|',''),'-','') from company where cmp_id = orderheader.ord_billto),'')  --3 RFC (R)     
																	           +'|'+     
    isnull((select replace(cmp_name,'|','') from company where cmp_id = orderheader.ord_billto),'')                  --4 Nombre Receptor (R)
																	           +'|'+     
																	           +'|'+  
	isnull((select replace(cmp_address1,'|','') from company where cmp_id = orderheader.ord_billto),'')              --5 Calle (R)     
																	           +'|'+   
																	           +'|'+       
																		      
    isnull((select replace(cmp_misc1,'|','') from company where cmp_id = orderheader.ord_billto),'')                 --5 Numero (R)   
	                                                                           +'|'+   
    isnull((select replace(cmp_address2,'|','') from company where cmp_id = orderheader.ord_billto),'')              --6 Colonia (R)  																			     
																		       +'|'+  
																		       +'|'+  
    isnull((select replace(isnull(cmp_address1,'') + isnull(cmp_address2,''),'|','') 
	from company where cmp_id = orderheader.ord_billto),'')                                                         --6 Direccion (R)  	 
                                                                               +'|'+     
    isnull((select replace((select stc_state_desc from  statecountry
	 where stc_State_c = cmp_state),'|','') from company where cmp_id = orderheader.ord_billto),'')                  --7 Localidad (R)  
																		       +'|'+     
    rtrim(isnull((select replace((select stc_state_alt from statecountry where stc_state_c = cmp_state),'|','') 
	from company where cmp_id = orderheader.ord_billto),'')  )                                                        --8 Estado (R)  
	                                                                           +'|'+  
																			   
    isnull((select replace(cmp_zip  ,'|','') from company where cmp_id = orderheader.ord_billto),'')                 --9 CP (R)     
																		       +'|'+    
                                                                               +'|'+     
																		       +'|'+   
                                                                               +'|'+   

                                                                               + '\n' +

----SECCION 04 (1:1)

    '04'                                                                                                             --1 Tipo de Registro   (R)
																		       +'|'+ 
    '1'                                                                                                              --2 ConsecutivoConcepto  (R)
																	           +'|'+     
    '78101800'                                                                                                       --3 Cod SAT  (R)     
																	           +'|'+    
    'Viaje-FLETE'                                                                                                    --4 Descripcion (R)   
																	           +'|'+     
    '1'                                                                                                              --5 Cantidad  (R)     
																	           +'|'+  
    'E54'                                                                                                            --6 Actividad  (R)     
																	           +'|'+   
    'Viaje'                                                                                                          --7 Id Producto (R) 
																	           +'|'+    
    'Viaje (Tarifa Fija)'                                                                                            --8 Producto (R)   
																	           +'|'+     
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) as varchar(20))                               --9 Subtotal  (R)     
																	           +'|'+  
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) as varchar(20))                               --10 Total  (R)     
																	           +'|'+   
    ''                                                                                                               --11 Vacio (R) 
																	           +'|'+   
                                                                               + '\n' +

----SECCION 041 Impuesto trasladado (1:1)

    '041'                                                                                                           --1 Tipo de Registro   (R)
																		       +'|'+ 
    '1'                                                                                                             --2 Cantidad  (R)
																	           +'|'+     
    '002'                                                                                                           --3 Cod Impuesto  (R)     
																	           +'|'+    
    'Tasa'                                                                                                          --4 Tipo (R)   
																	           +'|'+     
    '0.160000'                                                                                                      --5 % Impuesto (R)     
																	           +'|'+     
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*.16,0)) as varchar(20))                          --6 Monto Impuesto  (R)     
																	           +'|'+  
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) as varchar(20))                              --7 Base para Impuesto  (R)     
																	           +'|'+   
                                                                               + '\n' +

----SECCION 041 Impuesto retenido (1:1)

    '042'                                                                                                           --1 Tipo de Registro   (R)
																		       +'|'+ 
    '1'                                                                                                             --2 Cantidad  (R)
																	           +'|'+     
    '002'                                                                                                           --3 Cod Impuesto  (R)     
																	           +'|'+    
    'Tasa'                                                                                                          --4 Tipo (R)   
																	           +'|'+     
    '0.040000'                                                                                                      --5 % Impuesto (R)     
																	           +'|'+     
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*.04,0)) as varchar(20))                          --6 Monto Impuesto  (R)     
																	           +'|'+  
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge,0)) as varchar(20))                              --7 Base para Impuesto  (R)     
																	           +'|'+   
                                                                               + '\n' +


----SECCION 06 Impuesto trasladado (1:1)

    '06'                                                                                                            --1 Tipo de Registro   (R)
																	           +'|'+     
    '002'                                                                                                           --2 Cod Impuesto  (R)     
																	           +'|'+    
    'Tasa'                                                                                                          --3 Tipo (R)   
																	           +'|'+     
    '0.160000'                                                                                                      --4 % Impuesto (R)     
																	           +'|'+     
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*.16,0)) as varchar(20))                          --5 Monto Impuesto  (R)     
																	           +'|'+   
                                                                               + '\n' +
----SECCION 07 Impuesto Retenido (1:1)

    '07'                                                                                                            --1 Tipo de Registro   (R)
																	           +'|'+     
    '002'                                                                                                           --2 Cod Impuesto  (R)     
																	           +'|'+     
    '0.040000'                                                                                                      --3 % Impuesto (R)     
																	           +'|'+     
    cast(convert(decimal (10,2),isnull(orderheader.ord_totalcharge*.04,0)) as varchar(20))                          --4 Monto Impuesto  (R)     
																	           +'|'+   
                                                                               + '\n' +



----SECCION 08 ETIQUETA ORIGEN Y DESTINO(1:1)

	replace( (STUFF(( 

	select 
	'08'                                                                                                               --1 Tipo de Registro
																				+'|'+ 
    case when stp_Type = 'PUP' then 'Domicilio Origen'  else  'Domicilio Destino'    end                               --2 Etiqueta (R)
																	            +'|'+     
   (select rtrim(isnull(replace(cmp_address1,'|',''),'')) +',' + rtrim(isnull(replace(cmp_address2,'|',''),'')) +
	rtrim(isnull(replace(cmp_address3,'|',''),'')) +',' + 
	rtrim(isnull(replace(cty_nmstct,'|',''),'')) + ','+rtrim(isnull(replace(cmp_country,'|',''),''))+',' + 
	'(Cp:'+rtrim(isnull(replace(cmp_zip,'|',''),'')) + ' ' +
	'Mun:'+ isnull((select municipio from satcpcat where cp = cmp_zip),'') + ' ' +                                                   
    'Edo:' + isnull((select estado from satcpcat where cp = cmp_zip),'')+')'  
	from company where company.cmp_id = stops.cmp_id)                                                                  --3 Valor   
																	            +'|'+ 
	'ºçº'                                                                                                               --Wildcard para despues remplazar por salto de linea
	from stops 
	left join company on company.cmp_id = stops.cmp_id
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_type <> 'NONE'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n')
	                                                                             +


----SECCION CARTA PORTE GENERAL(1:1)

    'CP_GEN'                                                                                                         --1 Tipo de Registro   (R)
																		       +'|'+ 
    '1.0'                                                                                                            --2 Version  (R)
																	           +'|'+     
    'No'                                                                                                             --3 Transporte Internacional  (R)     
																	           +'|'+   
																			     
	''	                                                                       +'|'+                                 --4 Entrada o Salida de Mercancia al pais  (O)
					                                                                                                 
	''	                                                                       +'|'+ 								 --5 Via de Entrada/salida  (O)  ---> catCartaPorte:c_CveTransporte
					                                                                                                
	
   (select cast(sum (case when stp_lgh_mileage = 0 then 0.00  when stp_lgh_mileage IS NULL  
    then 0.0  when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage) end)   as varchar(20))                                                                                                               
    from stops 
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_type = 'DRP'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y'))
																   
	                                                                           +'|'+ 								 --6 Total Distancia Recorrida  (O)
                                                                             
																			   + '\n'   +


    



----SECCION CARTA PORTE UBICACIÓN (1:N)  
----STUFF RECURSIVO DEDE LA TABLA DE STOPS
	replace( (STUFF(( 

	select 

	'CP_UBQ'                                                                                                           --1 Tipo de Registro
																	            +'|'+ 
    isnull(replace(stops.cmp_id+CAST( stp_sequence  as varchar(3)),'|',''),'')                                         --2 Identificador Ubicación
																	            +'|'+ 
   ''                                                                                                                  --3 Tipo de Estacion/ Solo ferreo
																	            +'|'+ 																														

    case when (CAST( case when stp_lgh_mileage = 0 then 0.00  when stp_lgh_mileage IS NULL 
	 then 0.01 when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage)
	  end  as varchar(20)) = '0.00') then '0.01'else   
	  CAST( case when stp_lgh_mileage = 0 then 0.00  when stp_lgh_mileage IS NULL 
	 then 0.01 when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage)
	  end  as varchar(20))   end                                                                                        --4 Distancia Recorrida
																	            +'|'+ 
	'ºçº'                                                                                                               --Wildcard para despues remplazar por salto de linea
	from stops 
	left join company on company.cmp_id = stops.cmp_id
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	and stp_type <> 'NONE'
	order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n')
	
		
																	             + 

----SECCION CARTA PORTE UBICACIÓN ORIGEN/DESTINO (0:1)

replace( (STUFF(( 

	select 

	case when stp_type = 'PUP' then 'CP_UBQ_ORG'  
	     when stp_type = 'DRP' then 'CP_UBQ_DST'
		                       else 'CP_UBQ_DST'   end                                                                  --1 Tipo de Registro
																	            +'|'+ 
    isnull(replace(stops.cmp_id+CAST( stp_sequence  as varchar(3)),'|',''),'')                                         --2 Consecutivo Ubicación
																	            +'|'+ 	
	case when ( select COUNT(*) from stops
	left join freightdetail f on stops.stp_number = f.stp_number
	where stp_type = 'DRP' and stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')) <=2 then '' else																																															
	case when stp_type = 'PUP'  then 'OR'+ CAST(stp_sequence as varchar(3)) + RIGHT(rtrim(CAST(stp_number as VARchar(10))),5) else
	'DE'+CAST(stp_sequence as varchar(3))+ RIGHT(rtrim(CAST(stp_number as VARchar(10))),5) end  
	end                                                                                                                 --4 ID ubicación SAT
																	            +'|'+ 
	case when cmp_taxid =  isnull((select replace(replace(cmp_taxid,'|',''),'-','') 
	from company where cmp_id = orderheader.ord_billto),'') then ''
	else
	isnull((select replace(replace(isnull(cmp_taxid,''),'|',''),'-','')
	from company where company.cmp_id = stops.cmp_id),'') end 	                                                        --5 RFC Remitente /destinatario
																	            +'|'+ 
    isnull((select replace(isnull(replace(cmp_name,'¨',''),''),'|','') 
	from company where company.cmp_id = stops.cmp_id),'')                                                               --6 Nombre remitente/ destinatario
																	            +'|'+ 
	''				                                                                                                	--7 Num Registro Trib remitente/destinatario
																	            +'|'+ 
	''		                                                                                                            --8 Residencia Fisica remitente/destinatario
																	            +'|'+
	''																												    --9 Numero de Estacion
																	            +'|'+
	''																													--10 Nombre Estacion
																	            +'|'+
	''																													--11 Navegacion Traf maritimo
																	            +'|'+ 
	isnull(replace(format(stops.stp_arrivaldate,'yyyy-MM-ddThh:mm:ss'),'|',''),'')                                      --12 Fecha Hora salida/llegada
																	            +'|'+ 
	''                                                                                                                  --13 Tipo Estacion / solo ferreo
																	            +'|'+ 
     case when (CAST( case when stp_lgh_mileage = 0 then 0.00  when stp_lgh_mileage IS NULL 
	 then 0.01 when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage)
	  end  as varchar(20)) = '0.00') then '0.01'else   
	  CAST( case when stp_lgh_mileage = 0 then 0.00  when stp_lgh_mileage IS NULL 
	 then 0.01 when stp_lgh_mileage =  '-1' then 0.01 else convert(decimal(10,2),stp_lgh_mileage)
	  end  as varchar(20))   end                                                                                        --14 Distancia Recorrida
																	            +'|'+ 
	'ºçº'                                                                                                               --Wildcard para despues remplazar por salto de linea
	from stops 
	left join company on company.cmp_id = stops.cmp_id
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_type <> 'NONE'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n')

                                                                                              +




--SECCION CARTA PORTE UBICACIÓN DOMICILIO (0:1)
----STUFF RECURSIVO DEDE LA TABLA DE STOPS
	replace( (STUFF(( 

	select 
	'CP_UBQ_DOM'                                                                                                      --1 Tipo de Registro
																				+'|'+ 
	isnull(replace(stops.cmp_id+CAST( stp_sequence  as varchar(3)),'|',''),'')                                        --2 Identificador de la ubicación
																				+'|'+ 
	rtrim(isnull(replace(cmp_address1,'|',''),''))                                                                    --3 Calle
																	            +'|'+ 
     ''                                                                                                               --4 Número Exterior
																	            +'|'+ 
     ''                                                                                                               --5 Número Interior
																	            +'|'+ 
    (select max(c_colonia) from SATColoniasCAT where c_codigopostal = rtrim(isnull(replace(cmp_zip,'|',''),'')))      --6 Colonia
																	            +'|'+ 
    
    isnull((select localidad from satcpcat where cp = cmp_zip),'')                                                    --7 Localidad
																	            +'|'+ 
    cast(isnull(round(cast(cmp_latseconds as float)/3600,2),0.0) as varchar(20)) +','
	+ cast(isnull(round(cast(cmp_longseconds as float)/3600,2)*-1,0.0) as varchar(20))                                --8 Referencia
		
																	            +'|'+ 
    
	isnull((select municipio from satcpcat where cp = cmp_zip),'')                                                    --9 Municipio / Delegación
																	            +'|'+ 
    isnull((select estado from satcpcat where cp = cmp_zip),'')                                                      --10 Estado -->   conforme con la especificación ISO 3166-2
																	            +'|'+ 
    isnull(replace(cmp_country,'|',''),'')                                                                            --11 País  --> especificación ISO 3166-1
																	            +'|'+ 
                                                                                                                      --12 Codigo Postal
    isnull(replace(cmp_zip,'|',''),'')
																	            +'|'+ 
	'ºçº'                                                                                                             --Wildcard para despues remplazar por salto de linea
	from stops 
	left join company on company.cmp_id = stops.cmp_id
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
    and stp_type <> 'NONE'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n')

	
								
                                                                                 +

--SECCION MERCANCÍAS (1:1)

    'CP_MER'                                                                                                                                       --1 Tipo de Registro
																	        +'|'+      
   cast(
	
	(select case when SUM(fgt_weight) <= 0 then 0.01 else SUM(fgt_weight)  end 
	from freightdetail where stp_number in  (select stp_number from stops where stp_type  ='PUP'  and stops.ord_hdrnumber = orderheader.ord_hdrnumber)) 
	+
	cast(isnull(REPLACE((select cast(param2 as float) from labelfile where labeldefinition = tractorprofile.trc_type1 ) ,'|',''),8) as float)  +
	
    case when trl2.trl_number = 'UNKNOWN' then  

	cast(isnull(REPLACE((select cast(param2 as float) from labelfile where labeldefinition = trl1.trl_type1 ) ,'|',''),7) as float)
	else    
	cast(isnull(REPLACE((select cast(param2 as float) from labelfile where labeldefinition = trl1.trl_type1 ) ,'|',''),7) as float)  +     
	cast(isnull(REPLACE((select cast(param2 as float) from labelfile where labeldefinition = dolly.trl_type1) ,'|',''),3) as float)  +                                    
	cast(isnull(REPLACE((select cast(param2 as float) from labelfile where labeldefinition = trl2.trl_type1 ) ,'|',''),7) as float)  
	end 
	as varchar(20))  
	                                                                                                                                               --2 Peso Bruto Total
																	        +'|'+ 
     
     'L86'                                                                                                                                         --3 Unidad de Peso  --> catCartaPorte:c_ClaveUnidadPeso
																	        +'|'+ 


	(select case when SUM(fgt_weight) <= 0 then '0.01' else cast(SUM(fgt_weight)  as varchar(20)) end 
	from freightdetail where stp_number in  (select stp_number from stops where stp_type  ='PUP'  and stops.ord_hdrnumber = orderheader.ord_hdrnumber))                  --4 Peso Neto Total

																	        +'|'+ 
    cast(isnull((select COUNT(distinct cmd_code ) from freightdetail where cmd_code <> 'UNKNOWN' and stp_number in
	(select stp_number from stops where stp_type = 'PUP' and stops.ord_hdrnumber= (orderheader.ord_hdrnumber))),0)    as varchar(5))                                   --5 Numero Total de Mercancías
																	        +'|'+ 
     ''                                                                                                                                            --6 Cargo por Tasación
																	        +'|'+  
                                                                            + '\n'  +


--SECCION MERCANCÍA (1:N)


    replace( (STUFF(( 

	select distinct
	'CP_MER_MER'                                                                                                                                                                  --1 Tipo de Registro
																				+'|'+ 
	replace(isnull(f.cmd_code,''),'|','')                                                                                                                                         --2 Identificador de la mercancia
																				+'|'+
	replace(isnull(f.cmd_code,''),'|','')                                                                                                                                         --3 Bienes Transportados  ---> catCartaPorte:c_ClaveProdServCP
																		        +'|'+ 
     ''                                                                                                                                                                           --4 Clave Producto Catálogo STCC   ---> catCartaPorte:c_ClaveProdSTCC cuando es ferroviario (O)
																		        +'|'+ 
    isnull(replace(f.fgt_description,'|',''),'NA')                                                                                                                                 --5 Descripción
																		        +'|'+ 
   (select cast(sum(x.fgt_count) as varchar(20))  from freightdetail x where f.cmd_code = x.cmd_code and x.stp_number
	in (select stp_number from stops where stp_Type = 'PUP' and stops.ord_hdrnumber = orderheader.ord_hdrnumber))-- and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')))       --6 Cantidad
																	            +'|'+ 
    replace(isnull(f.fgt_countunit,''),'|','')                                                                                                                                     --7 Clave Unidad
																	            +'|'+ 
    replace(isnull(f.fgt_countunit,''),'|','')                                                                                                                                     --8 Unidad
																	            +'|'+ 
    cast(replace(isnull(f.fgt_volume,0),0,'') as varchar(10))                                                                                                                       --9 Dimensiones
	 																            +'|'+ 
    case when  (select replace(isnull(cmd_class,''),'|','') from commodity where commodity.cmd_code =  f.cmd_code) 
	= 'MPeligro' then 'Sí' else '' end																										                                       --10 Material Peligroso   --> si o no
																	            +'|'+ 
    case when  (select replace(isnull(cmd_class,''),'|','') from commodity where commodity.cmd_code =  f.cmd_code) 
	= 'MPeligro' then  isnull((select replace(isnull(replace(cmd_haz_class,'|',''),''),'UNK','')   from commodity where cmd_code = f.cmd_code) ,'')   else '' end	               --11 Clave Tipo Material Peligroso  ---> catCartaPorte:c_MaterialPeligroso
																	            +'|'+ 
      case when  (select replace(isnull(cmd_class,''),'|','') from commodity where commodity.cmd_code =  f.cmd_code) 
	= 'MPeligro' then 
	 isnull((select replace(isnull(replace(cmd_haz_subclass,'!',''),''),'UNK','')   from commodity where cmd_code = f.cmd_code) ,'') else '' end                                   --12 Embalaje --->   catCartaPorte:c_TipoEmbalaje
																	            +'|'+ 
       case when  (select replace(isnull(cmd_class,''),'|','') from commodity where commodity.cmd_code =  f.cmd_code) 
	 = 'MPeligro' then 
	 isnull((select isnull(replace(left([Descripción],90),'|',''),'') FROM [TMWSuite].[dbo].[SATTipoEmbalajeCAT]  where [Clave de designación] =
	  (select isnull(replace(cmd_haz_subclass,'!',''),'')   from commodity where cmd_code = f.cmd_code)),'')  else '' end                                                          --13 Descripción del Embalaje -- solo si se trata de material peligroso
																	            +'|'+ 
    (select case when SUM(isnull(fgt_weight,0)) <= 0     then '0.01' 
	             when SUM(isnull(fgt_weight,0)) IS NULL  then '0.01' else cast(SUM(isnull(fgt_weight,0))  as varchar(20)) end 
	 from freightdetail r where f.cmd_code =r.cmd_code and  stp_number in  (select stp_number from stops where stp_type  ='PUP'  and stops.ord_hdrnumber = orderheader.ord_hdrnumber)) 
	                                                                                                                                                                               --14 Peso
																	            +'|'+ 
     ''                                                                                                                                                                            --15 Valor Mercancía (O)
																	            +'|'+ 
     ''                                                                                                                                                                            --16 Moneda  --> catCFDI:c_Moneda (O)
																	            +'|'+ 
     ''                                                                                                                                                                            --17 Fracción Arancelaria    ---> catComExt:c_FraccionArancelaria /opc (O)
																	            +'|'+ 
     ''                                                                                                                                                                            --18 UUID Comercio Exterior (O)
																		        +'|'+ 
	'ºçº'                                                                                                                                                                         --Wildcard para despues remplazar por salto de linea
	from stops
	left join freightdetail f on stops.stp_number = f.stp_number
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	and stp_type = 'PUP'
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n')
						
 
                                                                                 +

--SECCION CANTIDAD TRANSPORTA (0:N)
----STUFF RECURSIVO DEDE LA TABLA DE STOPS
case when ( select COUNT(*) from stops
	left join freightdetail f on stops.stp_number = f.stp_number
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_type = 'DRP'
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')) <=2 then ''
	else

 	replace( (STUFF(( 

	select distinct
	'CP_MER_MER_CAN'                                                                                                                                                             --1 Tipo de Registro
																				+'|'+ 
	replace(f.cmd_code,'|','')                                                                                                                                                   --2 Identificador de la mercancia
																				+'|'+
	casT(isnull(cast(f.fgt_count as int),'0')  as varchar(20))                                                                                                                    --3 Cantidad
																		        +'|'+ 
    (select 'OR' +  CAST(max(stp_sequence) as varchar(3)) + RIGHT(rtrim(CAST(max(x.stp_number) as VARchar(10))),5)  from stops x
	where x.stp_type = 'PUP' and x.ord_hdrnumber = orderheader.ord_hdrnumber and x.stp_sequence < y.stp_sequence   )                                                              --4 Id Origen
																				+'|'+ 
	'DE'+ CAST(stp_sequence as varchar(3)) + RIGHT(rtrim(CAST(y.stp_number as VARchar(10))),5)                                                                                       --5 Id Destino
																				+'|'+ 
	'01'                                                                                                                                                                         --6 Clave Transporte   --> catCartaPorte:c_CveTransporte
																		        +'|'+ 
	'ºçº'                                                                                                                                                                         --Wildcard para despues remplazar por salto de linea
	from stops y
	left join freightdetail f on y.stp_number = f.stp_number
	where y.ord_hdrnumber = orderheader.ord_hdrnumber
	and y.stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	and y.stp_type = 'DRP'
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n')

	end
						
						                                                          +

/*						
--SECCION DETALLE MERCANCÍA (1:1)


----STUFF RECURSIVO DEDE LA TABLA DE STOPS

 	replace( (STUFF(( 

	select distinct
	'CP_MER_MER_DET'                                                            --1 Tipo de Registro
																				+'|'+ 
	replace(f.cmd_code,'|','')                                                  --2 Consecutivo de la mercancia
																				+'|'+
	replace(isnull(f.fgt_weightunit,''),'|','')                                 --3 Unidad Peso
																		        +'|'+ 
	replace(isnull(f.fgt_weight,''),'|','')                                     --4 Peso Bruto
																				+'|'+ 
	replace(isnull(f.fgt_weight,''),'|','')                                     --5 Peso Neto 
																				+'|'+ 
	'0.01'                                                                      --6 Peso Tara
																		        +'|'+ 
	casT(isnull(cast(f.fgt_count as int),'0')  as varchar(20))                  --7 Numero Piezas
																		        +'|'+ 
	'ºçº'                                                                       --Wildcard para despues remplazar por salto de linea
	from stops
	left join freightdetail f on stops.stp_number = f.stp_number
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber
	and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
	-- order by stp_sequence
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,CHAR(10))													 +

--select trl_number,trl_grosswgt, trl_type1 from trailerprofile where trl_status <> 'OUT'
---select distinct trl_type1 from trailerprofile where trl_status <> 'OUT'
*/

--SECCION AUTOTRANSPORTE FEDERAL (1:1)
   
    'CP_AUT'                                                                  --1 Tipo de Registro
																	        +'|'+ 
     case when  trl2.trl_number  <> 'UNKNOWN' then  'TPAF19'
	      when  (select cmd_class from commodity
		  where commodity.cmd_code =  legheader.cmd_code)  = 'MPeligro'   then 'TPAF03' 
	   else 'TPAF01' end                                                    --2 Permiso SCT ---> catCartaPorte:c_TipoPermiso, TPAF01 carga general, TPAF19  expreso doble articulado
																	        +'|'+ 
     '2242TTR15062011021002407'                                              --3 Número Permiso SCT
																	        +'|'+ 
     'HDI seguros'                                                           --4 Nombre Aseguradora
																	        +'|'+ 
     '2264019'                                                               --5 Número de Póliza de Seguro
																	        +'|'+ 
                                                                            + '\n' +

--SECCION IDENTIFICACIÓN VEHICULAR (0:1)
   
    'CP_VEH'                                                                --1 Tipo de Registro
	--																        +'|'+ 
    -- isnull(REPLACE(trc_number,'|',''),'')                                  --2 Número Económico  
	
	
																	        +'|'+ 	 
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
	end                                                                     --X catCartaPorte:c_ConfigAutotransporte
																	        +'|'+ 
     isnull(REPLACE(trc_licnum,'|',''),'')                                  --3 Placa
																	        +'|'+ 
     isnull(REPLACE(trc_year,  '|',''),'')                                  --4 Año Modelo
																	        +'|'+ 
																			+ '\n' +
																			
--SECCION REMOLQUE (0:2) --REMOLQUE 1
   
    'CP_REM'                                 --1 Tipo de Registro
																	        +'|'+ 
     isnull(REPLACE((select param1 from labelfile where labeldefinition = trl1.trl_type1) ,'|',''),'CTR002')  --2 Subtipo de Remolque   ---> catCartaPorte:c_SubTipoRem
																	        +'|'+                                              
     isnull(REPLACE(trl1.trl_licnum,'|',''),'')                                                               --3 Placa
																	        +'|'+ 
																		    + '\n' +
--SECCION REMOLQUE (0:2) --REMOLQUE 2
    
	case when trl2.trl_number <> 'UNKNOWN' then 

    ('CP_REM'                                 --1 Tipo de Registro
																	        +'|'+ 
       isnull(REPLACE((select param1 from labelfile where labeldefinition = trl2.trl_type1) ,'|',''),'CTR002')  --2 Subtipo de Remolque   ---> catCartaPorte:c_SubTipoRem
																	        +'|'+                                              
     isnull(REPLACE(trl2.trl_licnum,'|',''),'')                                                                 --3 Placa
																	        +'|'+ 
																		    + '\n' )

	else ''
	end
	+''+



/********************INICIA POSIBLEMENTE NO REQUERIDOS*******************************

--SECCION TRANSPORTE MARíTIMO (1:N)
   
    'CP_TRA_MAR'                                 --1 Tipo de Registro
																	        +'|'+ 
     ''                                          --2 Permiso SCT  --> catCartaPorte:c_TipoPermiso
																	        +'|'+ 
     ''                                          --3 Número de Permiso SCT
																	        +'|'+ 
     ''                                          --4 Nombre Aseguradora
																	        +'|'+ 
     ''                                          --5 Número de Póliza
																	        +'|'+ 
     ''                                          --6 Tipo de Embarcación  --> catCartaPorte:c_ConfigMaritima
																	        +'|'+ 
     ''                                          --7 Matricula
																	        +'|'+ 
     ''                                          --8 Numero de IMO
																	        +'|'+ 
     ''                                          --9 Año Construcción Embarcación
																	        +'|'+ 
     ''                                          --10 Nombre Embarcación
																	        +'|'+ 
     ''                                          --11 Nacionalidad Embarcación  --> catCFDI:c_Pais
																	        +'|'+ 
     ''                                          --12 Unidades de Arqueo Bruto
																	        +'|'+ 
     ''                                          --13 Tipo de Carga  --> catCartaPorte:c_ClaveTipoCarga
																	        +'|'+ 
     ''                                          --14 Número de Certiicado ITC
																	        +'|'+ 
     ''                                          --15 Eslora
																	        +'|'+ 
     ''                                          --16 Manga
																	        +'|'+ 
     ''                                          --17 Calado
																	        +'|'+ 
     ''                                          --18 Línea Naviera
																	        +'|'+ 
     ''                                          --19 Agente Naviero
																	        +'|'+ 
     ''                                          --20 Número de Autorización Agente Naviero --> catCartaPorte:c_NumAutorizacionNaviero
																	        +'|'+ 
     ''                                          --21 Número de Viaje
																	        +'|'+ 
     ''                                          --22 Conocimiento de Embarque
																	        +'|'+ 
																		    + '\n' +

--SECCION TRANSPORTE MARíTIMO CONTENEDOR (1:N)
   
    'CP_TRA_MAR_CNT'                              --1 Tipo de Registro
																	        +'|'+ 
     ''                                           --2 Número de Contenedor
																	        +'|'+ 
     ''                                           --3 Tipo de Contenedor  --> catCartaPorte:c_ContenedorMaritimo
																	        +'|'+ 
     ''                                           --4 Número de Precinto
																	        +'|'+ 
                                                                            + '\n' +
--SECCION TRANSPORTE AEREO (1:N)
   
    'CP_TRA_AER'                                 --1 Tipo de Registro
																	        +'|'+ 
     ''                                           --2 Tipo Permiso SCT  --> catCartaPorte:c_TipoPermiso
																	        +'|'+ 
     ''                                           --3 Número de Permiso SCT
																	        +'|'+ 
     ''                                           --4 Matricula Aeronave
																	        +'|'+ 
     ''                                           --5 Nombre Aseguradora
																	        +'|'+ 
     ''                                           --6 Número de Póliza de Seguro
																	        +'|'+ 
     ''                                           --7 Número de Guia
																	        +'|'+ 
     ''                                           --8 Lugar Contrato
																	        +'|'+ 
     ''                                           --9 RFC Transportista
																	        +'|'+ 
     ''                                           --10 Código Transporista --> catCartaPorte:c_CodigoTransporteAereo
																	        +'|'+ 
     ''                                           --11 Número de Registro de Identificación Tributaria Transportista
																	        +'|'+ 
     ''                                           --12 Residencia Fiscal Transportista
																	        +'|'+ 
     ''                                           --13 Nombre Transportista
																	        +'|'+ 
     ''                                           --14 RFC Embarcador
																	        +'|'+ 
     ''                                           --15 Número de Registro de Identificación Tributaria Embarcador
																	        +'|'+ 
     ''                                           --16 Residencia Fiscal Embarcador
																	        +'|'+ 
     ''                                           --17 Nombre Embarcador
																	        +'|'+ 
																		    + '\n' +

--SECCION TRANSPORTE FERROVIARIO (0:1)
   
    'CP_TRA_FER'                                 --1 Tipo de Registro
																	        +'|'+ 
     ''                                           --2 Tipo de Servicio  --> catCartaPorte:c_TipoDeServicio
																	        +'|'+ 
     ''                                           --3 Nombre Aseguradora
																	        +'|'+ 
     ''                                           --4 Número de Poliza Seguro
																	        +'|'+ 
     ''                                           --5 Concesionario  --> tdCFDI:t_RFC_PM
																	        +'|'+ 
																		    + '\n' +
																			
--SECCION DERECHOS DE PASO (0:N)
   
    'CP_TRA_FER_DER'                              --1 Tipo de Registro
																	        +'|'+ 
     ''                                           --2 Tipo de Derecho de Paso --> catCartaPorte:c_DerechosDePaso
																	        +'|'+ 
     ''                                           --3 Kilometraje Pagado
																	        +'|'+ 
																		    + '\n' +

--SECCION CARRO FERROVIARIO (1:N)
   
    'CP_TRA_FER_CAR'                              --1 Tipo de Registro  
																	        +'|'+ 
     ''                                           --2 Identificador Único Carro
																	        +'|'+ 
     ''                                           --3 Tipo de Carro -->  catCartaPorte:c_TipoCarro
																	        +'|'+ 
     ''                                           --4 Matricula Carro
																	        +'|'+ 
     ''                                           --5 Guia Carro
																	        +'|'+ 
     ''                                           --6 Toneladas Netas Carro
																	        +'|'+ 
																		    + '\n' +

--SECCION CONTENEDORES CARROS FERROVIARIO (0:N)
   
    'CP_TRA_FER_CAR_CNT'                           --1 Tipo de Registro  
																	        +'|'+ 
     ''                                            --2 Identificador Único Carro
																	        +'|'+ 
     ''                                            --3 Tipo de Contenedor --> catCartaPorte:c_Contenedor
																	        +'|'+ 
     ''                                            --4 Peso Contenedor Vacio
																	        +'|'+ 
     ''                                            --5 Peso Neto Mercancía
																	        +'|'+ 
															                + '\n' +

--********************TERMINA POSIBLEMENTE NO REQUERIDOS**********************************/

--SECCION  FIGURA TRANSPORTE (0:1)
   
    'CP_FIG'                                       --1 Tipo de Registro
																	        +'|'+ 
     '01'                                            --2 Clave Transporte ---> catCartaPorte:c_CveTransporte 01-Autotransporte Federal
																	        +'|'+ 
																            + '\n' +

--SECCION OPERADOR (0:N)
   
    'CP_OPE'																												--1 Tipo de Registro
																	        +'|'+
     isnull(REPLACE(mpp_id,'|',''),'')																					    --2 Identificador Único Operador
																	        +'|'+
     isnull(REPLACE(mpp_misc3,'|',''),'')																				    --3 RFC Operador --> tdCFDI:t_RFC_PF
																	        +'|'+
     isnull(REPLACE(mpp_licensenumber,'|',''),'')																	        --4 Número de Licencia
																	        +'|'+
     isnull(REPLACE(mpp_lastfirst,'|',''),'')																				--5 Nombre Operador
																	        +'|'+
     ''																														--6 Número de Registro de Identificación Tributaria Operador, dejar en blanco
																	        +'|'+
     '' 																													--7 Residencia Fiscal Operador Pais catalogo c_pais  ISO 3166-1
																	        +'|'+
																            + '\n' +

--SECCION DOMICILIO OPERADOR (0:N)
   
    'CP_OPE_DOM'                                                                                                             --1 Tipo de Registro
																	        +'|'+
     isnull(REPLACE(mpp_id,'|',''),'')																						 --2 Identificador Único Operador (R)
																	        +'|'+
    'Avenida Mexico'
	-- isnull(REPLACE(mpp_address1,'|',''),'')																			     --3 Calle  (R)
																	        +'|'+
     '10'																													 --4 Número Exterior (O)
																	        +'|'+
     ''																														 --5 Número Interior (O)
																	        +'|'+
     '0282'																												     --6 Colonia (O)
																	        +'|'+
     ''																												         --7 Localidad (O)
																	        +'|'+
     ''																														 --8 Referencia (O)
																	        +'|'+
    
	+'011'
	--replicate('0', 3-LEN(rtrim(isnull(replace((select cty_comm_zone from city where cty_code =mpp_city),'|',''),'00') ))) 
	--+ rtrim(isnull(replace((select cty_comm_zone from city where cty_code =mpp_city),'|',''),'001'))					     --9 Municipio (O)
																	        +'|'+
     'QUE'															--10 Estado (R)
																	        +'|'+
     'MEX'																													--11 País (R) --> ISO 3166-1
																	        +'|'+
     '76247'
	 --isnull(REPLACE(mpp_zip,'|',''),'')																						--12 Codigo Postal (R)
																	        +'|'





--OBTECION DE DATOS DE LA TABLA LEGHEADER

from legheader
left join manpowerprofile      on legheader.lgh_driver1           = manpowerprofile.mpp_id
left join orderheader          on legheader.ord_hdrnumber         = orderheader.ord_hdrnumber
left join tractorprofile       on legheader.lgh_tractor           = tractorprofile.trc_number
left join trailerprofile trl1  on legheader.lgh_primary_trailer   = trl1.trl_number
left join trailerprofile trl2  on legheader.lgh_primary_pup       = trl2.trl_number
left join trailerprofile dolly on legheader.lgh_dolly             = dolly.trl_number
left join company billcmp      on orderheader.ord_billto          = billcmp.cmp_id


--CLAUSULA WHERE EL SEGMENTO SEA IGUAL AL PARAMETRO DEL SP
where lgh_number = @lgh_hdrnumber
GO
