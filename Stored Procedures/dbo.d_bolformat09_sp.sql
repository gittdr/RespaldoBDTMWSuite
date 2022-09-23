SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_bolformat09_sp] (@ord_hdrnumber int, @mov_number int)
--Parameters should be used mutually exclusively
AS
	SELECT	oh.ord_number order_number,
			ISNULL(oh.ord_remark, '') order_remark,
			creditterms.name,
			oh.ord_startdate ship_date, 
			e.evt_trailer1 trailer,
			shipper.cmp_name shipper_name,
			shipper.cmp_address1 shipper_address,
			shippercity.cty_name shipper_city,
			shippercity.cty_state shipper_state,
			CASE 
				WHEN shipper.cmp_zip IS NULL THEN shippercity.cty_zip
				ELSE shipper.cmp_zip
			END shipper_zip,
			ISNULL(shipper.cmp_primaryphone, '') shipper_phone,
			consignee.cmp_name consignee_name,
			consignee.cmp_address1 consignee_address,
			consigneecity.cty_name consignee_city,
			consigneecity.cty_state consignee_state,
			CASE 
				WHEN consignee.cmp_zip IS NULL THEN consigneecity.cty_zip
				ELSE consignee.cmp_zip
			END consignee_zip,
			ISNULL(consignee.cmp_primaryphone, '') consignee_phone,
			SUM(f.fgt_count) freight_count,
			SUM(f.fgt_weight) freight_weight,
			oh.ord_hdrnumber ord_hdrnumber,
			s.lgh_number lgh_number
	  FROM	stops s
				INNER JOIN orderheader oh ON s.ord_hdrnumber = oh.ord_hdrnumber
				INNER JOIN event e ON s.stp_number = e.stp_number AND e.evt_sequence = 1
				INNER JOIN company shipper ON oh.ord_shipper = shipper.cmp_id
				INNER JOIN city shippercity ON shipper.cmp_city = shippercity.cty_code
				INNER JOIN company consignee ON s.cmp_id = consignee.cmp_id
				INNER JOIN city consigneecity ON consignee.cmp_city = consigneecity.cty_code
				INNER JOIN freightdetail f ON s.stp_number = f.stp_number
				INNER JOIN labelfile creditterms ON oh.ord_terms = creditterms.abbr AND creditterms.labeldefinition = 'CreditTerms'
	 WHERE	s.stp_type = 'DRP' AND
			((oh.ord_hdrnumber = @ord_hdrnumber and @ord_hdrnumber <> 0) OR
			(s.mov_number = @mov_number and @mov_number <> 0))
	GROUP BY
		oh.ord_number,
		oh.ord_remark,
		creditterms.name,
		oh.ord_startdate, 
		e.evt_trailer1,
		shipper.cmp_name,
		shipper.cmp_address1,
		shippercity.cty_name,
		shippercity.cty_state,
		CASE 
			WHEN shipper.cmp_zip IS NULL THEN shippercity.cty_zip
			ELSE shipper.cmp_zip
		END,
		shipper.cmp_primaryphone,
		consignee.cmp_name,
		consignee.cmp_address1,
		consigneecity.cty_name,
		consigneecity.cty_state,
		CASE 
			WHEN consignee.cmp_zip IS NULL THEN consigneecity.cty_zip
			ELSE consignee.cmp_zip
		END,
		consignee.cmp_primaryphone,
		oh.ord_hdrnumber,
		s.lgh_number
GO
GRANT EXECUTE ON  [dbo].[d_bolformat09_sp] TO [public]
GO
