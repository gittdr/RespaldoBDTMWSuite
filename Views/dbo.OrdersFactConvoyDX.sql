SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











-- SELECT * FROM OrdersFactConvoyDX
-- Órdenes creadas DX con car_type3 = Convoy360 (CONV) *Proveedores que facturan con Convoy 360*

/*
select ord_billto, ord_hdrnumber, ord_refnum from orderheader where ord_refnum like 'TIJ4322%' and ord_billto = 'TDRQUERE'
*/

CREATE VIEW [dbo].[OrdersFactConvoyDX]
AS
SELECT


 o.ord_startdate AS 'FECHA'
	,row_number() OVER (
		ORDER BY o.ord_hdrnumber ASC
		) AS 'No'
	,o.ord_refnum AS 'Transporte'
	,o.ord_carrier AS 'CARRIER'
	,ca.car_name AS 'Nombre Carrier'
	,substring(o.ord_refnum, 1, 7) AS 'Proyecto SAEGP'
	,substring(o.ord_refnum, 9, 7) AS 'No. SIAB'
	,o.ord_shipper AS 'ORIGEN'
	,shipper.cmp_name AS 'Nombre Origen'
	,ord_origin_latestdate AS 'FeOri' --bien
	,ord_origin_latestdate AS 'FeOri_V'
	,o.ord_consignee AS 'D'
	,consignee.cmp_name AS 'Nombre destino'
	,o.ord_completiondate AS 'TimeD' --bieN 
	,o.ord_dest_latestdate AS 'TimeD_V'
	,'' AS 'E'
	,'#N/A' AS 'COLUMNA_Q'
	,'#N/A' AS 'TimeE'
	,'#N/A' AS 'TimeE_V'
	,'' AS 'S'
	,'#N/A' AS 'COLUMNA_U'
	,'#N/A' AS 'TimeS'
	,'#N/A' AS 'TimeS_V'
	,'' AS 'T'
	,'#N/A' AS 'COLUMNA_Y'
	,'#N/A' AS 'TimeT'
	,'#N/A' AS 'TimeT_V'
	,'' AS 'I'
	,'#N/A' AS 'COLUMNA_AC'
	,'#N/A' AS 'TimeI'
	,'#N/A' AS 'TimeI_V'
	,'' AS 'N'
	,'#N/A' AS 'COLUMNA_AG'
	,'#N/A' AS 'TimeN'
	,'#N/A' AS 'TimeN_V'
	,'' AS 'O'
	,'#N/A' AS 'COLUMNA_AK'
	,'#N/A' AS 'TimeO'
	,'#N/A' AS 'TimeO_V'
	,'' AS 'S2'
	,'#N/A' AS 'COLUMNA_AO'
	,'#N/A' AS 'TimeS2'
	,'#NA' AS 'TimeS2_V'
	,'' AS 'dx_movenumber'
	,'' AS 'dx_stopnumber'
	-- PESO DE CADA STOP para otros Billto's 
	,o.ord_totalweight AS 'PESO'
	,'' AS 'COLUMNA_AU'
	,'SAEQRO' AS 'Sucursal'
	,o.cmd_code AS 'PRODUCTO'
	,'TDRQUERE' AS 'Billto'
	,'TDR' AS 'Orderby'
	,'BKG' AS 'ProyOrden'
	,'CNV' AS 'Division'
	,'N' AS 'DoNotInvoice'
	,'' AS 'man1'
	,'' AS 'man2'
	,'' AS 'man3'
	,'' AS 'man4'
	,'' AS 'man5'
	,'' AS 'man6'
	,'' AS 'CONF'
	,'UNKNOWN' AS 'REM_1_1'
	,'UNKNOWN' AS 'REM_1_2'
	,'UNKNOWN' AS 'DOLLY_1'
	,'UNKNOWN' AS 'REM_2_1'
	,'UNKNOWN' AS 'REM_2_2'
	,'UNKNOWN' AS 'DOLLY_2'
	,'UNKNOWN' AS 'REM_3_1'
	,'UNKNOWN' AS 'REM_3_2'
	,'UNKNOWN' AS 'DOLLY_3'
	,'UNKNOWN' AS 'REM_4_1'
	,'UNKNOWN' AS 'REM_4_2'
	,'UNKNOWN' AS 'DOLLY_4'
	,'UNKNOWN' AS 'REM_5_1'
	,'UNKNOWN' AS 'REM_5_2'
	,'UNKNOWN' AS 'DOLLY_5'
	,'UNKNOWN' AS 'REM_6_1'
	,'UNKNOWN' AS 'REM_6_2'
	,'UNKNOWN' AS 'DOLLY_6'
	,'UNKNOWN' AS 'REM_7_1'
	,'UNKNOWN' AS 'REM_7_2'
	,'UNKNOWN' AS 'DOLLY_7'
	,'UNKNOWN' AS 'REM_8_1'
	,'UNKNOWN' AS 'REM_8_2'
	,'UNKNOWN' AS 'DOLLY_8'
	,'' AS 'REM_9_1'
	,'' AS 'REM_9_2'
	,'' AS 'REM_10_1'
	,'' AS 'REM_10_2'
	,'' AS 'REM_11_1'
	,'' AS 'REM_11_2'
	,'' AS 'REM_12_1'
	,'' AS 'REM_12_2'
	,'' AS 'REM_13_1'
	,'' AS 'REM_13_2'
	,'' AS 'REM_14_1'
	,'' AS 'REM_14_2'
	,'' AS 'REM_15_1'
	,'' AS 'REM_15_2'
	,'' AS 'REM_16_1'
	,'' AS 'REM_16_2'
	,'' AS 'ref2'
	,'' AS 'ref3'
	,'' AS 'ref4'
	,'' AS 'ref5'
	,'' AS 'ref6'
	,'' AS 'unidad'
	,'' AS 'operador'
	-- EVENTOS DE STOPS para otros Billto's
	,'LLD' AS 'evento1'
	,'LUL' AS 'evento2'
	,'' AS 'evento3'
	,'' AS 'evento4'
	,'' AS 'evento5'
	,'' AS 'evento6'
	-- PESO STOPS para otros Billto's
	,o.ord_totalweight AS 'descga2'
	,'' AS 'descga3'
	,'' AS 'descga4'
	,'' AS 'descga5'
	,'' AS 'descga6'
	,'' AS 'Remolque'
	,'' AS 'Remolque2'
	,o.trl_type1 AS 'TIPOREMOLQUE'
	,lbtiporemol.name AS 'Descripción'
	,'' AS 'NumeroGPS'
	,o.ord_trl_type3 AS 'ZONA'
	,o.ord_revtype2 AS 'SucursalSAE'
	,lbsucur.name AS 'Nombre SucursalSAE'

FROM orderheader o
INNER JOIN carrier ca ON o.ord_carrier = ca.car_id
INNER JOIN company consignee ON o.ord_consignee = consignee.cmp_id
INNER JOIN company shipper ON o.ord_shipper = shipper.cmp_id
INNER JOIN labelfile lbsucur ON o.ord_revtype2 = lbsucur.abbr
INNER JOIN labelfile lbtiporemol ON o.trl_type1 = lbtiporemol.abbr 
WHERE ord_billto IN ('SAE')
	AND ord_bookedby = 'DX'
	AND ord_status = 'CMP'
	AND ord_bookdate > '2020-07-01'
	AND ca.car_type3 = 'CONV'
	AND lbsucur.labeldefinition = 'Revtype2' --INNER JOIN mostrar Nombre Sucursal SAE
	AND lbtiporemol.labeldefinition = 'TrlType1' --INNER JOIN mostrar Nombre Tipo Remolque
	AND CAST(o.ord_refnum AS VARCHAR) NOT IN (
		SELECT CAST(ISNULL(ord_refnum, '') AS VARCHAR)
		FROM orderheader
		WHERE ord_billto = 'TDRQUERE'
			AND ord_revtype4 = 'CNV'
			--AND ord_status <> 'CAN'
		)
	--and	o.ord_revtype2 = 'MTE'
	AND ord_bookdate > GETDATE()-20 --'2020-03-29'
 -- and	(o.ord_refnum  like 'TIJ4277%')




GO
