SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select * from orderheader where ord_hdrnumber = 171620
--drop proc pod_format04JR
-- Exec pod_format04JR_XD 196286, 203052

CREATE PROCEDURE [dbo].[pod_format04JR_XD] (@mov_number 	INTEGER, @lgh		INTEGER) 
AS
DECLARE @temp_name   	VARCHAR(30) ,  
        @temp_addr   	VARCHAR(30) ,  
        @temp_addr2  	VARCHAR(30),  
        @temp_nmstct	VARCHAR(30),  
        @temp_altid  	VARCHAR(25),  
        @counter    	INTEGER,  
        @ret_value  	INTEGER,  
        @temp_terms    	VARCHAR(20),  
        @varchar50 	VARCHAR(50)  ,
        @ls_rateby 	CHAR(1),
		@toll_charge	MONEY,
		@V_renglon		int,
		@V_evento		VARCHAR(6), 
		@V_compañia		VARCHAR(30),
		@V_ciudad		VARCHAR(30), 
		@V_producto		VARCHAR(60), 
		@V_peso			VARCHAR(10),
		@V_todoseventos	VARCHAR(900),
		@V_Tipocargo	VARCHAR(6),
		@V_montocargo	MONEY,
		@V_ivacargo		MONEY,
		@V_retcargo		MONEY,
		@V_tieneiva		char(1),
		@V_tieneret		Char(1),
		@V_montototal	MONEY,
		@V_cantidadletras Varchar(120),
		@V_datoiva			Dec(4),
		@V_datoretencion	Dec(4),	
		@V_datomoneda		VARCHAR(3),
		@V_montomaniobras	MONEY,
		@V_montocasetas		MONEY,
		@VP_orden INTEGER,
		@VP_unidad VARCHAR(10),
		@VP_caja VARCHAR(10),
		@VP_Ope	VARCHAR(6),
		@VP_placasU VARCHAR(10),
		@VP_placasT VARCHAR(10),
		@VP_nombre VARCHAR(20),
		@VP_apellidos VARCHAR(20),
		@VP_licencia VARCHAR(20),
		@ord_hdrnumber	integer


/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET  */
CREATE TABLE #temp
(
	sort_sequence 		INTEGER IDENTITY NOT NULL,
	ord_number 		VARCHAR(20) NULL,
	ord_billto 		VARCHAR(8) NULL,
	billto_name 		VARCHAR(100) NULL,  
	billto_addr 		VARCHAR(100)  NULL,  
	billto_addr2 		VARCHAR(100) NULL,           
	billto_nmstct 		VARCHAR(30) NULL,
	billto_credit_terms	VARCHAR(20) NULL, 
	ord_shipper  		VARCHAR(8) NULL,     
	shipper_name 		VARCHAR(100) NULL,  
	shipper_addr 		VARCHAR(100) NULL,  
	shipper_addr2 		VARCHAR(100) NULL,  
	shipper_nmstct 		VARCHAR(30) NULL,
	shipper_contact		VARCHAR(30) NULL,
	shipper_directions	TEXT NULL,  
	ord_consignee 		VARCHAR(8) NULL,     
	consignee_name 		VARCHAR(100) NULL,  
	consignee_addr 		VARCHAR(100) NULL,  
	consignee_addr2 	VARCHAR(100) NULL,  
	consignee_nmstct 	VARCHAR(30) NULL,
	consignee_contact	VARCHAR(30) NULL,
	consignee_directions	TEXT NULL,
	ord_rateby 		CHAR(1) NULL,
	cht_itemcode 		VARCHAR(8) NULL, 
	ref_type 		VARCHAR(6) NULL,
	ref_num 		VARCHAR(30) NULL,
	fgt_vol 		MONEY NULL,
	fgt_volunits 		VARCHAR(6) NULL,
	fgt_count		MONEY NULL,
	fgt_weight		MONEY NULL,
	fgt_weightunits		VARCHAR(6) NULL,
	quantity 		MONEY NULL,   
	rate 			MONEY NULL,   
	charge 			MONEY NULL,
	pod_cmp_addr1 		VARCHAR(100) NULL,   
	pod_cmp_addr2 		VARCHAR(100) NULL,   
	pod_cmp_addr3 		VARCHAR(100) NULL,   
	pod_cmp_addr4 		VARCHAR(100) NULL,
	ord_bookdate 		DATETIME NULL,
	ord_startdate 		DATETIME NULL,
        ord_enddate		DATETIME NULL,
	ord_reftype 		VARCHAR(6) NULL,
	ord_refnum 		VARCHAR(30) NULL,
	tractor 		VARCHAR(8) NULL,
	trailer 		VARCHAR(13) NULL,
	driver 			VARCHAR(8) NULL,
	ord_revtype1_t 		VARCHAR(20) NULL,
	ord_revtype2_t 		VARCHAR(20) NULL,
	ord_revtype3_t 		VARCHAR(20) NULL,
	ord_revtype4_t 		VARCHAR(20) NULL,
	ord_revtype1 		VARCHAR(20) NULL,
	ord_revtype2 		VARCHAR(20) NULL,
	ord_revtype3 		VARCHAR(20) NULL,
	ord_revtype4 		VARCHAR(20) NULL,
	unit 			VARCHAR(6) NULL,
	rateunit 		VARCHAR(6) NULL,
	unitdesc 		VARCHAR(20) NULL,
	rateunitdesc 		VARCHAR(20) NULL,
	stp_number 		INTEGER NULL,
	cmp_id 			VARCHAR(8) NULL,
	cmp_name 		VARCHAR(100) NULL,
	cmp_nmstct 		VARCHAR(30) NULL,
	fgt_description	 	VARCHAR(60) NULL,
	cht_description	 	VARCHAR(30) NULL,
	det_description		VARCHAR(255) NULL,
	ord_terms		VARCHAR(6) NULL,
	load_comment		VARCHAR(60) NULL,
	unload_comment		VARCHAR(60) NULL,
	ord_remark		VARCHAR(254) NULL,
	mov_number		INTEGER NULL,
	driver_firstname	VARCHAR(40) NULL,
	driver_lastname		VARCHAR(40) NULL,
        driver_license		VARCHAR(25) NULL,
	tractor_license		VARCHAR(12) NULL,
	trailer_license		VARCHAR(12) NULL,
	ord_bookedby		VARCHAR(20) NULL,
	ord_accessorial_chrg	MONEY NULL,
	toll_charge		MONEY NULL,
    iva_tax			VARCHAR(2) NULL,
    retention_tax		VARCHAR(2) NULL,
	consignee_phone		VARCHAR(20) NULL,
	shipper_phone		VARCHAR(20) NULL,
	trailer2		VARCHAR(13) NULL,
	trailer2_license	VARCHAR(12) NULL,
	ord_carrier 		VARCHAR(8) NULL,
	nombre_carrier		VARCHAR(30) NULL,
    montoenletra		VARCHAR(250) NULL,
	TodosEventos		VARCHAR(900) NULL,
	iva_total			MONEY NULL,
	retencion_total		MONEY NULL,
	maniobras_total		MONEY Null,
	autopistas_total	MONEY Null
)

CREATE TABLE #toll_charge
(
	cht_itemcode		VARCHAR(6) NULL
)

-- Tabla para las paradas
CREATE TABLE #eventos
(renglon	integer,
evento		VARCHAR(6) NULL,
compañia	VARCHAR(30) NULL,
ciudad		VARCHAR(30) NULL,
producto	VARCHAR(60) NULL,
peso		VARCHAR(10) NULL)

-- Tabla de paso para los impuestos
CREATE TABLE #cargos
(tipocargo		VARCHAR(6) NULL,
 cargo		Money Null,
 tax1		CHAR(1) Null,
 tax2		CHAR(1) NULL)




IF @lgh = 0
BEGIN
   SELECT @lgh = MIN(lgh_number) 
     FROM stops 
    WHERE mov_number = @mov_number
END

SELECT @ls_rateby = MIN(ord_rateby), @ord_hdrnumber =  MIN(ord_hdrnumber)
  FROM orderheader 
 WHERE mov_number = @mov_number

IF @ls_rateby = 'T' -- For rate by total create a line for linehaul from orderheader and details from invoicedetails
BEGIN
   IF (SELECT count(*) 
         FROM invoicedetail 
        WHERE ord_hdrnumber = @ord_hdrnumber AND
              ivd_type = 'SUB') < 1
   BEGIN

      INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                         fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                         stp_number, fgt_description, ord_carrier)
         SELECT cht_itemcode, ord_reftype,ord_refnum, ord_totalvolume ,ord_totalvolumeunits,
                ord_totalpieces, ord_totalweight, ord_totalweightunits, ord_quantity, ord_rate, 
                ord_charge, ord_unit, ord_rateunit, 0,ord_description, ord_carrier
	   FROM orderheader 
          WHERE ord_hdrnumber = @ord_hdrnumber
   END

END
ELSE -- For rate by detail get all the information from freightdetails
BEGIN
   INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, fgt_reftype, fgt_refnum, fgt_volume ,fgt_volumeunit, fgt_count, 
             fgt_weight, fgt_weightunit, fgt_quantity, fgt_rate, fgt_charge, fgt_unit, 
             fgt_rateunit, stp_number, fgt_description
	FROM freightdetail 
       WHERE stp_number IN (SELECT stp_number 
                              FROM stops 
                             WHERE ord_hdrnumber = @ord_hdrnumber AND 
                                   stp_type = 'DRP')
	
   INSERT INTO #temp (cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits , fgt_count,
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_count,
             ivd_wgt, ivd_wgtunit, ivd_quantity, ivd_rate, ivd_charge, ivd_unit, ivd_rateunit, 
             stp_number, ivd_description
        FROM invoicedetail 
       WHERE ord_hdrnumber = @ord_hdrnumber
END

UPDATE #temp 
   SET cht_description = chargetype.cht_description 
  FROM chargetype 
 WHERE #temp.cht_itemcode = chargetype.cht_itemcode

UPDATE #temp 
   SET #temp.cmp_id = stops.cmp_id,
       #temp.cmp_name = company.cmp_name
  FROM stops,company 
 WHERE #temp.stp_number > 0 AND
       #temp.stp_number = stops.stp_number AND
       stops.cmp_id = company.cmp_id

UPDATE #temp 
   SET #temp.cmp_nmstct = SUBSTRING(city.cty_nmstct, 1, CHARINDEX('/', city.cty_nmstct) - 1) 
  FROM company,city
 WHERE #temp.cmp_id = company.cmp_id AND
       company.cmp_city = city.cty_code

UPDATE #temp 
   SET unitdesc = name  
  FROM labelfile 
 WHERE labeldefinition LIKE '%Units%' AND
       #temp.unit = abbr

UPDATE #temp 
   SET rateunitdesc = name  
  FROM labelfile 
 WHERE labeldefinition = 'RateBy' AND
       #temp.rateunit = abbr

UPDATE #temp 
   SET driver = lgh_driver1, 
       tractor = lgh_tractor, 
       trailer = lgh_primary_trailer,
       trailer2 = lgh_primary_pup
  FROM legheader 
 WHERE lgh_number = @lgh

UPDATE #temp
   SET driver_firstname = mpp_firstname,
       driver_lastname = mpp_lastname,
       driver_license = mpp_licensenumber
  FROM manpowerprofile
 WHERE mpp_id = #temp.driver AND
       #temp.driver <> 'UNKNOWN'

UPDATE #temp
   SET tractor_license = trc_licnum
  FROM tractorprofile
 WHERE trc_number = #temp.tractor AND
       #temp.tractor <> 'UNKNOWN'

UPDATE #temp
   SET trailer_license = trl_licnum
  FROM trailerprofile
 WHERE trl_id = #temp.trailer AND
       #temp.trailer <> 'UNKNOWN'

UPDATE #temp
   SET trailer2_license = trl_licnum
  FROM trailerprofile
 WHERE trl_id = #temp.trailer2 AND
       #temp.trailer2 <> 'UNKNOWN'

UPDATE #temp 
   SET pod_cmp_addr1 = gi_string1,
       pod_cmp_addr2 = gi_string2,
       pod_cmp_addr3 = gi_string3,
       pod_cmp_addr4 = gi_string4 
  FROM generalinfo 
 WHERE gi_name = 'PODCompany'

UPDATE #temp 
   SET ord_number = orderheader.ord_number,
       ord_bookdate = orderheader.ord_bookdate,
       ord_startdate = orderheader.ord_startdate,
       ord_enddate = orderheader.ord_completiondate,
       ord_reftype =orderheader.ord_reftype,
       ord_refnum = orderheader.ord_refnum,
       ord_terms = orderheader.ord_terms,
       ord_remark = orderheader.ord_remark,
       mov_number = orderheader.mov_number,
       ord_bookedby = orderheader.ord_bookedby,
       ord_billto = orderheader.ord_billto,
       ord_shipper = orderheader.ord_shipper,
       ord_consignee = orderheader.ord_consignee,
       ord_rateby = orderheader.ord_rateby,
       ord_accessorial_chrg = ISNULL(orderheader.ord_accessorial_chrg, 0)
  FROM orderheader 
 WHERE ord_hdrnumber = @ord_hdrnumber

--Get the toll charges
INSERT INTO #toll_charge
   SELECT DISTINCT cht_itemcode
     FROM tollbooth
    WHERE cht_itemcode IS NOT NULL AND
          cht_itemcode <> 'UNK'
SELECT @toll_charge = ISNULL(SUM(ivd_charge), 0)
  FROM invoicedetail
 WHERE invoicedetail.ord_hdrnumber = @ord_hdrnumber AND
       invoicedetail.cht_itemcode IN (SELECT #toll_charge.cht_itemcode
                                        FROM #toll_charge)
UPDATE #temp
   SET toll_charge = @toll_charge

UPDATE #temp 
   SET ord_revtype1 = labelfile.name, 
       ord_revtype1_t = labelfile.userlabelname
  FROM labelfile, orderheader
 wHERE ord_hdrnumber = @ord_hdrnumber AND
       labelfile.labeldefinition= 'RevType1' AND
       orderheader.ord_revtype1 = labelfile.abbr

UPDATE #temp 
   SET billto_name = company.cmp_name,
       billto_addr = cmp_address1,
       billto_addr2 = ISNULL(cmp_address2,''),
       billto_nmstct = CASE cty_nmstct 
                          WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                          ELSE SUBSTRING(cty_nmstct, 1 , CHARINDEX('/', cty_nmstct) - 1) + '  ' + ISNULL(cmp_zip, ' ')
                       END,
       billto_credit_terms = (SELECT name
                                FROM labelfile
                               WHERE labeldefinition = 'CreditTerms' AND
                                     abbr = company.cmp_terms)
  FROM company 
 WHERE #temp.ord_billto = company.cmp_id 

UPDATE #temp 
   SET shipper_name = company.cmp_name,
       shipper_addr = cmp_address1,
       shipper_addr2 = ISNULL(cmp_address2,''),
       shipper_nmstct = CASE cty_nmstct 
                           WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                           ELSE SUBSTRING(cty_nmstct, 1, CHARINDEX('/', cty_nmstct) - 1) + '  ' + ISNULL(cmp_zip, ' ')
                        END,
       shipper_contact = company.cmp_contact,
       shipper_directions = company.cmp_directions,
       shipper_phone = company.cmp_primaryphone
  FROM company 
 WHERE #temp.ord_shipper = company.cmp_id 

UPDATE #temp 
   SET consignee_name = company.cmp_name,
       consignee_addr = cmp_address1,
       consignee_addr2 = ISNULL(cmp_address2,''),
       consignee_nmstct = CASE cty_nmstct 
                             WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                             ELSE SUBSTRING(cty_nmstct, 1, charindex('/', cty_nmstct) - 1) + '  ' + ISNULL(cmp_zip, ' ') 
                          END,
       consignee_contact = company.cmp_contact,
       consignee_directions = company.cmp_directions,
       consignee_phone = company.cmp_primaryphone
  FROM company 
 WHERE #temp.ord_consignee = company.cmp_id 

UPDATE #temp
   SET load_comment = stops.stp_comment
  FROM stops
 WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
       stops.stp_type = 'PUP' AND
       stops.stp_sequence = (SELECT MIN(stp_sequence)
                               FROM stops
                              WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
                                    stops.stp_type = 'PUP')

UPDATE #temp
   SET unload_comment = stops.stp_comment
  FROM stops
 WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
       stops.stp_type = 'DRP' AND
       stops.stp_sequence = (SELECT MAX(stp_sequence)
                               FROM stops
                              WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
                                    stops.stp_type = 'DRP')

UPDATE #temp
   SET iva_tax = ISNULL(gi_string1, '0'),
       retention_tax = ISNULL(gi_string2, '0')
  FROM generalinfo
 WHERE gi_name = 'PODFormat04Taxes'

--select car_id, car_name from carrier
--datos del carrier

UPDATE #temp 
   SET nombre_carrier = carrier.car_name
  FROM carrier
 WHERE #temp.ord_carrier = carrier.car_id 

SET NOCOUNT ON
--- inserta en la tabla de eventos la informacion de las paradas
INSERT INTO #eventos
select stp_sequence,stp_event, cmp_name, cty_nmstct, stp_description, stp_weight
from  stops, city 
where ord_hdrnumber = @ord_hdrnumber and
      cty_code = stp_city
order by 1
-- lee cada uno de los renglones de las paradas para hacer una sola linea.
-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  #eventos )
	BEGIN --A Si hay movimientos de posiciones-- Se declara un curso para ir leyendo la tabla de paso
			select @v_todoseventos	=	''
				DECLARE eventos_cursor CURSOR FOR 
				SELECT renglon, evento,compañia,ciudad,producto,peso
				FROM #eventos 
					OPEN eventos_cursor 
					FETCH NEXT FROM eventos_cursor INTO @V_renglon, @V_evento, @V_compañia, @V_ciudad, @V_producto, @V_peso
					WHILE @@FETCH_STATUS = 0 
					BEGIN -- del cursor --B
						--SELECT @V_evento, @V_compañia, @V_ciudad, @V_producto, @V_peso	
						Select	@v_todoseventos	= @v_todoseventos +' (' +Convert(char(1),@V_renglon) +') '+ IsNull(@V_evento,'')+ ' '+ IsNull(@V_compañia,'')+' '+IsNull(@V_ciudad,'')+' '+ IsNull(@V_producto,'')+' '+ IsNull(@V_peso,'')
					
				FETCH NEXT FROM eventos_cursor INTO @V_renglon, @V_evento, @V_compañia, @V_ciudad, @V_producto, @V_peso
			END -- del curso --B
			CLOSE eventos_cursor 
			DEALLOCATE eventos_cursor 
	END --A

UPDATE #temp 
   SET todoseventos = @v_todoseventos
  FROM orderheader 
 WHERE #temp.ord_number = @ord_hdrnumber
SET NOCOUNT OFF

--Leer los datos del % del iva y retencion, y el tipo de moneda

select @V_datomoneda = ord_currency from orderheader where ord_hdrnumber = @ord_hdrnumber;

select @V_datoiva =(cast(ISNULL(gi_string1,'0') as dec)/100) , 
@V_datoretencion = (cast(ISNULL(gi_string2,'0') as dec)/100) 
  FROM generalinfo
 WHERE gi_name = 'PODFormat04Taxes';


-- Toma en cuenta los cargos para saber que impuesto se aplica
--(evento, cargo, tax1, tax2)
Insert INTO #cargos
	SELECT A.cht_itemcode, A.ivd_charge,
		   B.cht_taxtable1, B.cht_taxtable2 
	FROM invoicedetail A, chargetype B
	WHERE	ord_hdrnumber = @ord_hdrnumber and
			A.cht_itemcode = B.cht_itemcode 
and b.cht_itemcode not in ('DEL','PST','GST')
	UNION 
	SELECT	A.cht_itemcode, A.ord_charge,
			B.cht_taxtable1, B.cht_taxtable2 
	FROM orderheader A, chargetype B
	WHERE	ord_hdrnumber = @ord_hdrnumber and
			A.cht_itemcode = B.cht_itemcode 
and b.cht_itemcode not in ('DEL','PST','GST')




-- Revisa que exista gastos de la orden
If Exists ( Select count(*) From  #cargos )
	BEGIN --A Si hay movimientos de posiciones-- Se declara un curso para ir leyendo la tabla de paso
			SELECT @V_ivacargo		 =	0.00
			SELECT @V_retcargo		 =	0.00
			SELECT @V_montomaniobras =  0.00
			SELECT @V_montocasetas	 =  0.00

				DECLARE cargos_cursor CURSOR FOR 
				SELECT tipocargo, cargo, tax1, tax2
				FROM #cargos 
					OPEN cargos_cursor 
					FETCH NEXT FROM cargos_cursor INTO @V_Tipocargo, @V_montocargo,  @V_tieneiva, @V_tieneret
					WHILE @@FETCH_STATUS = 0 
					BEGIN -- del cursor --B
						-- revisa si afecta IVA
						IF 	@V_tieneiva = 'Y'
						Begin
							SELECT @V_ivacargo	=	@V_ivacargo + @V_montocargo*0.16
						end
						-- revisa si afecta retencion
						IF @V_tieneret = 'Y'
						Begin
							SELECT @V_retcargo	=	@V_retcargo + @V_montocargo*0.04
						end
						-- suma las maniobras
						IF @V_Tipocargo = 'MANTON' OR @V_Tipocargo = 'MORET' OR @V_Tipocargo = 'MODESC' OR
						   @V_Tipocargo = 'MOCARG' OR @V_Tipocargo = 'MOIVA' OR @V_Tipocargo = 'MSINR' 
							Begin
								SELECT @V_montomaniobras = @V_montomaniobras + @V_montocargo
							End

						-- Suma las casetas/autopistas, se restan en la impresion de la carta porte...
						-- al monto de Ord_accessorial_chrg
						IF @V_Tipocargo = 'CASIVA' OR @V_Tipocargo = 'CAS' OR @V_Tipocargo = 'CASRET' 
							Begin
								SELECT @V_montocasetas	=	@V_montocasetas + @V_montocargo
							End	
					
				FETCH NEXT FROM cargos_cursor INTO  @V_Tipocargo, @V_montocargo, @V_tieneiva, @V_tieneret	
			END -- del curso --B
			CLOSE cargos_cursor 
			DEALLOCATE cargos_cursor 
	END --A


UPDATE #temp 
   SET	iva_total		 = @V_ivacargo, 
		retencion_total  = @V_retcargo,
		maniobras_total	 = @V_montomaniobras,
		autopistas_total = @V_montocasetas
  FROM orderheader 
 WHERE #temp.ord_number = @ord_hdrnumber

-- Suma los montos para sacar el dato final

Select @V_montototal = (charge + ord_accessorial_chrg +iva_total - retencion_total)
FROM #temp
WHERE #temp.ord_number = @ord_hdrnumber

exec sp_cantidadenletraspormonto @V_montototal,@V_datomoneda,@V_cantidadletras out

UPDATE #temp 
   SET	montoenletra = @V_cantidadletras
  FROM orderheader 
 WHERE #temp.ord_number = @ord_hdrnumber


-- Cuando la empresa requiera que la carta porte salga con monto ceros se pone aqui
UPDATE #temp
Set billto_credit_terms = '', rate = 0.00, 
charge = 0.00, ord_accessorial_chrg = 0.00, toll_charge = 0.00, montoenletra = '',
iva_total = 0.00, retencion_total = 0.00, maniobras_total = 0.00, autopistas_total = 0.00
WHERE #temp.ord_billto in( 'SCHENKER','MEASIA','CHROBINS','WERNER', 'JANEL','CARYSERV','UNIVRSAL')

-- ordenes de Paulina
IF @ord_hdrnumber = 155247
	BEGIN
		UPDATE #temp
		Set 
		charge = 8600.00, ord_accessorial_chrg = 850.00, 
		toll_charge = 0.00,
		iva_total = 1512.00, retencion_total = 344.00, 
	    maniobras_total = 850.00, autopistas_total = 0.00
		WHERE #temp.ord_number = @ord_hdrnumber

		--exec sp_cantidadenletraspormonto 10367.80,'MX$',@V_cantidadletras out

		UPDATE #temp 
		   SET	montoenletra = '(**DIEZ MIL SEISCIENTOS DIEZ Y OCHO  PESOS  00/100 M.N**)'
		  FROM orderheader 
		 WHERE #temp.ord_number = @ord_hdrnumber

	END


-- Proceso de paso para las ordenes de Paulina
-- le mando el valor de la unidad y de la caja
IF @ord_hdrnumber = 111111111
BEGIN

	Select @VP_orden	= 154356
	Select @VP_unidad	= '883'
	Select @VP_caja		= '53102'
	Select @VP_Ope		= 'AGUVA'
	select @VP_placasU  =  trc_licnum from  tractorprofile where trc_number = @VP_unidad;
	select @VP_placasT  =  trl_licnum from  trailerprofile where trl_number = @VP_caja;

	select @VP_nombre = mpp_firstname, @VP_apellidos = mpp_lastname,@VP_licencia = mpp_licensenumber  
	from manpowerprofile where mpp_id = @VP_Ope ;

	UPDATE #temp
	Set ord_number		= @VP_orden, 
	tractor				= @VP_unidad, 
	trailer				= @VP_caja, 
	driver				= @VP_Ope , 
	driver_firstname	= @VP_nombre , 
	driver_lastname		= @VP_apellidos, 
	tractor_license		= @VP_placasU , 
	trailer_license		= @VP_placasT,
	driver_license		= @VP_licencia
	WHERE #temp.ord_number = @ord_hdrnumber
END



/* FINAL SELECT - FORMS RETURN SET */  
SELECT *  
  FROM #temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 
   SELECT @ret_value = @@ERROR
  
RETURN @ret_value  
--- hasta aqui

GO
