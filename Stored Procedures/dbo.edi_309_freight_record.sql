SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

	CREATE PROCEDURE [dbo].[edi_309_freight_record] @p_ord_number varchar(16),@p_fgt_number int,@p_e309batch int,@p_mov_number int,@p_cbp_stop int,@shipper varchar(8)
	/**
	 * 
	 * NAME:
	 * dbo.edi_309_freight_record
	 *
	 * TYPE:
	 * Stored Procedure
	 *
	 * DESCRIPTION:
	 * This procedure creates the 309 freight detail records
	 *
	 * RETURNS:
	 * A return value of zero indicates success. A non-zero return value
	 * indicates a failure of some type
	 *
	 * RESULT SETS: 
	 * none.
	 *
	 * PARAMETERS:
	 * 001 - @p_ord_number, varchar(16), input, null;
	 *       This parameter indicates the order number or SCN for the freight 
	 *
	 * 002 - @p_fgt_nbumber, int input, not null;
	 *       This parameter indicates the number of the freight detail record being processed.
	 * 003 - @p_e309batch, int, input,not null;
	 *       This parameter indicates the 309 document batch number input not null;
	 * 004 - @p_mov_number, int input not null;
	 *	 This parameter indicates the move number for the trip being processed.
	 * 005 - @p_cbp_stop int input not null;
	 * 	 This parameter indicates the stop number for the border crossing.
	 *
	 * REFERENCES:
	 * 001 - dbo.
	 * 
	 * REVISION HISTORY:
	 * 02/24/2006.01 - A.Rossman - Initial release.
	 * 04/10/2006.02 - A.Rossman - PTS32515 -  Added Hazmat information to the end of the record.
	 * 04/18/2006.03 - A.Rossman - PTS32601 - Added Broker download info as misc type record. Also, added inbond data.
	 * 07/06/2006.04 - A.Rossman - PTS33469 - Allow for the broker download to be enabled by 
	 *				setting the brokder filer number on the company profile; Added input parameter of cbp_stop.
	 * 08/16/2006.05 - A. Rossman - PTS34110 - Set precedence for using count,Qty and Volume amounts and units.
	 * 01/10/2007.06 - A. Rossman - PTS 35740 - Set the BOL code to 85 for Household goods when a reference is attached to freight detail with an edicode of HHG
	*									- Output miscellaneous type records based on existance of VIN referencenumbers.  This is for hauling autos cross-border. 		
	* 05/20/2007.07 - A.Rossman - PTS 37484 - Added shipper parm to allow for schedule k code based on shipper city.
	* 07/30/2007.08 - A. Rossman - PTS 38646 - updated logic for freight  value.
	* 11/05/2007.09 - A. Rossman - PTS 40194 - Updated freight description retrieval/output.
	* 07/03/2008.10 - A. Rossman - PTS 43499 - updated bol type indicators to included CF7523(83),CF3299(85),CF3311(84)
	* 10/04/2008.11 - A. Rossman - PTS 44679 - Allow for New GI Setting to default Qty and Unit.
	* 01/09/2009.12 - A.Rossman - PTS45638 - Swap volume for weight when there is a zero qty in weight field. (PTS45950 - Default weight units)
	 *
	 **/


	 AS

	 DECLARE @v_fgtval Money, @v_filerno varchar(15),@v_declaredval varchar(10),@v_harmonizedcode varchar(20),@v_boltype varchar(2)
	 DECLARE @v_broker varchar(8)
	 DECLARE @v_count int,@v_quantity int,@v_volume int,@v_countunit varchar(6),@v_quantityunit varchar(6), @v_volumeunit varchar(6),@v_pkgunit varchar(6)
	 DECLARE @vin_counter int, @vin_loop_count int,@curr_vin varchar(30)
	 DECLARE @v_schedk varchar(5),@v_province varchar(6),@v_receiverid varchar(30)
	 DECLARE @v_usedefault char(1),@v_defaultUnit varchar(6),@v_defaultQty Int		--PTS#44679
	 DECLARE @v_swapweight char(1),@v_weight int,@v_weightunit varchar(6)			--PTS#45638


	  CREATE TABLE #309_freight 
	  (
			SCN		varchar(16) NULL,
			loading_point	varchar(8) NULL,
			fgt_description	varchar(45) NULL,
			fgt_count	int	   NULL,
			fgt_packageunit varchar(6) NULL,
			fgt_weight	int	   NULL,
			fgt_weightunit	varchar(6) NULL,
			marks_and_numbers varchar(30) NULL,
			release_no	varchar(30) NULL,
			shipment_val	varchar(10)    NULL,
			country		varchar(2)  NULL,
			currency	varchar(3)  NULL,
			hazmat_code	varchar(10) NULL,	--32515
			hazmat_contact  varchar(30) NULL,	--32515
			hazmat_phone	varchar(30) NULL,	--32515
			bol_type	varchar(2) NULL 
	  )	

	 /*PTS 35740  Add table for VIN numbers */

	 CREATE TABLE #VIN
	 (		primary_key int IDENTITY(1,1) NOT NULL,
			vin		varchar(30)	NULL
	 )		

	 /****Get GI Setting Values ****/
	 SELECT	@v_receiverid = UPPER(ISNULL(gi_string1,'CBP-ACE-TEST'))
	 FROM	generalinfo
	 WHERE	gi_name = 'ACE:ReceiverID'

	 SELECT @v_usedefault = LEFT(UPPER(ISNULL(gi_string1,'N')),1)
	 FROM	generalinfo
	 WHERE	gi_name = 'ACE:DefaultManifestQty'
	 
	 --PTS 45638 Aross
	 SELECT	@v_swapweight = LEFT(UPPER(ISNULL(gi_string1,'N')),1)
	 FROM		generalinfo
	 WHERE	gi_name = 'ACE:ApplyVolumeforZeroWeight'

	 /**** End GI Settings Retrieval ****/

	 /*PTS 37484 AROSS - Added logic to get schedule K from the shipper */
	 SELECT	@v_province = cty_state
	FROM		city
			INNER JOIN company
				ON cmp_city = cty_code
	WHERE	cmp_id =  @shipper

	SELECT @v_schedk =  CASE @v_province
								WHEN 'AB' THEN '80101'
								WHEN 'MB' THEN '80102'
								WHEN 'SK'  THEN '80103'
								WHEN 'BC' THEN '80106'
								WHEN 'ON' THEN '80107'
								WHEN 'PQ' THEN '80108'
								WHEN 'QC' THEN '80108'				
								WHEN 'NB' THEN '80110'
								WHEN 'YT' THEN '80105'
								WHEN 'PE' THEN '80111'
								WHEN 'NS' THEN '80109'
								WHEN 'NF' THEN '80112'
								WHEN 'NT' THEN '80104'
								ELSE '09000'
							END	
	/* CBP TEST will only allow 01822 for schedule K code */
	IF @v_receiverid = 'CBP-ACE-TEST'
		SELECT @v_schedk = '01822'

	/*END 37484		*/			



	 --updated to get fgt_value based on associated freight value.  Aross::PTS 38646
	  SELECT @v_fgtval =  orderheader.ord_cmdvalue
	  FROM
	  orderheader
	  INNER JOIN stops
			ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
	  INNER JOIN freightdetail
		ON freightdetail.stp_number =  stops.stp_number
	WHERE freightdetail.fgt_number = @p_fgt_number


	 --SELECT @v_fgtval = ISNULL(ord_cmdvalue,0)
	 --FROM	orderheader 
	 --WHERE mov_number = @p_mov_number

	 IF @v_fgtval > 0 and @v_fgtval < 200
		SELECT @v_declaredval = RIGHT(convert( varchar(12),convert(int,(ISNULL(@v_fgtval,0.00))*100)),9),
			@v_boltype = '13'
	 ELSE
		SET @v_declaredval = ' '

	 /*Aross PTS 32601 - Set the value if there is inbond data associated with the fgt_number */
	 IF EXISTS (SELECT 1 from ace_inbond_data where fgt_number = @p_fgt_number)
		SELECT @v_declaredval = RIGHT(convert( varchar(12),convert(int,(ISNULL(@v_fgtval,0.00))*100)),9)


	 INSERT INTO #309_freight
		SELECT @p_ord_number,
			ISNULL(@v_schedk,'09000'),
			ISNULL(UPPER(LEFT(fgt_description,45)),ISNULL(UPPER(LEFT(cm.cmd_name,45)),'UNKNOWN')),
			ISNULL(fgt_count,0),
			CASE fgt_packageunit
				WHEN Null Then fgt_countunit
				WHEN 'UNK' Then fgt_countunit
				ELSE fgt_packageunit
			END,
			ISNULL(fgt_weight,0),
			CASE fgt_weightunit
				WHEN null THEN 'LBS'
				WHEN 'UNK' THEN 'LBS'
				ELSE fgt_weightunit
			END,
			' ',
			' ',
			@v_declaredval,
			' ',
			'USD',
			ISNULL(cm.cmd_haz_num,' '),
			ISNULL(cm.cmd_haz_contact,' '),
			ISNULL(cm.cmd_haz_telephone,' '),
			'00'
		FROM freightdetail fd
			JOIN commodity cm
				ON fd.cmd_code = cm.cmd_code
		WHERE	fgt_number = @p_fgt_number

	 /* Retreive the count,qty and volume amounts and qulifiers and update the temp table accordingly.  Hierarchy is: Count,QTY,Volume.  Package units will be applied when present. */
	 SELECT	@v_count = ISNULL(fgt_count,0),
			@v_quantity = ISNULL(fgt_quantity,0),
			@v_volume = ISNULL(fgt_volume,0),
			@v_countunit = ISNULL(fgt_countunit,'UNK'),
			@v_volumeunit = ISNULL(fgt_volumeunit,'UNK'),
			@v_pkgunit = ISNULL(fgt_packageunit,'UNK'),
			@v_weight = ISNULL(fgt_weight,0),		--45638
			@v_weightunit = ISNULL(fgt_weightunit,'LBS') --45638
	 FROM	freightdetail
	 WHERE	fgt_number = @p_fgt_number

	/* AROSS PTS 34110 - Apply updates to count and count units for manifest based on the following order fgt_count,fgt_quantity,fgt_volume.  Use count whenever possible. */
	IF @v_count > 0
		UPDATE #309_freight SET fgt_count = @v_count,fgt_packageunit = CASE @v_pkgunit  WHEN 'UNK' THEN @v_countunit ELSE @v_pkgunit END

	IF @v_quantity > 0 AND @v_count <= 0
		UPDATE #309_freight SET fgt_count = @v_quantity,fgt_packageunit = CASE @v_pkgunit  WHEN 'UNK' THEN @v_countunit ELSE @v_pkgunit END

	IF @v_volume > 0 AND @v_count <= 0
		UPDATE #309_freight SET fgt_count = @v_volume,fgt_packageunit = CASE @v_pkgunit  WHEN 'UNK' THEN @v_volumeunit ELSE @v_pkgunit END

	/* END PTS 34110 */		
	
	-- AR:PTS 45950 Set weight units to 'LBS' if it is UNK
	IF @v_weightunit = 'UNK'
		SET @v_weightunit = 'LBS'
		
	
	/* PTS 45638 Aross */
	IF @v_swapweight = 'Y'
	BEGIN
		IF @v_weight <= 0
			UPDATE #309_freight SET fgt_weight =  @v_volume ,
				fgt_weightunit = CASE @v_volumeunit 
								WHEN  'L'  THEN   @v_volumeunit
								WHEN 'G'  THEN	@v_volumeunit
								ELSE	@v_weightunit
							    END
							 
	END						 
							 
	--PTS 45638 END
	
	--PTS#44679 Begin 
	IF (SELECT ISNULL(@v_usedefault,'N'))  = 'Y'
	BEGIN
		SELECT @v_defaultUnit = LEFT(UPPER(ISNULL(gi_string2,'PCS')),3),
				   @v_defaultQty = ISNULL(gi_integer1,1)
		FROM	  generalinfo
		WHERE	gi_name = 'ACE:DefaultManifestQty'

		--verify the Qty is a valid amount.  Must be at least 1
		IF @v_defaultQty < 1
			SET @v_defaultQty = 1
			
		--update quantities based on supplied input
		UPDATE #309_freight 
		SET	 fgt_count =  @v_defaultQty,
				fgt_packageunit = @v_defaultUnit

	END
	--PTS#44679 End



	--Update the marks and Numbers 	
	  UPDATE #309_freight
	  SET	marks_and_numbers = ref_number
	  FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
	  WHERE	ref_tablekey = @p_fgt_number
		AND ref_table = 'freightdetail'
		AND edicode = 'MARKS'
		AND labeldefinition = 'ReferenceNumbers'

	 --Update the CBP RELEASE NUMBER 	 c4 line release for BRASS shipments
	  UPDATE #309_freight
	  SET	release_no = ref_number
	  FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
	  WHERE	ref_tablekey = @p_fgt_number
		AND ref_table = 'freightdetail'
		AND edicode = 'CBPREL'
		AND labeldefinition = 'ReferenceNumbers' 	

	--Update the country of origin for section 321
	  UPDATE #309_freight
	  SET	country = ref_number
	  FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
	  WHERE	ref_tablekey = @p_fgt_number
		AND ref_table = 'freightdetail'
		AND edicode = 'COO'
		AND labeldefinition = 'ReferenceNumbers' 	

	 /*update the boltype for section 321,BRASS and PAPS loads */
	IF (SELECT release_no FROM #309_freight) <> ' '	--set the BRASS bol type
		SET @v_boltype = '24'

	SELECT @v_boltype = ISNULL(@v_boltype,'00')

	/* PTS 35740  Set BOL type for HouseHold Goods */
	IF (SELECT COUNT(*) FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
		WHERE	ref_tablekey =  @p_fgt_number
			AND ref_table = 'freightdetail'
			AND edicode  = 'HHG'
			AND labeldefinition = 'ReferenceNumbers') > 0

			SET	@v_boltype = '85'
	/* end PTS 35740	*/
	/*PTS 43499*/
	IF (SELECT COUNT(*) FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
		WHERE	ref_tablekey =  @p_fgt_number
			AND ref_table = 'freightdetail'
			AND edicode = ('CF3299')
			AND labeldefinition = 'ReferenceNumbers') > 0

			SET	@v_boltype = '85'

	IF (SELECT COUNT(*) FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
		WHERE	ref_tablekey =  @p_fgt_number
			AND ref_table = 'freightdetail'
			AND edicode = ('CF3311')
			AND labeldefinition = 'ReferenceNumbers') > 0

			SET	@v_boltype = '84'

	IF (SELECT COUNT(*) FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
		WHERE	ref_tablekey =  @p_fgt_number
			AND ref_table = 'freightdetail'
			AND edicode = ('CF7523')
			AND labeldefinition = 'ReferenceNumbers') > 0

			SET	@v_boltype = '83'

	/*END 43499*/
	/* updates for VIN segments PTS35740 */
	IF (SELECT COUNT(*) FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
		WHERE	ref_tablekey =  @p_fgt_number
			AND ref_table = 'freightdetail'
			AND edicode = 'VIN'
			AND labeldefinition = 'ReferenceNumbers') > 0

			INSERT INTO #VIN(vin)
			SELECT ref_number
			FROM 	referencenumber
				JOIN labelfile
					ON abbr = ref_type
			WHERE	ref_tablekey = @p_fgt_number		
				AND	ref_table =  'freightdetail'
				AND 	edicode = 'VIN'

			SET @vin_loop_count = ISNULL((SELECT COUNT(*) FROM #VIN),0)
			SET @vin_counter = 1




	/*IF (SELECT COUNT(*)  FROM referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
	  WHERE	ref_tablekey = @p_ord_number
		AND ref_table = 'orderheader'
		AND abbr = 'PAPS'
		AND labeldefinition = 'ReferenceNumbers') > 0
		SET @v_boltype = '34'
	*/
	UPDATE #309_freight
	SET	bol_type = @v_boltype



	 /*output the record to the edi_309 table */

	 INSERT INTO edi_309(data_col,batch_number,mov_number)
		SELECT '6|10|'+
			SCN + '|' +
			loading_point + '|' +
			fgt_description + '|' +
			CAST(fgt_count as varchar(10))+ '|' +
			fgt_packageunit + '|' +
			CAST(fgt_weight as varchar(10))+ '|' +
			fgt_weightunit +'|' +
			marks_and_numbers + '|' +
			release_no +'|'+
			shipment_val +'|' +
			country +'|'+
			currency + '|' +
			hazmat_code + '|' +
			hazmat_contact +'|' +
			hazmat_phone + '|'+
			bol_type +'|||',
			@p_e309batch,
			@p_mov_number
		FROM	#309_freight


	 /*PTS 35470 add VIN Misc records */
	 WHILE @vin_loop_count > 0 AND @vin_counter <= @vin_loop_count
	 BEGIN
		SELECT @curr_vin =  vin
		FROM	#vin
		WHERE primary_key =  @vin_counter

		INSERT INTO edi_309(data_col,batch_number,mov_number)
			VALUES('7|10|VIN||' + @curr_vin +'|||',
					@p_e309batch,
					@p_mov_number)

		SET @vin_counter =  @vin_counter + 1
	 END
	 /* END PTS 35740  VIN Logic */

	/*PTS 32601 - Aross - Add the broker's filer number as a mist type record if it is supplied. */ 		

	 SELECT @v_broker  =  cmp_id	--get the broker company code from the border event stop
	 FROM	stops
	 WHERE	stp_number = @p_cbp_stop

	 /*retrieve the brokers filer code from the company profile if it exists */
	 SELECT	@v_filerno = ISNULL(cmp_aceid,' ')
	 FROM 	company
		JOIN	labelfile
		    ON abbr =  cmp_aceidtype
	 WHERE	cmp_id = @v_broker
		AND edicode = '8S'

	 /*filer codes entered as freight reference numbers will take precedence over the company profile codes */
	 SELECT @v_filerno = ref_number
	 FROM	referencenumber
		INNER JOIN labelfile
			ON labelfile.abbr = referencenumber.ref_type
	 WHERE	ref_tablekey = @p_fgt_number
		AND ref_table = 'freightdetail'
		AND edicode = '8S'
		AND labeldefinition = 'ReferenceNumbers'

	 /* CBP Test will only accept one filer code */
	 IF @v_receiverid = 'CBP-ACE-TEST'
		SELECT @v_filerno = ' '
	 /*END 37484 	*/	


	 --if there is a filer code present insert the record.
	 IF (SELECT ISNULL(@v_filerno,' ')) <> ' ' AND NOT EXISTS(SELECT 1 FROM edi_309 WHERE LEFT(data_col,8) = '7|10|BRO' and batch_number = @p_e309batch)
		INSERT INTO edi_309(data_col,batch_number,mov_number)
			VALUES( '7|10|BROKER|8S|'+ @v_filerno +'|',
				 @p_e309batch,
				 @p_mov_number )


	 /* Add in-bond information record if needed PTS 32601 */			
	 If (SELECT COUNT(*) FROM ace_inbond_data WHERE fgt_number = @p_fgt_number) > 0
		BEGIN
			 SELECT @v_harmonizedcode = ref_number
			 FROM	referencenumber
				INNER JOIN labelfile
					ON labelfile.abbr = referencenumber.ref_type
			 WHERE	ref_tablekey = @p_fgt_number
				AND ref_table = 'freightdetail'
				AND edicode = 'HTC'
		AND labeldefinition = 'ReferenceNumbers'

			INSERT INTO edi_309(data_col,batch_number,mov_number)
			SELECT '8|10|' +
				ISNULL(aid_entry_type,' ') + '|' +
				ISNULL(aid_entryno,' ') + '|' +
				ISNULL(aid_controlno,' ') + '|' +
				ISNULL(aid_usport,' ') +'|' +
				ISNULL(aid_foreignport,' ') + '|' +
				ISNULL(aid_scac_forward,' ') + '|' +
				ISNULL(aid_fda_flag,'N') +'|' +
				CONVERT( VARCHAR(8),aid_departure,112)+'|' +
				ISNULL(@v_harmonizedcode,' ') +'|' +
				ISNULL(aid_firms_code,' ')+'|' +
				ISNULL(aid_bonded_carrier,' ') +'|',
				@p_e309batch,
				@p_mov_number
			FROM	ace_inbond_data
			WHERE	fgt_number = @p_fgt_number


		END	


GO
GRANT EXECUTE ON  [dbo].[edi_309_freight_record] TO [public]
GO
