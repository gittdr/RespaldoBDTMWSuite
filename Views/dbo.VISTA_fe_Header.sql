SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













CREATE VIEW [dbo].[VISTA_fe_Header]
AS
/* ********************************CASO SINGLE INVOICES*********************/ 
SELECT
 /*Información General del CFD*/ 

idcomprobante = (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END)  + '-' + cast(ivh_invoicenumber AS varchar),
serie = (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END),
folio = ivh_invoicenumber, fhemision = dateadd(MINUTE, - 11, getdate()), 

/*** seccion que alenta la vista cambiar a consultar estos datos por .net EMOLVERA 

**********termina seccion que alenta la vista************************************/
subtotal =  (SELECT        round(sum(importe), 2)                          FROM  persistente_VISTA_Fe_detail  WHERE folio = cast(ivh_invoicenumber AS varchar(20))),
imptras =   (SELECT        round(sum(iva_monto), 2)                        FROM  persistente_VISTA_Fe_detail  WHERE folio = cast(ivh_invoicenumber AS varchar(20))),
imprete =   (SELECT        round(sum(ret_monto), 2)                        FROM  persistente_VISTA_Fe_detail  WHERE folio = cast(ivh_invoicenumber AS varchar(20))),
tasatras = '0.160000', tasarete = '0.040000', coditrans = '002', codirete = '002', tipofactor = 'Tasa', descuento = '', 
total =     (SELECT        round(sum(importe + iva_monto - ret_monto), 2)  FROM   persistente_VISTA_Fe_detail  WHERE folio = cast(ivh_invoicenumber AS varchar(20))),

totalletra = REPLACE(REPLACE(dbo.NumeroEnLetra(ROUND((abs(ivh_totalcharge)), 0, 1)) 
                         + (CASE ivh_currency WHEN 'MX$' THEN ' PESOS' ELSE ' DOLARES' END) + ' ' + CAST((((ROUND((abs(ivh_totalcharge)), 2)))) - (ROUND((abs(ivh_totalcharge)), 0, 1)) AS varchar) 
                         + ' /100 ' + (CASE ivh_currency WHEN 'MX$' THEN 'M.N.' ELSE 'DLS' END), '0.', ''), '	', ''), movdesc = '', fpago = 'PAGO EN UNA SOLA EXHIBICION',
						 
						  condpago =   rtrim
                             (
							 isnull(
							 (SELECT        PYMTRMID
                                 FROM            [172.24.16.113].TDR.DBO.RM00101
                                 WHERE        custnmbr = ivh_billto)
								,    (SELECT        PYMTRMID
                                 FROM            [172.24.16.113].CNVOY.DBO.RM00101
                                 WHERE        custnmbr = ivh_billto)       
								 )
								 )   ,
								 
								 
								  /*- PARAMETRIZACION DATOS DE PREFERENCIA FACTURACION CLIENTES-------------------------------------------------*/ metpago = (CASE ivh_creditmemo WHEN 'N' THEN isnull(a.cmp_misc3, '99') 
                         WHEN 'Y' THEN isnull(a.cmp_othertype3, '99') ELSE '99' END), cuentaref = CASE WHEN invoiceheader.ivh_creditmemo = 'Y' THEN isnull
                             ((SELECT        max(uuid)
                                 FROM            [172.24.16.113].CFDI.DBO.[cfdi_detallecfdi] WITH (nolock)
                                 WHERE        folio = CAST(invoiceheader.ivh_cmrbill_link AS VARCHAR)), '') ELSE '' END, 
				      
					  
					   --  metodopago33 = (CASE ivh_creditmemo WHEN 'N' THEN isnull(a.cmp_misc5, 'PPD') WHEN 'Y' THEN isnull(a.cmp_misc4, 'PPD') ELSE 'PPD' END), 
					    --by emolvera 30nov2021 to use misc4 and misc5 for seguro de carga
						metodopago33 = 'PPD', 


                         usocfdi = (CASE ivh_creditmemo WHEN 'N' THEN isnull(a.cmp_misc6, 'G03') WHEN 'Y' THEN isnull(a.cmp_misc7, 'G02') ELSE 'G03' END), 
                         /*-----------------------------------------------------------------------------------------------------------*/ moneda = (CASE ivh_currency WHEN 'MX$' THEN ' MXN' ELSE 'USD' END), tipocambio = (CASE WHEN (ivh_currency = 'UNK' AND ivh_billto = 'WALMART') 
                         THEN '' WHEN (ivh_currency = 'MX$' AND ivh_billto = 'WALMART') THEN '' WHEN (ivh_currency = 'UNK' AND ivh_billto <> 'WALMART') THEN '1' WHEN (ivh_currency = 'MX$' AND ivh_billto <> 'WALMART') 
                         THEN '1' WHEN (ivh_currency = 'US$') THEN
                             (SELECT        cast(round(cex_rate, 2) AS varchar(20))
                               FROM            currency_exchange(nolock)
                               WHERE        cex_date =
                                                             (SELECT        max(cex_Date)
                                                               FROM            currency_exchange(nolock))) WHEN ivh_currency = 'USDOLLAR' THEN
                             (SELECT        cast(round(cex_rate, 2) AS varchar(20))
                               FROM            currency_exchange(nolock)
                               WHERE        cex_date =
                                                             (SELECT        max(cex_Date)
                                                               FROM            currency_exchange(nolock))) END), /* Información del receptor*/ idreceptor = ivh_billto, rfc = (CASE A.cmp_country WHEN 'USA' THEN 'XEXX010101000' ELSE REPLACE(replace(isnull(A.cmp_taxid, 
                         ''), ' ', ''), '-', '') END), numtributacion = CASE A.cmp_country WHEN 'USA' THEN REPLACE(replace(isnull(A.cmp_taxid, ''), ' ', ''), '-', '') ELSE '' END, /*solo caso para extranjeros*/ nombrecliente = A.cmp_name, 
                         pais = CASE WHEN A.cmp_country = 'MEXICO' THEN 'MEX' WHEN A.cmp_country = 'Mex' THEN 'MEX' ELSE A.cmp_country END, 
                         paisresidencia = CASE WHEN A.cmp_country = 'MEXICO' THEN '' WHEN A.cmp_country = 'Mex' THEN '' ELSE A.cmp_country END, calle = isnull(rtrim(ltrim(A.cmp_address1)), ''), numext = isnull(A.cmp_misc1, ''), 
                         numint = isnull(A.cmp_misc2, ''), colonia = isnull(A.cmp_address2, ''), localidad = isnull(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), ''), referencia = isnull(rtrim(ltrim(A.cmp_address1)), '') 
                         + isnull(A.cmp_address2, ''), municdeleg = CASE A.cmp_address3 WHEN '' THEN isnull(replace(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), 'CUAJIMALPA DE MORE', 
                         'CUAJIMALPA DE MORELOS'), '') WHEN NULL THEN isnull(replace(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), 'CUAJIMALPA DE MORE', 'CUAJIMALPA DE MORELOS'), '') 
                         ELSE isnull(A.cmp_address3, isnull(REPLACE(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), 'CUAJIMALPA DE MORE', 'CUAJIMALPA DE MORELOS'), '')) END, estado =
                             (SELECT        upper(stc_state_desc)
                               FROM            statecountry WITH (nolock)
                               WHERE        stc_state_c = B.cty_state), cp = A.cmp_zip, mailenvio = ISNULL(A.cmp_mailto_address1, ''), /*- Información Adicional Comprobante*/ nmaster = ivh_mbnumber, cuotaconv = '', valorcomer = '', 
                         remision = isnull
                             ((SELECT        dbo.orderheader.ord_refnum
                                 FROM            orderheader WITH (nolock)
                                 WHERE        dbo.orderheader.ord_hdrnumber = dbo.invoiceheader.ord_hdrnumber), ''), operador = isnull
                             ((SELECT        MAX(mpp_lastname)
                                 FROM            manpowerprofile WITH (nolock)
                                 WHERE        mpp_id = ivh_driver), '') + ' ' + isnull
                             ((SELECT        MAX(mpp_firstname)
                                 FROM            manpowerprofile WITH (nolock)
                                 WHERE        mpp_id = ivh_driver), ''), operadorlicenicia = isnull
                             ((SELECT        MAX(mpp_licensenumber)
                                 FROM            manpowerprofile WITH (nolock)
                                 WHERE        mpp_id = ivh_driver), ''), tractoeco = ivh_tractor, tractoplaca = isnull
                             ((SELECT        MAX(trc_licnum)
                                 FROM            tractorprofile WITH (nolock)
                                 WHERE        trc_number = ivh_tractor), ''), remolque1Eco = ivh_trailer, remolque1Placa = isnull
                             ((SELECT        MAX(trl_licnum)
                                 FROM            trailerprofile WITH (nolock)
                                 WHERE        trl_number = ivh_trailer), ''), remolque2Eco = '', remolque2Placa = '', documento = rtrim(ltrim(ivh_user_id2)), fechapagare = getdate(), interesespagare = '5%', clientepagare = A.cmp_name, control = '', 
                         hecha = rtrim(ltrim(ivh_user_id2)), revisada = '', autorizada = '', auxiliares = '', 
						 
						 origen =
                           isnull(  (SELECT        rand_city + ' ' + rand_state
                               FROM            city WITH (nolock)
                               WHERE        cty_code = ivh_origincity),''),
							   
							   
							    remitente = isnull(C.cmp_name, ''), domicilioorigen = isnull(ltrim(rtrim(C.cmp_address1)), '') + ' ' + ' ' + isnull(rtrim(ltrim(C.cmp_address2)), '') + ' ' + CASE rtrim(ltrim(C.cmp_address3)) 
                         WHEN '' THEN isnull(replace(D .cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), '') WHEN NULL THEN isnull(replace(d .cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), '') 
                         ELSE isnull(ltrim(rtrim(C.cmp_address3)), isnull(replace(d .cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), '')) END + ' ' + isnull(D .cty_state, '') + ' ' + isnull(C.cmp_country, '') 
                         + ' ' + isnull(replace(rtrim(ltrim(C.cmp_zip)), '|', ''), ''), rfcorigen = REPLACE(isnull(C.cmp_taxid, ''), '-', ''), contiene = 'UNIDAD DE MEDIDA NO APLICA- ' + replace(isnull
                             ((SELECT        MAX(ivd_description)
                                 FROM            invoicedetail WITH (nolock)
                                 WHERE        ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN'), ''), '|', ''), comentarios = isnull(replace(rtrim(ltrim(replace(replace(ivh_remark, char(13), ''), char(10), 
                         ''))), '|', ''), ''), ampararemisiones = 'Esta factura ampara las remisiones: ' + ivh_invoicenumber, pesoestimado = abs(ivh_totalweight), 
						 
						 destino =isnull(
                             (SELECT        rand_city + ' ' + rand_state
                               FROM            city WITH (nolock)
                               WHERE        cty_code = ivh_destcity),''),
							   
							   
							    destinatario = isnull(E.cmp_name, ''), domiciliodestino = isnull(rtrim(ltrim(E.cmp_address1)), '') + ' ' + isnull(rtrim(ltrim(E.cmp_address2)), '') + ' ' + isnull(ltrim(rtrim(E.cmp_address3)), 
                         F.cty_name) + ' ' + isnull(F.cty_state, '') + ' ' + LEFT(isnull(E.cmp_country, ''), 15) + ' ' + LEFT(isnull(replace(E.cmp_zip, '|', ''), ''), 6), rfcdestino = isnull(E.cmp_taxid, ''), invoice = ivh_invoicenumber, orden = ord_number, 
                         movimiento = mov_number, bandera = ISNULL(ivh_ref_number, ''), ultinvoice = ivh_invoicenumber, tipocomprobante = (CASE ivh_creditmemo WHEN 'N' THEN 'I' WHEN 'Y' THEN 'E' END), lugarexpedicion = '76240', 
                         confirmacion = '', relacion = CASE WHEN invoiceheader.ivh_creditmemo = 'Y' THEN '01' ELSE '' END, uuidrel = CASE WHEN invoiceheader.ivh_creditmemo = 'Y' THEN isnull
                             ((SELECT      max(  uuid )
                                 FROM            [172.24.16.113].CFDI.DBO.[cfdi_detallecfdi] WITH (nolock)
                                 WHERE        folio = CAST(invoiceheader.ivh_cmrbill_link AS VARCHAR)), '') ELSE '' END, invoiceheader.ivh_cmrbill_link, tipodetalle = (CASE ivh_creditmemo WHEN 'N' THEN 'FAC' WHEN 'Y' THEN 'NCR' END)
,RevType4 =(select ord_revtype4 from orderheader oh where oh.ord_hdrnumber = invoiceheader.ord_hdrnumber)
/* Desde las tablas*/ 
				--SELECT *   
					FROM invoiceheader WITH (nolock) , company A WITH (nolock), city B WITH (nolock), company C WITH (nolock), city D WITH (nolock), company E WITH (nolock), city F WITH (nolock)
/*Com las siguientes condiciones*/ 
						WHERE invoiceheader.ivh_invoicestatus = 'PRN' 
						--AND Substring(ivh_invoicenumber, 1, 1) <> 'T' 
						AND ivh_billto <> 'SAE' AND ivh_mbnumber = 0 AND A.cmp_city = B.cty_code AND 
                         A.cmp_id = ivh_billto AND C.cmp_city = D .cty_code AND C.cmp_id = ivh_shipper AND E.cmp_city = F.cty_code AND E.cmp_id = ivh_consignee /*and ivh_ref_number  not like 'TDRT%'  and ivh_ref_number  not like 'NCT%'*/ AND 
                         ivh_invoicenumber NOT IN
                             (SELECT        invoice
                               FROM            Vista_fe_Generadas WITH (nolock))
							   and (SELECT        round(sum(importe), 2)                          FROM  persistente_VISTA_Fe_detail  WHERE folio = cast(ivh_invoicenumber AS varchar(20))) is not null
							   



							   UNION

SELECT   
/*Información General del CFD*/ 
idcomprobante = (CASE f.ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END) + '-' + cast ((SELECT        max(ivh_invoicenumber)
FROM    invoiceheader WITH (nolock)  WHERE        ivh_mbnumber = F.ivh_mbnumber) AS varchar), 
serie = (CASE f.ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END), 
folio = (SELECT   max(ivh_invoicenumber) FROM            invoiceheader WITH (nolock)  WHERE        ivh_mbnumber = F.ivh_mbnumber),
fhemision = dateadd(MINUTE, - 60, getdate()), 


/*** seccion que alenta la vista cambiar a consultar estos datos por .net EMOLVERA**************************************************

   

** termina seccion que alenta la vista*********************************************************************************************/ 

subtotal = (SELECT        round(sum(importe), 2)   FROM    persistente_VISTA_Fe_detail   WHERE        folio IN
 (SELECT        cast(ivh_invoicenumber AS varchar(20)) FROM   invoiceheader   WHERE        ivh_mbnumber = f.ivh_mbnumber)), 
 
imptras = (SELECT        round(sum(iva_monto), 2)   FROM   persistente_VISTA_Fe_detail   WHERE        folio IN
 (SELECT        cast(ivh_invoicenumber AS varchar(20)) FROM  invoiceheader   WHERE        ivh_mbnumber = f.ivh_mbnumber)),
 
imprete = (SELECT        round(sum(ret_monto), 2)   FROM   persistente_VISTA_Fe_detail   WHERE        folio IN
 (SELECT        cast(ivh_invoicenumber AS varchar(20))  FROM  invoiceheader  WHERE        ivh_mbnumber = f.ivh_mbnumber)), 
 
tasatras = '0.160000', tasarete = '0.040000', coditrans = '002', codirete = '002', tipofactor = 'Tasa', descuento = '', 
                         
total =    (SELECT       round(sum(importe + iva_monto - ret_monto), 2)  FROM      persistente_VISTA_Fe_detail  WHERE    folio IN
 (SELECT        cast(ivh_invoicenumber AS varchar(20))  FROM  invoiceheader  WHERE         ivh_mbnumber = f.ivh_mbnumber)),

  totalletra = REPLACE(REPLACE(dbo.NumeroEnLetra(ROUND((abs(f.ivh_totalcharge)), 0, 1)) 
                         + (CASE ivh_currency WHEN 'MX$' THEN ' PESOS' ELSE ' DOLARES' END) + ' ' + CAST((((ROUND((abs(f.ivh_totalcharge)), 2)))) - (ROUND((abs(f.ivh_totalcharge)), 0, 1)) AS varchar) 
                         + ' /100 ' + (CASE ivh_currency WHEN 'MX$' THEN 'M.N.' ELSE 'DLS' END), '0.', ''), '	', ''), movdesc = '', fpago = 'PAGO EN UNA SOLA EXHIBICION',
						 
						 
						 	  condpago =   rtrim
                             (
							 isnull(
							 (SELECT        PYMTRMID
                                 FROM            [172.24.16.113].TDR.DBO.RM00101
                                 WHERE        custnmbr = F.ivh_billto)
								,    (SELECT        PYMTRMID
                                 FROM            [172.24.16.113].CNVOY.DBO.RM00101
                                 WHERE        custnmbr = F.ivh_billto)       
								 )
								 )   ,
					
								 
								 
								 
								  /*- PARAMETRIZACION DATOS DE PREFERENCIA FACTURACION CLIENTES-------------------------------------------------*/ metpago = (CASE f.ivh_creditmemo WHEN 'N' THEN isnull(a.cmp_misc3, '99') 
                         WHEN 'Y' THEN isnull(a.cmp_othertype3, '99') ELSE '99' END), /*metpago es igual a forma de pago para no afectar el funcionanmiento del 3.2*/ cuentaref = CASE WHEN invoiceheader.ivh_creditmemo = 'Y' THEN isnull
                             ((SELECT        uuid
                                 FROM            [172.24.16.113].CFDI.DBO.[cfdi_detallecfdi] WITH (nolock)
                                 WHERE        folio = CAST(invoiceheader.ivh_cmrbill_link AS VARCHAR)), '') ELSE '' END, metodopago33 = (CASE f.ivh_creditmemo WHEN 'N' THEN isnull(a.cmp_misc5, 'PPD') WHEN 'Y' THEN isnull(a.cmp_misc4, 'PPD') ELSE 'PPD' END), 
                         usocfdi = (CASE f.ivh_creditmemo WHEN 'N' THEN isnull(a.cmp_misc6, 'G03') WHEN 'Y' THEN 'G02' ELSE 'G03' END), 
                         /*-----------------------------------------------------------------------------------------------------------*/ moneda = CASE ivh_currency WHEN 'MX$' THEN ' MXN' ELSE 'USD' END, tipocambio = (CASE WHEN (ivh_currency = 'UNK' AND f.ivh_billto = 'WALMART') 
                         THEN '' WHEN (ivh_currency = 'MX$' AND f.ivh_billto = 'WALMART') THEN '' WHEN (ivh_currency = 'UNK' AND f.ivh_billto <> 'WALMART') THEN '1' WHEN (ivh_currency = 'MX$' AND f.ivh_billto <> 'WALMART') 
                         THEN '1' WHEN (ivh_currency = 'US$') THEN
                             (SELECT        cast(round(cex_rate, 2) AS varchar(20))
                               FROM            currency_exchange(nolock)
                               WHERE        cex_date =
                                                             (SELECT        max(cex_Date)
                                                               FROM            currency_exchange(nolock))) WHEN ivh_currency = 'USDOLLAR' THEN
                             (SELECT        cast(round(cex_rate, 2) AS varchar(20))
                               FROM            currency_exchange(nolock)
                               WHERE        cex_date =
                                                             (SELECT        max(cex_Date)
                                                               FROM            currency_exchange(nolock))) END), /*Información del receptor*/ idreceptor = F.ivh_billto, rfc = (CASE A.cmp_country WHEN 'USA' THEN 'XEXX010101000' ELSE REPLACE(replace(isnull(A.cmp_taxid, 
                         ''), ' ', ''), '-', '') END), numtributacion = CASE A.cmp_country WHEN 'USA' THEN REPLACE(replace(isnull(A.cmp_taxid, ''), ' ', ''), '-', '') ELSE '' END, /*solo caso para extranjeros*/ nombrecliente = A.cmp_name, 
                         pais = CASE WHEN A.cmp_country = 'MEXICO' THEN 'MEX' WHEN A.cmp_country = 'Mex' THEN 'MEX' ELSE A.cmp_country END, 
                         paisresidencia = CASE WHEN A.cmp_country = 'MEXICO' THEN '' WHEN A.cmp_country = 'Mex' THEN '' ELSE A.cmp_country END, calle = isnull(rtrim(ltrim(A.cmp_address1)), ''), numext = isnull(A.cmp_misc1, ''), 
                         numint = isnull(A.cmp_misc2, ''), colonia = isnull(A.cmp_address2, ''), localidad = isnull(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), ''), referencia = isnull(rtrim(ltrim(A.cmp_address1)), '') 
                         + isnull(A.cmp_address2, ''), municdeleg = CASE A.cmp_address3 WHEN '' THEN isnull(replace(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), 'CUAJIMALPA DE MORE', 
                         'CUAJIMALPA DE MORELOS'), '') WHEN NULL THEN isnull(replace(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), 'CUAJIMALPA DE MORE', 'CUAJIMALPA DE MORELOS'), '') 
                         ELSE isnull(A.cmp_address3, isnull(REPLACE(replace(B.cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), 'CUAJIMALPA DE MORE', 'CUAJIMALPA DE MORELOS'), '')) END, 
                         /*municdeleg = CASE A.cmp_address3 WHEN '' THEN isnull(replace(B.cty_name,'PROGRESO DE OBREGO','PROGRESO DE OBREGON'), '') WHEN NULL THEN isnull(replace(B.cty_name,'PROGRESO DE OBREGO','PROGRESO DE OBREGON'), '')  ELSE isnull(A.cmp_address3, isnull(replace(B.cty_name,'PROGRESO DE OBREGO','PROGRESO DE OBREGON'), '') ) END, */ estado
                          =
                             (SELECT        upper(stc_state_desc)
                               FROM            statecountry WITH (nolock)
                               WHERE        stc_state_c = B.cty_state), cp = A.cmp_zip, mailenvio = ISNULL(A.cmp_mailto_address1, ''), /*---- Información Adicional Comprobante*/ nmaster = F.ivh_mbnumber, cuotaconv = '', valorcomer = '', 
                         remision = isnull
                             ((SELECT        dbo.orderheader.ord_refnum
                                 FROM            orderheader WITH (nolock)
                                 WHERE        dbo.orderheader.ord_hdrnumber = dbo.invoiceheader.ord_hdrnumber), ''), operador = isnull
                             ((SELECT        MAX(mpp_lastname)
                                 FROM            manpowerprofile WITH (nolock)
                                 WHERE        mpp_id = ivh_driver), '') + ' ' + isnull
                             ((SELECT        MAX(mpp_firstname)
                                 FROM            manpowerprofile WITH (nolock)
                                 WHERE        mpp_id = ivh_driver), ''), operadorlicenicia = isnull
                             ((SELECT        MAX(mpp_licensenumber)
                                 FROM            manpowerprofile WITH (nolock)
                                 WHERE        mpp_id = ivh_driver), ''), tractoeco = ivh_tractor, tractoplaca = isnull
                             ((SELECT        MAX(trc_licnum)
                                 FROM            tractorprofile WITH (nolock)
                                 WHERE        trc_number = ivh_tractor), ''), remolque1Eco = ivh_trailer, remolque1Placa = isnull
                             ((SELECT        MAX(trl_licnum)
                                 FROM            trailerprofile WITH (nolock)
                                 WHERE        trl_number = ivh_trailer), ''), remolque2Eco = '', remolque2Placa = '', documento = rtrim(ltrim(ivh_user_id2)), fechapagare = getdate(), interesespagare = '5%', clientepagare = A.cmp_name, control = '', 
                         hecha = rtrim(ltrim(ivh_user_id2)), revisada = '', autorizada = '', auxiliares = '', origen =
                             (SELECT        rand_city + ' ' + rand_state
                               FROM            city WITH (nolock)
                               WHERE        cty_code = ivh_origincity), remitente = isnull(C.cmp_name, ''), domicilioorigen = isnull(ltrim(rtrim(C.cmp_address1)), '') + ' ' + ' ' + isnull(rtrim(ltrim(C.cmp_address2)), '') + ' ' + CASE rtrim(ltrim(C.cmp_address3)) 
                         WHEN '' THEN isnull(replace(d .cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), '') WHEN NULL THEN isnull(replace(d .cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), '') 
                         ELSE isnull(ltrim(rtrim(C.cmp_address3)), isnull(replace(d .cty_name, 'PROGRESO DE OBREGO', 'PROGRESO DE OBREGON'), '')) END + ' ' + isnull(D .cty_state, '') + ' ' + isnull(C.cmp_country, '') 
                         + ' ' + isnull(replace(rtrim(ltrim(C.cmp_zip)), '|', ''), ''), rfcorigen = REPLACE(isnull(C.cmp_taxid, ''), '-', ''), contiene = 'UNIDAD DE MEDIDA NO APLICA-  ' + isnull
                             ((SELECT        MAX(ivd_description)
                                 FROM            invoicedetail WITH (nolock)
                                 WHERE        ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN'), ''), comentarios = isnull(replace(rtrim(ltrim(replace(replace(ivh_remark, char(13), ''), char(10), ''))), 
                         '|', ''), ''), ampararemisiones = dbo.formacadenamaster(f.ivh_mbnumber), pesoestimado = abs(ivh_totalweight), destino =
                            
							isnull( (SELECT        rand_city + ' ' + rand_state
                               FROM            city WITH (nolock)
                               WHERE        cty_code = ivh_destcity),''),
							   
							   
							    destinatario = isnull(E.cmp_name, ''), domiciliodestino = isnull(rtrim(ltrim(E.cmp_address1)), '') + ' ' + isnull(rtrim(ltrim(E.cmp_address2)), '') + ' ' + isnull(ltrim(rtrim(E.cmp_address3)), 


                         D .cty_name) + ' ' + isnull(D .cty_state, '') + ' ' + LEFT(isnull(E.cmp_country, ''), 15) + ' ' + LEFT(isnull(replace(E.cmp_zip, '|', ''), ''), 6), rfcdestino = isnull(E.cmp_taxid, ''), 
						 
						 
						 invoice =
                             (SELECT        max(ivh_invoicenumber)
                               FROM            invoiceheader WITH (nolock)
                               WHERE        ivh_mbnumber = F.ivh_mbnumber), orden = f.ord_number, movimiento = CASE WHEN F.ivh_mbnumber = 0 THEN mov_number WHEN F.ivh_mbnumber > 0 THEN F.ivh_mbnumber END, 
                         bandera = ISNULL(ivh_ref_number, ''), ultinvoice =
                             (SELECT        max(ivh_invoicenumber)
                               FROM            invoiceheader WITH (nolock)
                               WHERE        ivh_mbnumber = F.ivh_mbnumber), tipocomprobante = (CASE f.ivh_creditmemo WHEN 'N' THEN 'I' WHEN 'Y' THEN 'E' END), lugarexpedicion = '76240', confirmacion = '', 
                         relacion = CASE WHEN F.ivh_creditmemo = 'Y' THEN '01' ELSE '' END, uuidrel = CASE WHEN F.ivh_creditmemo = 'Y' THEN isnull
                             ((SELECT       min( uuid)
                                 FROM            [172.24.16.113].CFDI.DBO.[cfdi_detallecfdi] WITH (nolock)
                                 WHERE        folio =
                                                              (SELECT        CAST(ivh_cmrbill_link AS VARCHAR)
                                                                FROM            invoiceheader(nolock)
                                                                WHERE        ivh_invoicenumber =
                                                                                              (SELECT        min(ivh_invoicenumber)
                                                                                                FROM            invoiceheader WITH (nolock)
                                                                                                WHERE        ivh_mbnumber = F.ivh_mbnumber))), '') ELSE '' END, invoiceheader.ivh_cmrbill_link, tipodetalle = (CASE f.ivh_creditmemo WHEN 'N' THEN 'FAC' WHEN 'Y' THEN 'NCR' END)

,RevType4 =(select ord_revtype4 from orderheader oh where oh.ord_hdrnumber = invoiceheader.ord_hdrnumber)
/* Desde las tablas*/
FROM invoiceheader WITH (nolock),
vTTSTMW_FirstREg F WITH (nolock), company A WITH (nolock), city B WITH (nolock), company C WITH (nolock), city D WITH (nolock), company E WITH (nolock), 
                         city G WITH (nolock)
/* Con las siguientes condiciones */ 
WHERE invoiceheader.ivh_invoicenumber = F.ivh_invoicenumber AND CONVERT(varchar, invoiceheader.ivh_printdate, 112) >= '20100801'
AND F.ivh_mbnumber = invoiceheader.ivh_mbnumber AND 
                         A.cmp_city = B.cty_code AND A.cmp_id = invoiceheader.ivh_billto AND C.cmp_city = D .cty_code AND C.cmp_id = ivh_shipper AND E.cmp_city = G.cty_code AND 
                         E.cmp_id = ivh_consignee /*and ivh_ref_number  not like 'TDRT%'  and ivh_ref_number  not like 'NCT%'*/ 
						 
						 
						 AND f.ivh_mbnumber NOT IN
                             (SELECT        nmaster
                               FROM            Vista_fe_Generadas WITH (nolock))

							   and 
							   (SELECT        round(sum(importe), 2)   FROM    persistente_VISTA_Fe_detail   WHERE        folio IN
 (SELECT        cast(ivh_invoicenumber AS varchar(20)) FROM   invoiceheader   WHERE        ivh_mbnumber = f.ivh_mbnumber)) is not null 



GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[8] 2[32] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 86
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1620
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Widt', 'SCHEMA', N'dbo', 'VIEW', N'VISTA_fe_Header', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'h = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'VISTA_fe_Header', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'VISTA_fe_Header', NULL, NULL
GO
