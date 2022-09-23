SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO














/*
Insert into vTTSTMW_Header
select  * from VISTA_TMW_Header */
/* select  * from VISTA_TMW_Header  where IVH_BILLTO = 'SLMFORW' ivh_invoicenumber = 'TQR003151'*/
/****** Object:  vTTSTMW_Header  Script Date: 02/04/09 2:02:14 PM ******/

CREATE VIEW   [dbo].[VISTA_TMW_Header_new]
    AS   
  SELECT ivh_billto,
	ivh_shipper,
	ivh_consignee,
	serie = '',
	ivh_revtype1,
	ivh_user_id2,
	ivh_invoicenumber,
	invoiceheader.ivh_printdate,
	extra1 = ord_number,
	mov_number,
	ivh_remark = isnull(ivh_remark, '') ,
	ivh_ref_number  =isnull(ivh_ref_number, '') ,
	ivh_terms,
	ivh_tractor,
	ivh_trailer,
	lastname  = (select  max(mpp_lastname) from manpowerprofile where mpp_id = ivh_driver),
	firstname =  (select max(mpp_firstname) from manpowerprofile where mpp_id = ivh_driver),
	licensenumber = (select max(mpp_licensenumber) from manpowerprofile where mpp_id = ivh_driver),
	tractor_licnum = (select max(trc_licnum) from tractorprofile where trc_number = ivh_tractor),
	trailer_licnum    = (select max(trl_licnum) from trailerprofile where trl_number = ivh_trailer),
	comprobante = ivh_applyto,
	ivd_descripcion = (select MAX(ivd_description) from invoicedetail where ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
			cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN' /* AND ivd_quantity >0 */),


	ivh_totalcharge = abs(ivh_totalcharge),
	ivh_taxamount1 = abs(ivh_taxamount1),
	ivh_taxamount2 = abs(ivh_taxamount2),
	ivh_creditmemo,
	ciudad_origen  = (select rand_city + ' ' + rand_state from city where cty_code =  ivh_origincity),
	ciudad_destino = (select rand_city + ' ' + rand_state from city where cty_code =  ivh_destcity),
	moneda = ivh_currency,
	extra2 = ivh_mbnumber,
	peso_estimado = ivh_totalweight,
	cmp_id = A.cmp_id,
	rfc = REPLACE(replace(isnull(A.cmp_taxid,''), ' ' , ''), '-', ''),
	calle = A.cmp_address1,
	ext =  isnull(A.cmp_misc1, ''),
	interior = isnull(A.cmp_misc2, ''),
	colonia = isnull(A.cmp_address2, ''),
	municipio =  case  A.cmp_address3
	when '' then  B.cty_name
	when null then B.cty_name 
	else isnull(A.cmp_address3, B.cty_name)  end ,
	ciudad = B.cty_name,
	estado = (select upper(stc_state_desc) from statecountry where stc_state_c = B.cty_state),
	pais = isnull(A.cmp_country, ''),
	A.cmp_zip,
	A.cmp_name,
	email_address = (select  isnull(max(email_address),'') from companyemail
	where   A.cmp_id = companyemail.cmp_id),
	ce_phone1  =(select isnull(max(ce_phone1),'')  from companyemail
	where   A.cmp_id = companyemail.cmp_id),
	A.cmp_revtype1,
	contact_name  =(select isnull(max(contact_name),'')  from companyemail
	where   A.cmp_id = companyemail.cmp_id),
	rfc_origen = REPLACE(isnull(C.cmp_taxid,''),'-',''),
	calle_origen = isnull(C.cmp_address1, ''),
	ext_origen = isnull(C.cmp_misc1,''),
	interior_origen = isnull(C.cmp_misc2, ''),
	colonia_origen = isnull(C.cmp_address2,''),
--	municipio_origen = isnull(C.cmp_address3,D.cty_name),
	municipio_origen =  case  C.cmp_address3
	when '' then  D.cty_name
	when null then D.cty_name 
	else  isnull(C.cmp_address3,D.cty_name) end ,
	cd_origen = D.cty_name,
	edo_origen = D.cty_state,
	pais_origen = isnull(C.cmp_country, ''),
	zip_origen = isnull(C.cmp_zip, ''),
	name_origen = isnull(C.cmp_name, ''),
	email_address_origen = (select  isnull(max(email_address), '') from companyemail
	where   C.cmp_id = companyemail.cmp_id),
	ce_phone1_origen  =(select isnull(max(ce_phone1), '')  from companyemail
	where   C.cmp_id = companyemail.cmp_id),
	revtype1_origen = C.cmp_revtype1,
	contact_name_origen  =(select isnull(max(contact_name), '')  from companyemail
	where   C.cmp_id = companyemail.cmp_id),
	rfc_destino = isnull(E.cmp_taxid, ''),
	calle_destino = isnull(E.cmp_address1, ''),
	ext_destino = isnull(E.cmp_misc1, ''),
	interior_destino= isnull(E.cmp_misc2, ''),
	colonia_destino= isnull(E.cmp_address2, ''),
	municipio_destino = isnull(E.cmp_address3, F.cty_name),
	cd_destino = isnull(F.cty_name, ''),
	edo_destino= isnull(F.cty_state, ''),
	pais_destino = left(isnull(E.cmp_country, ''),15),
	ZIP_destino = left(isnull(E.cmp_zip, ''),6),
	NAME_destino = isnull(E.cmp_name, ''),
	email_address_destino = (select  isnull(max(email_address), '') from companyemail
	where   E.cmp_id = companyemail.cmp_id),
	ce_phone1_destino  =(select isnull(max(ce_phone1), '')  from companyemail
	where   E.cmp_id = companyemail.cmp_id),
	revtype1_destino = isnull(E.cmp_revtype1, ''),
	contact_name_destino  =(select isnull(max(contact_name), '')  from companyemail
	where   E.cmp_id = companyemail.cmp_id),
	referencia_factura = '',
	fecha_wfactura = convert( datetime,'01/01/1900 01:00'),
	archivo_tif = 0,
	mast_inv = rtrim( convert(char,ivh_mbnumber) )+ ivh_invoicenumber
From 	invoiceheader,  company A, city B,
company C, city D,
company E, city F
WHERE  --invoiceheader.ivh_invoicestatus = 'PRN'  and
--Convert(varchar,ivh_printdate,112) > dateadd(day,-1,getdate()) and
--A.cmp_taxid is not null and
Substring(ivh_invoicenumber,1,1) <> 'T' and
ivh_billto  <> 'SAE'  AND
ivh_mbnumber = 0 and
A.cmp_city = B.cty_code and
A.cmp_id   = ivh_billto AND
C.cmp_city = D.cty_code and
C.cmp_id   = ivh_shipper AND
E.cmp_city = F.cty_code and
E.cmp_id   = ivh_consignee

/*
UNION
  SELECT F.ivh_billto,
	ivh_shipper,
	ivh_consignee,
	serie = '',
	ivh_revtype1,
	ivh_user_id2,
	ivh_invoicenumber = F.ivh_invoicenumber ,
	fecha = CASE 
         WHEN F.ivh_billto  = 'KRAFT' THEN ivh_billdate
         WHEN F.ivh_billto <> 'KRAFT' THEN invoiceheader.ivh_printdate
        END,	
	F.ord_number,
	mov_number = CASE 
         WHEN F.ivh_mbnumber = 0 THEN mov_number
         WHEN F.ivh_mbnumber > 0 THEN F.ivh_mbnumber 
        END,
	ivh_remark = isnull(ivh_remark , ''),
	ivh_ref_number =isnull(ivh_ref_number , ''),
	'', --ivh_terms,
	'', --ivh_tractor,
	'', --ivh_trailer,
	lastname  = '', --(select  max(mpp_lastname) from manpowerprofile where mpp_id = ivh_driver),
	firstname =  '', --(select max(mpp_firstname) from manpowerprofile where mpp_id = ivh_driver),
	licensenumber = '', --(select max(mpp_licensenumber) from manpowerprofile where mpp_id = ivh_driver),
	tractor_licnum = '', --(select max(trc_licnum) from tractorprofile where trc_number = ivh_tractor),
	trailer_licnum = '' , --(select max(trl_licnum) from trailerprofile where trl_number = ivh_trailer),
	comprobante = ivh_applyto,
	ivd_descripcion = (select MAx(ivd_description) from invoicedetail where ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
			cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN'  ),

	ivh_totalcharge = abs(F.ivh_totalcharge),
	ivh_taxamount1 = abs(F.ivh_taxamount1),
	ivh_taxamount2 = abs(F.ivh_taxamount2),
	ivh_creditmemo,
	ciudad_origen  = (select cty_name + ' ' + isnull(rand_state,'')  from city where cty_code =  ivh_origincity),
	ciudad_destino =  (select isnull(cty_name + ' ' + rand_state,'') from city where cty_code =  ivh_destcity),
	moneda = ivh_currency,
	masterbill = F.ivh_mbnumber,
	peso_estimado = ivh_totalweight,
	cmp_id = A.cmp_id,
	rfc = Replace(replace(isnull(A.cmp_taxid,''), ' ' , ''), '-', ''),
	calle = isnull(A.cmp_address1, ''),
	ext = isnull(A.cmp_misc1, ''),
	interior = isnull(A.cmp_misc2, ''),
	colonia = isnull(A.cmp_address2, ''),
	municipio =  case  A.cmp_address3
	when '' then  B.cty_name
	when null then B.cty_name 
	else isnull(A.cmp_address3, B.cty_name)  end ,

	ciudad = isnull(B.cty_name, ''),
	estado =(select  upper(stc_state_desc) from statecountry where stc_state_c = B.cty_state),
	pais =  A.cmp_country ,
	A.cmp_zip,
	A.cmp_name,
	email_address = (select  isnull(max(email_address), '') from companyemail
	where   A.cmp_id = companyemail.cmp_id),
	ce_phone1  =(select isnull(max(ce_phone1), '')  from companyemail
	where   A.cmp_id = companyemail.cmp_id),
	A.cmp_revtype1,
	contact_name  =(select isnull(max(contact_name), '')  from companyemail
	where   A.cmp_id = companyemail.cmp_id),
	rfc_origen = isnull(C.cmp_taxid, ''),
	calle_origen = isnull(C.cmp_address1, ''),
	ext_origen = isnull(C.cmp_misc1, ''),
	interior_origen = isnull(C.cmp_misc2, ''),
	colonia_origen = isnull(C.cmp_address2, ''),
--	municipio_origen = isnull(C.cmp_address3, D.cty_name),
	municipio_origen =  case  C.cmp_address3
	when '' then  D.cty_name
	when null then D.cty_name 
	else  isnull(C.cmp_address3,D.cty_name) end ,
	cd_origen = isnull(D.cty_name, ''),
	edo_origen = isnull(D.cty_state, ''),
	pais_origen = isnull(C.cmp_country, ''),
	ZIP_origen =  isnull(C.cmp_zip, ''),
	NAME_origen = isnull(C.cmp_name, ''),
	email_address_origen = (select  isnull(max(email_address), '') from companyemail
	where   C.cmp_id = companyemail.cmp_id),
	ce_phone1_origen  =(select isnull(max(ce_phone1), '')  from companyemail
	where   C.cmp_id = companyemail.cmp_id),
	revtype1_origen = C.cmp_revtype1,
	contact_name_origen  =(select isnull(max(contact_name), '')  from companyemail
	where   C.cmp_id = companyemail.cmp_id),
	rfc_destino = replace(isnull(E.cmp_taxid, ''), '-', ''),
	calle_destino = isnull(E.cmp_address1, ''),
	ext_destino = isnull(E.cmp_misc1, ''),
	interior_destino= isnull(E.cmp_misc2, ''),
	colonia_destino=  isnull(E.cmp_address2, ''),
	municipio_destino = isnull(E.cmp_address3, G.cty_name),
	cd_destino = isnull(G.cty_name, ''),
	edo_destino= isnull(G.cty_state, ''),
	pais_destino = left(isnull(E.cmp_country, ''),15),
	ZIP_destino =  isnull(E.cmp_zip, ''),
	NAME_destino = isnull(E.cmp_name, ''),
	email_address_destino = (select  isnull(max(email_address), '') from companyemail
	where   E.cmp_id = companyemail.cmp_id),
	ce_phone1_destino  =(select isnull(max(ce_phone1), '')  from companyemail
	where   E.cmp_id = companyemail.cmp_id),
	revtype1_destino = E.cmp_revtype1,
	contact_name_destino  =(select isnull(max(contact_name),'')  from companyemail
	where   E.cmp_id = companyemail.cmp_id),
	referencia_factura = '',
	fecha_wfactura = convert( datetime,'01/01/1900 01:00'),
	archivo_tif = 0,
	mast_inv = Rtrim(Convert(char, F.ivh_mbnumber)) + F.ivh_invoicenumber
From 	invoiceheader, vTTSTMW_FirstREg  F 
,  company A, city B,
company C, city D,
company E, city G
WHERE  invoiceheader.ivh_invoicenumber  = F.ivh_invoicenumber  and
--invoiceheader.ivh_totalcharge > 0 and
Convert(varchar,invoiceheader.ivh_printdate,112) >='20100801' AND
--A.cmp_taxid is not null and
F.ivh_mbnumber = invoiceheader.ivh_mbnumber  and
A.cmp_city = B.cty_code and
A.cmp_id   = invoiceheader.ivh_billto AND
C.cmp_city = D.cty_code and
C.cmp_id   = ivh_shipper AND
E.cmp_city = G.cty_code and
E.cmp_id   = ivh_consignee
*/































































GO
