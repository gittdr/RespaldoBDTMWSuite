SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_bolformat03_sp] (@ord_hdrnumber int)
AS
/**
 * 
 * REVISION HISTORY:
 * 10/24/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
DECLARE
@varchar30	varchar(30)

Select @varchar30 = '                             '

select	oh.ord_origin_latestdate,
	oh.ord_hdrnumber,
	stops.stp_sequence,
	@varchar30 'ref_number',
	shipper.cmp_name 'shipper_cmp_name',
	shipper.cmp_address1 'shipper_cmp_address1',
	shipper.cmp_address2 'shipper_cmp_address2',
	shipper.cty_nmstct 'shipper_cmp_nmstct',
	shipper.cmp_zip 'shipper_cmp_zip',
	shipper.cmp_primaryphone 'shipper_cmp_primaryphone',
	consignee.cmp_name 'consignee_cmp_name',
	consignee.cmp_address1 'consignee_cmp_address1',
	consignee.cmp_address2 'consignee_cmp_address2',
	consignee.cty_nmstct 'consignee_cmp_nmstct',
	consignee.cmp_zip 'consignee_cmp_zip',
	consignee.cmp_primaryphone 'consignee_cmp_primaryphone',
	billto.cmp_name 'billto_cmp_name',
	billto.cmp_address1 'billto_cmp_address1',
	billto.cmp_address2 'billto_cmp_address2',
	billto.cty_nmstct 'billto_cmp_nmstct',
	billto.cmp_zip 'billto_cmp_zip',
	billto.cmp_primaryphone 'billto_cmp_primaryphone',
	dist.cmp_name 'dist_cmp_name',
	dist.cmp_address1 'dist_cmp_address1',
	dist.cmp_address2 'dist_cmp_address2',
	dist.cty_nmstct 'dist_cmp_nmstct',
	dist.cmp_zip 'dist_cmp_zip',
	oh.ord_company,
	ordby.cmp_name 'ordby_cmp_name',
	oh.ord_remark,
	oh.ord_distributor,
	oh.ord_revtype2,
	oh.ord_revtype4,
	oh.ord_driver1,
	oh.ord_tractor,
	oh.ord_trailer,
	fd.fgt_unit, 
	fd.fgt_quantity,
	cm.cmd_name,
	cm.cmd_misc1,
	cm.cmd_misc2,
	cm.cmd_misc3,
	fd.cmd_code,
	fd.fgt_weight,
	mpp.mpp_firstname,
	mpp.mpp_lastname,
	tr.trc_misc1
  into 	#boltemp
FROM  orderheader oh  LEFT OUTER JOIN  company dist  ON  oh.ord_distributor  = dist.cmp_id   LEFT OUTER JOIN  company ordby  ON  oh.ord_company  = ordby.cmp_id ,
	 stops,
	 company shipper,
	 company consignee,
	 company billto,
	 eventcodetable evt,
	 freightdetail fd,
	 commodity cm,
	 manpowerprofile mpp,
	 tractorprofile tr 
WHERE	 oh.mov_number  = stops.mov_number
 AND	oh.ord_hdrnumber  = @ord_hdrnumber
 AND	stops.stp_number  = fd.stp_number
 AND	fd.cmd_code  = cm.cmd_code
 AND	oh.ord_shipper  = shipper.cmp_id
 AND	oh.ord_billto  = billto.cmp_id
 AND	stops.stp_sequence  <= 6
 AND	stops.stp_event  = evt.abbr
 AND	stops.cmp_id  = consignee.cmp_id
 AND	evt.fgt_event  = 'DRP'
 AND	oh.ord_driver1  = mpp.mpp_id
 AND	oh.ord_tractor  = tr.trc_number
order by stp_sequence

update	#boltemp
set	#boltemp.ref_number = ( SELECT  ref1. ref_number
				FROM 	referencenumber ref1
				WHERE	ref1.ref_tablekey = #boltemp.ord_hdrnumber AND
					ref1.ref_table = 'orderheader' AND
					ref1.ref_type = 'BL#' AND
					ref1.ref_sequence = (select min(ref2.ref_sequence)
							from referencenumber ref2
							where 	ref2.ref_tablekey =ref1.ref_tablekey AND
								ref2.ref_table = 'orderheader' AND
								ref2.ref_type = 'BL#'))
SELECT * from #boltemp
DROP TABLE #boltemp

GO
GRANT EXECUTE ON  [dbo].[d_bolformat03_sp] TO [public]
GO
