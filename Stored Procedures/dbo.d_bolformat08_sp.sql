SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_bolformat08_sp] (@ord_hdrnumber int, @mov_number int)
--Parameters should be used mutually exclusively
AS

DECLARE @tmwuser varchar(255)
DECLARE @mode varchar(5)


SET @ord_hdrnumber = isnull(@ord_hdrnumber, 0)
SET @mov_number = isnull(@mov_number, 0)

IF @ord_hdrnumber > 0 BEGIN
	SET @mode = 'BYORD'
END
ELSE IF @mov_number > 0 BEGIN
	SET @mode = 'BYMOV'
END 

EXEC @tmwuser = dbo.gettmwuser_fn

SELECT 			oh.ord_origin_latestdate,
				oh.ord_hdrnumber,
				replicate(' ', 30) as ref_number1,
				replicate(' ', 30) as ref_number2,
				oh.ord_shipper as shipper_cmp_id,
				replicate(' ', 100) as shipper_cmp_name,
				replicate(' ', 100) as shipper_cmp_address1,
				replicate(' ', 100) as shipper_cmp_address2,
				replicate(' ', 25) as shipper_cmp_nmstct,
				replicate(' ', 10) as shipper_cmp_zip,
				replicate(' ', 20) as shipper_cmp_primaryphone,
				oh.ord_consignee as consignee_cmp_id,
				replicate(' ', 100) as consignee_cmp_name,
				replicate(' ', 100) as consignee_cmp_address1,
				replicate(' ', 100) as consignee_cmp_address2,
				replicate(' ', 25) as consignee_cmp_nmstct,
				replicate(' ', 10) as consignee_cmp_zip,
				replicate(' ', 20) as consignee_cmp_primaryphone,
				replicate(' ', 100) as tss_company_name,
				replicate(' ', 255) as tss_company_address,
				replicate(' ', 255) as tss_company_logo,
				oh.ord_remark,
				fd.fgt_count, 
				fd.fgt_countunit,
				fd.fgt_description,
				fd.fgt_weight,
				fd.fgt_quantity,
				fd.fgt_unit as fgt_quantity_unit,
				fd.fgt_count2,
				fd.fgt_count2unit,
				fd.fgt_sequence,
				CAST('1950-01-01' as datetime) as dateshipped, 
				lgh.mov_number,
				@tmwuser as userid,
				oh.ord_number,
				cm.cmd_class,
				stp.cmp_id as stop_comp_id,
				stp.mfh_number,
				stp.stp_mfh_sequence,
				lgh.lgh_number,
				stp.stp_arrivaldate,
				'ICC/MC 167401' as icc_mc_number,
				lgh.mov_number as mov_number_printed, 
				stp.stp_event as stp_event	/* 07/28/2009 MDH PTS 47425: Added for filtering at BOL level. */
INTO 			#boltemp
from legheader lgh left outer join stops stp on lgh.mov_number = stp.mov_number
		--left outer join orderheader oh on oh.mov_number = lgh.mov_number
		left outer join orderheader oh on oh.ord_hdrnumber = stp.ord_hdrnumber
		inner join eventcodetable evt on (stp.stp_event = evt.abbr)
		inner join freightdetail fd on (stp.stp_number = fd.stp_number) 
		inner join commodity cm on (fd.cmd_code = cm.cmd_code)
WHERE 			(((oh.ord_hdrnumber = @ord_hdrnumber) and @ord_hdrnumber <> 0)
					OR ((lgh.mov_number = @mov_number) and @mov_number <> 0))
				AND (evt.fgt_event in ('DRP') OR evt.abbr = 'XDU')		/* 06/22/2009 MDH PTS 47425: Addded OR evt.evt_eventcode = 'XDU' */
ORDER BY 	stp.mfh_number, stp.stp_mfh_sequence

--ADD an additional record for the move so it's origin/destination can be modified independently
INSERT #boltemp
SELECT 			oh.ord_origin_latestdate,
				oh.ord_hdrnumber,
				replicate(' ', 30) as ref_number1,
				replicate(' ', 30) as ref_number2,
				oh.ord_shipper as shipper_cmp_id,
				replicate(' ', 100) as shipper_cmp_name,
				replicate(' ', 100) as shipper_cmp_address1,
				replicate(' ', 100) as shipper_cmp_address2,
				replicate(' ', 25) as shipper_cmp_nmstct,
				replicate(' ', 10) as shipper_cmp_zip,
				replicate(' ', 20) as shipper_cmp_primaryphone,
				oh.ord_consignee as consignee_cmp_id,
				replicate(' ', 100) as consignee_cmp_name,
				replicate(' ', 100) as consignee_cmp_address1,
				replicate(' ', 100) as consignee_cmp_address2,
				replicate(' ', 25) as consignee_cmp_nmstct,
				replicate(' ', 10) as consignee_cmp_zip,
				replicate(' ', 20) as consignee_cmp_primaryphone,
				replicate(' ', 100) as tss_company_name,
				replicate(' ', 255) as tss_company_address,
				replicate(' ', 255) as tss_company_logo,
				oh.ord_remark,
				fd.fgt_count, 
				fd.fgt_countunit,
				fd.fgt_description,
				fd.fgt_weight,
				fd.fgt_quantity,
				fd.fgt_unit as fgt_quantity_unit,
				fd.fgt_count2,
				fd.fgt_count2unit,
				fd.fgt_sequence,
				CAST('1950-01-01' as datetime) as dateshipped, 
				oh.mov_number,
				@tmwuser as userid,
				oh.ord_number,
				cm.cmd_class,
				stp.cmp_id as stop_comp_id,
				stp.mfh_number,
				stp.stp_mfh_sequence,
				0 as lgh_number,
				stp.stp_arrivaldate,
				'ICC/MC 167401' as icc_mc_number,
				oh.mov_number as mov_number_printed, 
				stp.stp_event as stp_event	/* 07/28/2009 MDH PTS 47425: Added for filtering at BOL level. */
FROM 			stops stp left outer join orderheader oh on (oh.ord_hdrnumber = stp.ord_hdrnumber) 
				inner join eventcodetable evt on (stp.stp_event = evt.abbr)
				inner join freightdetail fd on (stp.stp_number = fd.stp_number) 
				inner join commodity cm on (fd.cmd_code = cm.cmd_code)
WHERE 			(((oh.ord_hdrnumber = @ord_hdrnumber) and @ord_hdrnumber <> 0)
					OR ((stp.mov_number = @mov_number) and @mov_number <> 0))
				AND (evt.fgt_event in ('DRP') OR evt.abbr = 'XDU')		/* 06/22/2009 MDH PTS 47425: Addded OR evt.evt_eventcode = *'XDU' */ 
ORDER BY 	stp.mfh_number, stp.stp_mfh_sequence


UPDATE #boltemp
SET	tss_company_name = tss.tss_company_name,
	tss_company_address = tss.tss_company_address,
	tss_company_logo = tss.tss_company_logo
FROM  ttsusers usr inner join tripsheetselection tss on (usr.usr_type1 = tss.ord_revtype1)
WHERE	usr.usr_userid = @tmwuser


IF @mode = 'BYORD' BEGIN
	
	UPDATE #boltemp
	SET	#boltemp.ref_number1 = ( SELECT TOP 1 ref1.ref_number
					FROM 	referencenumber ref1
					WHERE	ref1.ref_tablekey = @ord_hdrnumber AND
						ref1.ref_table = 'orderheader' AND
						ref1.ref_sequence = 1)



	UPDATE	#boltemp
	SET	#boltemp.ref_number2 = ( SELECT TOP 1 ref1.ref_number
					FROM 	referencenumber ref1
					WHERE	ref1.ref_tablekey = @ord_hdrnumber AND
						ref1.ref_table = 'orderheader' AND
						ref1.ref_sequence = 2)

	UPDATE	#boltemp
	SET	#boltemp.dateshipped = (SELECT oh.ord_startdate
					FROM 	orderheader oh
					WHERE	oh.ord_hdrnumber = @ord_hdrnumber)
	
	UPDATE	#boltemp
	SET	shipper_cmp_name = shipper.cmp_name,
		shipper_cmp_address1 = shipper.cmp_address1, 
		shipper_cmp_address2 = shipper.cmp_address2,
		shipper_cmp_nmstct = shipper.cty_nmstct,
		shipper_cmp_zip = shipper.cmp_zip,
		shipper_cmp_primaryphone = shipper.cmp_primaryphone
	FROM #boltemp inner join company shipper on (#boltemp.shipper_cmp_id = shipper.cmp_id)

	UPDATE	#boltemp
	SET	consignee_cmp_name = consignee.cmp_name,
		consignee_cmp_address1 = consignee.cmp_address1, 
		consignee_cmp_address2 = consignee.cmp_address2,
		consignee_cmp_nmstct = consignee.cty_nmstct,
		consignee_cmp_zip = consignee.cmp_zip,
		consignee_cmp_primaryphone = consignee.cmp_primaryphone
	FROM #boltemp inner join company consignee on (#boltemp.consignee_cmp_id = consignee.cmp_id)

	UPDATE	#boltemp
	SET	mov_number_printed = stp.mov_number
	FROM stops stp 
	WHERE stp_number = (SELECT TOP 1 stpinner.stp_number
							FROM stops stpinner
							WHERE stpinner.ord_hdrnumber = #boltemp.ord_hdrnumber
									and isnull(stpinner.ord_hdrnumber, 0) <> 0
							ORDER BY stpinner.mfh_number desc, stpinner.stp_mfh_sequence desc)

		
END
ELSE IF @mode = 'BYMOV' BEGIN

	UPDATE	#boltemp
	SET	mov_number_printed = @mov_number,
		mov_number = @mov_number
	WHERE lgh_number = 0


	UPDATE	#boltemp
	SET	mov_number_printed = stp.mov_number
	FROM stops stp 
	WHERE stp_number = (SELECT TOP 1 stpinner.stp_number
							FROM stops stpinner
							WHERE stpinner.ord_hdrnumber = #boltemp.ord_hdrnumber
									and isnull(stpinner.ord_hdrnumber, 0) <> 0
							ORDER BY stpinner.mfh_number desc, stpinner.stp_mfh_sequence desc)
			and #boltemp.lgh_number > 0


	UPDATE #boltemp
	SET	#boltemp.ref_number1 = ( SELECT TOP 1 ref1.ref_number
					FROM 	referencenumber ref1
					WHERE	ref1.ref_tablekey = (SELECT TOP 1 stpinner.ord_hdrnumber 
							FROM stops stpinner
							WHERE (((stpinner.lgh_number = #boltemp.lgh_number) and (#boltemp.lgh_number > 0))
										OR ((stpinner.mov_number = #boltemp.mov_number) and (#boltemp.lgh_number = 0)))
									and isnull(stpinner.ord_hdrnumber, 0) <> 0
							ORDER BY stpinner.mfh_number, stpinner.stp_mfh_sequence)
					 AND ref1.ref_table = 'orderheader' 
					AND	ref1.ref_sequence = 1)



	UPDATE	#boltemp
	SET #boltemp.ref_number2 = ( SELECT TOP 1 ref1.ref_number
					FROM 	referencenumber ref1
					WHERE	ref1.ref_tablekey = (SELECT TOP 1 stpinner.ord_hdrnumber 
							FROM stops stpinner
							WHERE (((stpinner.lgh_number = #boltemp.lgh_number) and (#boltemp.lgh_number > 0))
										OR ((stpinner.mov_number = #boltemp.mov_number) and (#boltemp.lgh_number = 0)))
									and isnull(stpinner.ord_hdrnumber, 0) <> 0
							ORDER BY stpinner.mfh_number, stpinner.stp_mfh_sequence)
						 AND ref1.ref_table = 'orderheader' 
						AND	ref1.ref_sequence = 2)



	UPDATE	#boltemp
	SET	#boltemp.dateshipped = stp.stp_arrivaldate
	FROM stops  stp 
	where stp_number = (SELECT TOP 1 stpinner.stp_number
					FROM 	stops stpinner
					WHERE (stpinner.lgh_number = #boltemp.lgh_number and #boltemp.lgh_number > 0)
							OR (stpinner.mov_number = #boltemp.mov_number and #boltemp.lgh_number = 0)
					ORDER BY stpinner.mfh_number, stpinner.stp_mfh_sequence)
							
						
	UPDATE	#boltemp
	SET	shipper_cmp_id = shipper.cmp_id,
		shipper_cmp_name = shipper.cmp_name,
		shipper_cmp_address1 = shipper.cmp_address1, 
		shipper_cmp_address2 = shipper.cmp_address2,
		shipper_cmp_nmstct = shipper.cty_nmstct,
		shipper_cmp_zip = shipper.cmp_zip,
		shipper_cmp_primaryphone = shipper.cmp_primaryphone
	FROM stops stp inner join company shipper on (stp.cmp_id = shipper.cmp_id)
	WHERE stp_number = (SELECT TOP 1 stpinner.stp_number
							FROM stops stpinner
							WHERE (((stpinner.lgh_number = #boltemp.lgh_number) and (#boltemp.lgh_number > 0))
										OR ((stpinner.mov_number = #boltemp.mov_number) and (#boltemp.lgh_number = 0)))
							ORDER BY stpinner.mfh_number, stpinner.stp_mfh_sequence)

	UPDATE	#boltemp
	SET	consignee_cmp_id = consignee.cmp_id,
		consignee_cmp_name = consignee.cmp_name,
		consignee_cmp_address1 = consignee.cmp_address1, 
		consignee_cmp_address2 = consignee.cmp_address2,
		consignee_cmp_nmstct = consignee.cty_nmstct,
		consignee_cmp_zip = consignee.cmp_zip,
		consignee_cmp_primaryphone = consignee.cmp_primaryphone
	FROM stops stp inner join company consignee on (stp.cmp_id = consignee.cmp_id)
	WHERE stp_number = (SELECT TOP 1 stpinner.stp_number
							FROM stops stpinner
							WHERE 	(((stpinner.lgh_number = #boltemp.lgh_number) and (#boltemp.lgh_number > 0))
										OR ((stpinner.mov_number = #boltemp.mov_number) and (#boltemp.lgh_number = 0)))
							ORDER BY stpinner.mfh_number desc,stpinner.stp_mfh_sequence desc)
END 

SELECT * FROM #boltemp
ORDER BY 	lgh_number, mfh_number, stp_mfh_sequence

DROP TABLE #boltemp

GO
GRANT EXECUTE ON  [dbo].[d_bolformat08_sp] TO [public]
GO
