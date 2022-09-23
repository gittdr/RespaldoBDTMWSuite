SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  VIEW  [dbo].[comprobantes] AS SELECT d.ivh_invoicenumber as Regreso,d.ivh_invoicenumber AS invoicenumberD, h.cmp_name, h.ivh_billto, h.cmp_id, 
h.ivh_invoicenumber AS invoicenumberH, REPLACE(REPLACE(h.rfc, ' ',''), '-', '' ) AS rfc,

h.calle, h.ext, h.interior, h.colonia, h.municipio, h.ciudad, h.estado, 

h.pais, h.cmp_zip, h.email_address, h.ce_phone1, h.cmp_revtype1, 

h.ivh_billdate, h.ivh_shipper, h.ivh_consignee, h.ord_number, h.mov_number, h.ivh_remark,

h.lastname + ' ' + h.firstname AS lastname, h.licensenumber, h.ivh_tractor, h.tractor_licnum, h.ivh_trailer, 
h.trailer_licnum, h.ivh_user_id2,

h.ivh_ref_number, h.ivh_terms,

SUM(CASE ISNUMERIC(CAST (d.iva_monto AS VARCHAR (255)))

WHEN 0 THEN 0

WHEN 1 THEN d.iva_monto

END )AS ivaMonto, SUM(CASE ISNUMERIC( CAST (d.ret_monto AS VARCHAR(255)))

WHEN 0 THEN 0

WHEN 1 THEN d.ret_monto

END) AS retMonto, SUM(d.ivd_charge) AS subTotal,

SUM(CASE ISNUMERIC(CAST (d.iva_monto AS VARCHAR (255)))

WHEN 0 THEN 0

WHEN 1 THEN d.iva_monto

END ) - SUM(CASE ISNUMERIC( CAST (d.ret_monto AS VARCHAR(255)))

WHEN 0 THEN 0

WHEN 1 THEN d.ret_monto

END) + SUM(d.ivd_charge) AS totalCalc, CASE h.ivh_creditmemo

WHEN 'N' THEN 'ingreso'

WHEN 'Y' THEN 'egreso'

END AS tpoDoc,

CASE h.ivh_creditmemo

WHEN 'N' THEN 'TDR'

WHEN 'Y' THEN 'NC'

END AS serie, (SELECT SUM(df.ivd_charge)

FROM dbo.vTTSTMW_detail AS df

WHERE df.descripcion LIKE '%Viaje%' AND h.ivh_invoicenumber = df.ivh_invoicenumber) AS impFlete,

(SELECT SUM(df.ivd_charge)

FROM dbo.vTTSTMW_detail AS df

WHERE df.descripcion LIKE '%Maniobras%' AND h.ivh_invoicenumber = df.ivh_invoicenumber) AS impManiobras,

(SELECT SUM(df.ivd_charge)

FROM dbo.vTTSTMW_detail AS df

WHERE df.descripcion LIKE '%Autopistas%' AND h.ivh_invoicenumber = df.ivh_invoicenumber) AS impAutopistas,

(SELECT SUM(df.ivd_charge)

FROM dbo.vTTSTMW_detail AS df

WHERE df.descripcion NOT LIKE '%Autopistas%' AND df.descripcion NOT LIKE '%Maniobras%' AND df.descripcion NOT LIKE 
'%Viaje%' AND h.ivh_invoicenumber = df.ivh_invoicenumber) AS impOtros,

h.ciudad_origen, h.ciudad_destino, h.peso_estimado,

CAST (DAY(h.ivh_billdate) AS VARCHAR (20) ) + CASE CAST( (MONTH(h.ivh_billdate)) AS VARCHAR (50) )

WHEN '1' THEN ' DE ENERO DE '

WHEN '2' THEN ' DE FEBRERO DE '

WHEN '3' THEN ' DE MARZO DE '

WHEN '4' THEN ' DE ABRIL DE '

WHEN '5' THEN ' DE MAYO DE '

WHEN '6' THEN ' DE JUNIO DE '

WHEN '7' THEN ' DE JULIO DE '

WHEN '8' THEN ' DE AGOSTO DE '

WHEN '9' THEN ' DE SEPTIEMBRE DE '

WHEN '10' THEN ' DE OCTUBRE DE '

WHEN '11' THEN ' DE NOVIMEBRE DE '

WHEN '12' THEN ' DE DICIEMBRE DE '

END

+ CAST( (YEAR(h.ivh_billdate)) AS VARCHAR (50) ) AS fechaLetra, h.moneda,

h.ivd_descripcion, h.rfc_origen AS EXTRA39, h.calle_origen AS EXTRA24, h.ext_origen AS EXTRA25, h.interior_origen AS 
EXTRA26,

h.colonia_origen AS EXTRA27, h.municipio_origen AS EXTRA28, h.municipio_origen, h.cd_origen, h.edo_origen,

h.pais_origen, h.ZIP_origen AS EXTRA29, h.NAME_origen AS EXTRA23, h.email_address_origen, h.ce_phone1_origen,

h.revtype1_origen, h.contact_name_origen, h.rfc_destino AS EXTRA37, h.calle_destino AS EXTRA31, h.ext_destino AS 
EXTRA32,

h.interior_destino AS EXTRA33, h.colonia_destino AS EXTRA34, h.municipio_destino AS EXTRA35, h.cd_destino AS EXTRA38, 
h.edo_destino,

h.pais_destino, h.ZIP_destino AS EXTRA36, h.NAME_destino AS EXTRA30, h.email_address_destino, h.ce_phone1_destino,

h.revtype1_destino, h.contact_name_destino AS EXTRA40, CASE (h.masterbill)

WHEN 0 THEN NULL

ELSE h.masterbill

END AS EXTRA47

FROM  dbo.vTTSTMW_Header AS h WITH( NOLOCK ), dbo.vTTSTMW_detail AS d WITH( NOLOCK )
--, wf..wfacturas as w WITH( NOLOCK )

where h.ivh_invoicenumber  = d.ivh_invoicenumber and
--h.ivh_invoicenumber != w.llave_comprobante
h.referencia_factura  = ''

GROUP BY h.ivh_invoicenumber,h.cmp_name, h.ivh_billto, h.cmp_id, d.ivh_invoicenumber, h.ivh_invoicenumber, h.rfc, 
h.calle, h.ext, h.interior, h.colonia, h.municipio, h.ciudad, h.estado, 

h.pais, h.cmp_zip, h.cmp_name, h.email_address, h.ce_phone1, h.cmp_revtype1, 

h.ivh_billdate, h.ivh_shipper, h.ivh_consignee, h.ord_number, h.mov_number, h.ivh_remark,

h.lastname, h.licensenumber, h.ivh_tractor, h.tractor_licnum, h.ivh_trailer, h.trailer_licnum, h.ivh_user_id2,

h.ivh_ref_number, h.ivh_terms, h.ivh_creditmemo, h.ciudad_origen, h.ciudad_destino, h.peso_estimado, h.moneda, 
h.ivd_descripcion,

h.rfc_origen, h.calle_origen, h.ext_origen, h.interior_origen,

h.colonia_origen, h.municipio_origen, h.municipio_origen, h.cd_origen, h.edo_origen,

h.pais_origen, h.ZIP_origen, h.NAME_origen, h.email_address_origen, h.ce_phone1_origen,

h.revtype1_origen, h.contact_name_origen, h.rfc_destino, h.calle_destino, h.ext_destino,

h.interior_destino, h.colonia_destino, h.municipio_destino, h.cd_destino, h.edo_destino,

h.pais_destino, h.ZIP_destino, h.NAME_destino, h.email_address_destino, h.ce_phone1_destino, 

h.revtype1_destino, h.contact_name_destino, h.masterbill, h.firstname

GO
