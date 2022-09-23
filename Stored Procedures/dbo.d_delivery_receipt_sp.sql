SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_delivery_receipt_sp] (@ordnumber char(12))
AS

DECLARE @stp_mfh_sequence int,
 @idx int

CREATE TABLE #delivery_receipt
(ord_origin char(12),
 ord_origin_earliestdate datetime null,
 ord_dest_latestdate datetime null,
 ord_refnum varchar(30) null,
 ord_billto varchar(8) null,
 cmp_name_s varchar(30) null,
 cty_nmstct_s varchar(25) null,
 ord_remark varchar(160) null,
 stp_number_1 int null,
 cmp_name_1 varchar(30) null,
 cty_nmstct_1 varchar(25) null,
 ref_number_1 varchar(34) null,
 stp_number_2 int null, 
 cmp_name_2 varchar(30) null,
 cty_nmstct_2 varchar(25) null,
 ref_number_2 varchar(34) null,
 stp_number_3 int null,
 cmp_name_3 varchar(30) null,
 cty_nmstct_3 varchar(25) null,
 ref_number_3 varchar(34) null,
 stp_number_4 int null,
 cmp_name_4 varchar(30) null,
 cty_nmstct_4 varchar(25) null,
 ref_number_4 varchar(34) null,
 netwgtgal_1 float null,
 commodities_1 varchar(58) null,
 netwgtgal_2 float null,
 commodities_2 varchar(58) null,
 netwgtgal_3 float null,
 commodities_3 varchar(58) null, 
 netwgtgal_4 float null,
 commodities_4 varchar(58) null,
 ord_revtype1 varchar(8) null)

INSERT INTO #delivery_receipt
 SELECT @ordnumber,
  ord.ord_origin_earliestdate,
  ord.ord_dest_latestdate,
  ord.ord_refnum,
  ord.ord_billto,
  cmp.cmp_name,
  cty.cty_nmstct,
  ord.ord_remark,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  ord.ord_revtype1
 FROM orderheader ord, company cmp, city cty
 WHERE ord.ord_number = @ordnumber
 AND ord.ord_shipper = cmp.cmp_id
 AND cty.cty_code = cmp.cmp_city

-- Get the first 4 stops on the order where a delivery occurs
CREATE TABLE #delivery_stops
(stp_number int,
 stp_mfh_sequence int)

SET ROWCOUNT 4

INSERT INTO #delivery_stops
 SELECT stp.stp_number,
  stp.stp_mfh_sequence
  FROM stops stp, orderheader ord
  WHERE ord.ord_number = @ordnumber
  AND stp.ord_hdrnumber = ord.ord_hdrnumber
  AND stp.stp_event in ('DUL', 'LUL')
  ORDER BY stp.stp_mfh_sequence

SET ROWCOUNT 0

-- Get the first stop number into the delivery receipt work table
SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence)
 FROM #delivery_stops

UPDATE #delivery_receipt
 SET stp_number_1 = stp_number
 FROM #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

DELETE #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

-- Get the second stop number into the delivery receipt work table
SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence)
 FROM #delivery_stops

UPDATE #delivery_receipt
 SET stp_number_2 = stp_number
 FROM #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

DELETE #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

-- Get the third stop number into the delivery receipt work table
SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence)
 FROM #delivery_stops

UPDATE #delivery_receipt
 SET stp_number_3 = stp_number
 FROM #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

DELETE #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

-- Get the fourth stop number into the delivery receipt work table
SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence)
 FROM #delivery_stops

UPDATE #delivery_receipt
 SET stp_number_4 = stp_number
 FROM #delivery_stops
 WHERE stp_mfh_sequence = @stp_mfh_sequence

-- Get the delivery point parameters into the work table
UPDATE #delivery_receipt
 SET cmp_name_1 = cmp.cmp_name,
  cty_nmstct_1 = cty.cty_nmstct
  FROM stops stp, company cmp, city cty, #delivery_receipt tdr
  WHERE stp.stp_number = tdr.stp_number_1
  AND stp.cmp_id = cmp.cmp_id
  AND cty.cty_code = cmp.cmp_city

UPDATE #delivery_receipt
 SET ref_number_1 = 'PO# ' + ref.ref_number
 FROM stops stp, referencenumber ref, #delivery_receipt tdr
 WHERE stp.stp_number = tdr.stp_number_1
 AND ref.ref_tablekey = stp.stp_number
 AND ref.ref_table = 'stops'
 AND ref.ref_type = 'PO'

UPDATE #delivery_receipt
 SET netwgtgal_1 = IsNull(fgt.fgt_weight, IsNull(fgt.fgt_volume, 0)),
 commodities_1 = IsNull(cmd.cmd_name, '') + ' ' +
 IsNull(cmd.cmd_misc1, '') + ' ' +
 IsNull(cmd.cmd_pin, '') + ' ' +
 IsNull(cmd.cmd_misc2, '')
 FROM freightdetail fgt, commodity cmd, #delivery_receipt tdr
 WHERE fgt.stp_number = tdr.stp_number_1
 AND fgt.cmd_code = cmd.cmd_code 

UPDATE #delivery_receipt
 SET cmp_name_2 = cmp.cmp_name,
  cty_nmstct_2 = cty.cty_nmstct
  FROM stops stp, company cmp, city cty, #delivery_receipt tdr
  WHERE stp.stp_number = tdr.stp_number_2
  AND stp.cmp_id = cmp.cmp_id
  AND cty.cty_code = cmp.cmp_city

UPDATE #delivery_receipt
 SET ref_number_2 = 'PO# ' + ref.ref_number
 FROM stops stp, referencenumber ref, #delivery_receipt tdr
 WHERE stp.stp_number = tdr.stp_number_2
 AND ref.ref_tablekey = stp.stp_number
 AND ref.ref_table = 'stops'
 AND ref.ref_type = 'PO'

UPDATE #delivery_receipt
 SET netwgtgal_2 = IsNull(fgt.fgt_weight, IsNull(fgt.fgt_volume, 0)),
 commodities_2 = IsNull(cmd.cmd_name, '') + ' ' +
 IsNull(cmd.cmd_misc1, '') + ' ' +
 IsNull(cmd.cmd_pin, '') + ' ' +
 IsNull(cmd.cmd_misc2, '')
 FROM freightdetail fgt, commodity cmd, #delivery_receipt tdr
 WHERE fgt.stp_number = tdr.stp_number_2
 AND fgt.cmd_code = cmd.cmd_code 

UPDATE #delivery_receipt
 SET cmp_name_3 = cmp.cmp_name,
  cty_nmstct_3 = cty.cty_nmstct
  FROM stops stp, company cmp, city cty, #delivery_receipt tdr
  WHERE stp.stp_number = tdr.stp_number_3
  AND stp.cmp_id = cmp.cmp_id
  AND cty.cty_code = cmp.cmp_city

UPDATE #delivery_receipt
 SET ref_number_3 = 'PO# ' + ref.ref_number
 FROM stops stp, referencenumber ref, #delivery_receipt tdr
 WHERE stp.stp_number = tdr.stp_number_3
 AND ref.ref_tablekey = stp.stp_number
 AND ref.ref_table = 'stops'
 AND ref.ref_type = 'PO'

UPDATE #delivery_receipt
 SET netwgtgal_3 = IsNull(fgt.fgt_weight, IsNull(fgt.fgt_volume, 0)),
 commodities_3 = IsNull(cmd.cmd_name, '') + ' ' +
 IsNull(cmd.cmd_misc1, '') + ' ' +
 IsNull(cmd.cmd_pin, '') + ' ' +
 IsNull(cmd.cmd_misc2, '')
 FROM freightdetail fgt, commodity cmd, #delivery_receipt tdr
 WHERE fgt.stp_number = tdr.stp_number_3
 AND fgt.cmd_code = cmd.cmd_code 

UPDATE #delivery_receipt
 SET cmp_name_4 = cmp.cmp_name,
  cty_nmstct_4 = cty.cty_nmstct
  FROM stops stp, company cmp, city cty, #delivery_receipt tdr
  WHERE stp.stp_number = tdr.stp_number_4
  AND stp.cmp_id = cmp.cmp_id
  AND cty.cty_code = cmp.cmp_city

UPDATE #delivery_receipt
 SET ref_number_4 = 'PO# ' + ref.ref_number
 FROM stops stp, referencenumber ref, #delivery_receipt tdr
 WHERE stp.stp_number = tdr.stp_number_4
 AND ref.ref_tablekey = stp.stp_number
 AND ref.ref_table = 'stops'
 AND ref.ref_type = 'PO'

UPDATE #delivery_receipt
 SET netwgtgal_4 = IsNull(fgt.fgt_weight, IsNull(fgt.fgt_volume, 0)),
 commodities_4 = IsNull(cmd.cmd_name, '') + ' ' +
 IsNull(cmd.cmd_misc1, '') + ' ' +
 IsNull(cmd.cmd_pin, '') + ' ' +
 IsNull(cmd.cmd_misc2, '')
 FROM freightdetail fgt, commodity cmd, #delivery_receipt tdr
 WHERE fgt.stp_number = tdr.stp_number_4
 AND fgt.cmd_code = cmd.cmd_code

SELECT ord_origin,
 ord_origin_earliestdate,
 ord_dest_latestdate,
 ord_refnum,
 ord_billto,
 cmp_name_s,
 cty_nmstct_s,
 ord_remark,
 cmp_name_1,
 cty_nmstct_1,
 ref_number_1,
 cmp_name_2,
 cty_nmstct_2,
 ref_number_2,
 cmp_name_3,
 cty_nmstct_3,
 ref_number_3,
 cmp_name_4,
 cty_nmstct_4,
 ref_number_4,
 netwgtgal_1,
 commodities_1,
 netwgtgal_2,
 commodities_2,
 netwgtgal_3,
 commodities_3,
 netwgtgal_4,
 commodities_4, 
 ord_revtype1
 FROM #delivery_receipt

GO
GRANT EXECUTE ON  [dbo].[d_delivery_receipt_sp] TO [public]
GO
