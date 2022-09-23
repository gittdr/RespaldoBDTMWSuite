SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






















--
/* 

select 'H|000|'+ ltrim(convert(char,total)) +'|'+serie+'|' + ltrim(convert(char, subtotal)) +'|'
from VISTA_dfe_Header    
insert into    dfe..comprobante
Select * from VISTA_dfe_Header    where invoice = '107493'
*/
CREATE                                   VIEW   [dbo].[VISTA_dfe_Header]   
    AS   
  SELECT   
	version = '2.0',
	serie =  Case  ivh_creditmemo
	when 'N' then  'TDR'
	when 'Y' then 'NC' end ,
	llave = '',
	fecha = invoiceheader.ivh_printdate,
 	sello = '',
	anoaprobacion = 2009,
	noaprobacion = 38954,
	nocertificado =	'00001000000100680279' ,
	condiciones = '',
 	subtotal = abs(ivh_totalcharge) - ivh_taxamount1 + abs(ivh_taxamount2),
	descuento = 0,
	motivo = '',
	forma = 'PAGO EN UNA SOLA EXHIBICION',
	metodos_pago = '' ,
	tipo_comprobante =  case  ivh_creditmemo
	when 'N' then  'INGRESO'
	when 'Y' then 'EGRESO'
	end ,
	total = abs(ivh_totalcharge),
	ivh_taxamount  = abs(ivh_taxamount2),	
	imp2 = ABS(ivh_taxamount1),
	usuario = ivh_user_id2,
	fecha_genera = invoiceheader.ivh_printdate,
	invoice = ivh_invoicenumber,
	norder = ord_number,
	movimiento = mov_number,
	ivh_ref_number = isnull(ivh_ref_number, ''),
	ivh_remark= isnull(ivh_remark, '') ,
	ivh_descripcion = isnull((select MAX(ivd_description) from invoicedetail where ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
			cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN' ), ''),
	ivh_tractor = ivh_tractor,
	ivh_trailer = ivh_trailer ,
	tractor_licnum = (select max(trc_licnum) from tractorprofile where trc_number = ivh_tractor),
	trailer_licnum    = (select max(trl_licnum) from trailerprofile where trl_number = ivh_trailer),		
	lastname  = (select  max(mpp_lastname) from manpowerprofile where mpp_id = ivh_driver),
	firstname =  (select max(mpp_firstname) from manpowerprofile where mpp_id = ivh_driver),
	licensenumber = (select max(mpp_licensenumber) from manpowerprofile where mpp_id = ivh_driver),	
	ciudad_origen  = (select rand_city + ' ' + rand_state from city where cty_code =  ivh_origincity),
	ciudad_destino = (select rand_city + ' ' + rand_state from city where cty_code =  ivh_destcity),
	moneda =  case  ivh_currency
	when 'MX$' then  'MX'
	ELSE 'US'
	end ,
	
	masterbill = ivh_mbnumber,
	peso_estimado = ivh_totalweight,
	rfc = 'TTR931201KJ6',
	empresa = 'TDR Transportes, S.A. de C.V.' ,
	calle = 'Av. México',
	ext = '10',
	interior = '',
	colonia = 'Palo Alto',
	municipio = 'El Marques',
	localidad = 'El Marques',
	estado = 'Queretaro',
	pais = 'México',
	codigopostal = '76240',
	rfcr = REPLACE(replace(isnull(A.cmp_taxid,''), ' ' , ''), '-', ''),
	nombrereceptor = A.cmp_name,
	caller = ltrim(A.cmp_address1),
	extr = left( isnull(A.cmp_misc1, ''),10),
	interiorr = left(isnull(A.cmp_misc2, ''),10),
	coloniar = ltrim(isnull(A.cmp_address2, '')),
	localidadr =  case  A.cmp_address3
	when '' then  B.cty_name
	when null then B.cty_name 
	else isnull(A.cmp_address3, B.cty_name)  end ,		
	municipior =  case  A.cmp_address3
	when '' then  B.cty_name
	when null then B.cty_name 
	else isnull(A.cmp_address3, B.cty_name)  end ,
	/*ciudadr = B.cty_name,*/
	estador = (select stc_state_desc from statecountry where stc_state_c = B.cty_state),
	paisr = isnull(A.cmp_country, ''),
	A.cmp_zip,

	rfc_origen = REPLACE(isnull(C.cmp_taxid,''),'-',''),
	calle_origen = isnull(C.cmp_address1, ''),
	ext_origen = left(isnull(C.cmp_misc1, ''),10),
	interior_origen = left(isnull(C.cmp_misc2, ''),10),
	colonia_origen = isnull(C.cmp_address2,''),
	municipio_origen =  case  C.cmp_address3
	when '' then  D.cty_name
	when null then D.cty_name 
	else  isnull(C.cmp_address3,D.cty_name) end ,
	cd_origen = D.cty_name,
	edo_origen = D.cty_state,
	pais_origen = isnull(C.cmp_country, ''),
	zip_origen = left(isnull(C.cmp_zip, ''),6),
	name_origen = isnull(C.cmp_name, ''),
	rfc_destino = isnull(E.cmp_taxid, ''),
	calle_destino = isnull(E.cmp_address1, ''),
	ext_destino = left(isnull(E.cmp_misc1, ''),10),
	interior_destino= left(isnull(E.cmp_misc2, ''),10),
	colonia_destino= isnull(E.cmp_address2, ''),
	municipio_destino = isnull(E.cmp_address3, F.cty_name),
	cd_destino = isnull(F.cty_name, ''),
	edo_destino = (select stc_state_desc from statecountry where stc_state_c = F.cty_state),
	pais_destino = isnull(E.cmp_country, ''),
	ZIP_destino =left( isnull(E.cmp_zip, ''),6),
	NAME_destino = isnull(E.cmp_name, ''),
	archivo_tif = ' ',
	archivo_pdf = '',
	archivo_xml = '' ,
	estatus = 1,
	parcialidad = 0,	
	fecha_cancela= convert( datetime,'01/01/1900 01:00'),
	tasa_iva = (select isnull(max(ivd_rate),0)  from  invoicedetail A
		where  A.ivh_hdrnumber  =  ivh_hdrnumber and
		     A.ivd_charge  > 0 and
		     A.cht_itemcode = 'GST'),
	tasa_ret = (select  abs(isnull(max(ivd_rate),0))   from  invoicedetail A
		where  A.ivh_hdrnumber  =  ivh_hdrnumber and
		     A.ivd_charge <> 0  and
		     A.cht_itemcode = 'PST')/*,
	cadena = '',

	fletes  = (select  	abs(isnull(max(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber  =  invoiceheader.ivh_hdrnumber and
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge > 0  and 
			  UPPER(cht_description) like '%VIAJE%' ), 
	
	seguro = (select  	abs(isnull(max(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber  =  invoiceheader.ivh_hdrnumber and
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  UPPER(cht_description) like '%SEGURO%' ), 
	autopistas = (select  	abs(isnull(max(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber  =  invoiceheader.ivh_hdrnumber and
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  (UPPER(cht_description) like '%TRANS%' OR
			 UPPER(cht_description)  like  '%AUTOP%' )), 	

	cpac = (select  	abs(isnull(max(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber  =  invoiceheader.ivh_hdrnumber and
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  UPPER(cht_description) ='COSTO AJUSTE COMBUSTIBLE' ), 
	otros = (select  	abs(isnull(max(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber  =  invoiceheader.ivh_hdrnumber and
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			(  UPPER(cht_description) <> 'COSTO AJUSTE COMBUSTIBLE' and
			   A.cht_itemcode NOT IN ( 'PST','GST' )  and
			  left(UPPER(cht_description),5) not in ('VIAJE', 'SEGUR', 'TRANS', 'AUTOP', 'MANIO' )) ),
	maniobras = (select  	abs(isnull(max(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber  =  invoiceheader.ivh_hdrnumber and
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  UPPER(cht_description) like '%MANIOBRA%' ),
	  monto_pesos = ivh_archarge	 */
From 	invoiceheader,  company A, city B,
company C, city D,
company E, city F
where   invoiceheader.ivh_invoicestatus = 'PRN'  and
Convert(varchar,ivh_printdate,112) > dateadd(day,-1,getdate()) and
Substring(ivh_invoicenumber,1,1) <> 'T' and
ivh_billto  <> 'SAE'  AND
ivh_mbnumber = 0 and
A.cmp_city = B.cty_code and
A.cmp_id   = ivh_billto AND
C.cmp_city = D.cty_code and
C.cmp_id   = ivh_shipper AND
E.cmp_city = F.cty_code and
E.cmp_id   = ivh_consignee



/* MASTER */
UNION 
  SELECT   
	version = '2.0',
	serie =  Case  ivh_creditmemo
	when 'N' then  'TDR'
	when 'Y' then 'NC' end ,
	llave = '',
	fecha = invoiceheader.ivh_printdate,
 	sello = '',
	ano = 2009,
	aprobacion = 38954,
	nocertificado =	'00001000000100680279' ,
	condiciones = '',
 	subtotal = abs(F.ivh_totalcharge) - F.ivh_taxamount1 + abs(F.ivh_taxamount2),
	descuento = 0,
	motivo = '',
	forma = 'PAGO EN UNA SOLA EXHIBICION',
	metodos_pago = '' ,
	tipo_comprobante =  case  ivh_creditmemo
	when 'N' then  'INGRESO'
	when 'Y' then 'EGRESO'
	end ,
	total = abs(F.ivh_totalcharge),
	ivh_taxamount  = abs(F.ivh_taxamount2),	
	imp2 = ABS(F.ivh_taxamount1),
	usuario = ivh_user_id2,
	fecha_genera =  CASE 
         WHEN F.ivh_billto  = 'KRAFT' THEN ivh_billdate
         WHEN F.ivh_billto <> 'KRAFT' THEN invoiceheader.ivh_printdate
        END,	 
	invoice = F.ivh_invoicenumber ,
	norder = f.ord_number,
	mov_number = CASE 
         WHEN F.ivh_mbnumber = 0 THEN mov_number
         WHEN F.ivh_mbnumber > 0 THEN F.ivh_mbnumber 
        END,
	ivh_ref_number = isnull(ivh_ref_number, ''),
	ivh_remark= isnull(ivh_remark, '') ,
	ivh_descripcion = isnull((select MAX(ivd_description) from invoicedetail where ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
			cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN' ), ''),
	tractor = ivh_tractor,
	trailer = ivh_trailer ,
	tractor_licnum = (select max(trc_licnum) from tractorprofile where trc_number = ivh_tractor),
	trailer_licnum    = (select max(trl_licnum) from trailerprofile where trl_number = ivh_trailer),	
	
	lastname  = (select  max(mpp_lastname) from manpowerprofile where mpp_id = ivh_driver),
	firstname =  (select max(mpp_firstname) from manpowerprofile where mpp_id = ivh_driver),
	licensenumber = (select max(mpp_licensenumber) from manpowerprofile where mpp_id = ivh_driver),
	
	ciudad_origen  = (select  cty_name + ' ' + isnull(rand_state,'')  from city where cty_code =  ivh_origincity),
	ciudad_destino =  (select isnull(cty_name + ' ' + rand_state,'') from city where cty_code =  ivh_destcity),
	
	moneda =  case  ivh_currency
	when 'MX$' then  'MX'
	ELSE 'US'
	end ,
	masterbill = F.ivh_mbnumber,
	peso_estimado = ivh_totalweight,
	rfc = 'TTR931201KJ6',
	empresa = 'TDR Transportes, S.A. de C.V.' ,
	calle = 'Av. México',
	ext = '10',
	interior = '',
	colonia = 'Palo Alto',
	municipio = 'El Marques',
	localidad = 'El Marques',
	estado = 'Queretaro',
	pais = 'México',
	zip = '76240',

	rfc = Replace(replace(isnull(A.cmp_taxid,''), ' ' , ''), '-', ''),
	A.cmp_name,
	calle = ltrim(isnull(A.cmp_address1, '')),
	ext = left(isnull(A.cmp_misc1, ''),10),
	interior = left(isnull(A.cmp_misc2, ''),10),
	colonia = ltrim(isnull(A.cmp_address2, '')),
	municipio =  case  A.cmp_address3
	when '' then  B.cty_name
	when null then B.cty_name 
	else isnull(A.cmp_address3, B.cty_name)  end ,
	ciudad = isnull(B.cty_name, ''),
	estado = (select stc_state_desc from statecountry where stc_state_c = B.cty_state),
	pais =  A.cmp_country ,
	left(A.cmp_zip,6),
	
	rfc_origen = REPLACE(isnull(C.cmp_taxid,''),'-',''),
	calle_origen = isnull(C.cmp_address1, ''),
	ext_origen = left(isnull(C.cmp_misc1,''),10),
	interior_origen = left(isnull(C.cmp_misc2, ''),10),
	colonia_origen = isnull(C.cmp_address2,''),
	municipio_origen =  case  C.cmp_address3
	when '' then  D.cty_name
	when null then D.cty_name 
	else  isnull(C.cmp_address3,D.cty_name) end ,
	cd_origen = D.cty_name,
	edo_origen = (select stc_state_desc from statecountry where stc_state_c = D.cty_state),
	pais_origen = left(isnull(C.cmp_country, ''),15),
	zip_origen = left(isnull(C.cmp_zip, ''),6),
	name_origen = isnull(C.cmp_name, ''),
	rfc_destino = isnull(E.cmp_taxid, ''),
	calle_destino = isnull(E.cmp_address1, ''),
	ext_destino = left(isnull(E.cmp_misc1, ''),10),
	interior_destino= left(isnull(E.cmp_misc2, ''),10),
	colonia_destino= isnull(E.cmp_address2, ''),
	municipio_destino = isnull(E.cmp_address3, G.cty_name),
	cd_destino = isnull(G.cty_name, ''),
	edo_destino= (select stc_state_desc from statecountry where stc_state_c = G.cty_state),
	pais_destino = left(isnull(E.cmp_country, ''),15),
	ZIP_destino = left(isnull(E.cmp_zip, ''),6),
	NAME_destino = isnull(E.cmp_name, ''),
	archivo_tif = ' ',
	archivo_pdf = '',
	archivo_xml = '' ,
	estatus = 1,
	parcialidad = 0,	
	fecha_cancela= convert( datetime,'01/01/1900 01:00'),
	tasa_iva = (select isnull(max(ivd_rate),0)  from  invoicedetail A
		where  A.ivh_hdrnumber  =  ivh_hdrnumber and
		     A.ivd_charge  > 0 and
		     A.cht_itemcode = 'GST'),
	tasa_ret = (select  abs(isnull(max(ivd_rate),0))   from  invoicedetail A
		where  A.ivh_hdrnumber  =  ivh_hdrnumber and
		     A.ivd_charge <> 0  and
		     A.cht_itemcode = 'PST')/*,
	cadena = '',

	fletes = (select  	abs(isnull(SUM(ivd_charge ),0))  
		 from  invoicedetail A,  chargetype  
			where  A.ivh_hdrnumber   in (
		select ivh_hdrnumber   from   invoiceheader
		where  ivh_mbnumber = F.ivh_mbnumber)    and 
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge > 0  and			 
			  UPPER(cht_description) like '%VIAJE%' ) ,
 
	
	seguro = (select  	abs(isnull(SUM(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber   in (
	select ivh_hdrnumber   from   invoiceheader
	where  ivh_mbnumber = F.ivh_mbnumber)    and 
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  UPPER(cht_description) like '%SEGURO%' ), 

	autopistas = (select  	abs(isnull(SUM(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber     in (
	select ivh_hdrnumber   from   invoiceheader
	where  ivh_mbnumber = F.ivh_mbnumber)    and 
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  (UPPER(cht_description) like '%TRANS%' OR
			 UPPER(cht_description)  like	'%AUT0PISTA%') ), 

	cpac = (select  	abs(isnull(SUM(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber     in (
	select ivh_hdrnumber   from   invoiceheader
	where  ivh_mbnumber = F.ivh_mbnumber)    and 
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  UPPER(cht_description) ='COSTO AJUSTE COMBUSTIBLE' ), 
	otros = (select  	abs(isnull(sum(ivd_charge ),0))  
		 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber    in (
		select ivh_hdrnumber   from   invoiceheader
		where  ivh_mbnumber = F.ivh_mbnumber)   and 
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			 ( UPPER(cht_description) <> 'COSTO AJUSTE COMBUSTIBLE' and
			   A.cht_itemcode NOT IN ( 'PST','GST' )  and
			 left(UPPER(cht_description),5) not in ('VIAJE', 'SEGUR', 'TRANS', 'AUT0P', 'MANIO')) ),

	maniobras = (select  abs(isnull(SUM(ivd_charge ),0))  
	 from  invoicedetail A,  chargetype
		where  A.ivh_hdrnumber   in (
		select ivh_hdrnumber   From   invoiceheader
		where  ivh_mbnumber = F.ivh_mbnumber)  and 
		 A.cht_itemcode  =   chargetype.cht_itemcode   AND 
		     A.ivd_charge <> 0  and 
			  UPPER(cht_description) like '%MANIOBRA%' ),
	Monto_pesos = F.monto_pesos*/
From 	invoiceheader, vTTSTMW_FirstREg  F,
company A, city B,
company C, city D,
company E, city G
WHERE  invoiceheader.ivh_invoicenumber  = F.ivh_invoicenumber  and
Convert(varchar,invoiceheader.ivh_printdate,112) >='20100601' AND
--F.ivh_billto  <> 'SAE'  AND
F.ivh_mbnumber = invoiceheader.ivh_mbnumber  and
A.cmp_city = B.cty_code and
A.cmp_id   = invoiceheader.ivh_billto AND
C.cmp_city = D.cty_code and
C.cmp_id   = ivh_shipper AND
E.cmp_city = G.cty_code and
E.cmp_id   = ivh_consignee























GO
