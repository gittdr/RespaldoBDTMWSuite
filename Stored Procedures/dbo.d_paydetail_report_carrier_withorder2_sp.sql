SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE   PROC [dbo].[d_paydetail_report_carrier_withorder2_sp] (@carrier_id varchar(8), @carrier_type1 varchar(6), @carrier_type2 varchar(6), 
	@carrier_type3 varchar(6), @carrier_type4 varchar(6), @payment_status_array varchar(100), 
	@beg_work_date datetime, @end_work_date datetime, 
	 @beg_pay_date datetime, @end_pay_date datetime, @payment_type_array varchar(8000),
	@carrier_accounting_type varchar(6), @beg_transfer_date datetime, @end_transfer_date datetime,
	@beg_invoice_bill_date datetime, @end_invoice_bill_date datetime, @revtype1 varchar(6), @revtype2 varchar(6), @revtype3 varchar(6), @revtype4 varchar(6),
	@excl_revtype1 char(1), @excl_revtype2 char(1), @excl_revtype3 char(1), @excl_revtype4 char(1))  
   
AS

/**
 * 
 * NAME:
 * d_paydetail_report_carrier_withorder2_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Returns a result set to be used in d_paydetail_report_carrier_withorder2.  This is tightly coupled with 
 * dbo.d_paydetail_report_idwithorder3_sp, therefor any changes made to the result set here needs to be made
 * in that proc as well.
 *
 * RETURNS:
 * (NONE)
 * 
 * RESULT SETS: 
 * asgn_type,
 * asgn_id, 
 * pyd_payto, 
 * pyt_itemcode, 
 * mov_number, 
 * pyd_description, 
 * pyd_quantity, 
 * pyd_rate,
 * pyd_amount, 
 * pyd_glnum, 
 * pyd_pretax, 
 * pyd_status, 
 * pyd_refnumtype, 
 * pyd_refnum, 
 * pyh_payperiod, 
 * pyd_workperiod, 
 * lgh_startcity,
 * lgh_endcity, 
 * start_city, 
 * end_city,
 * load_state,
 * legheader_enddate,
 * carrier_name,
 * ord_number,
 * ivh_billdate,
 * ivh_invoicenumber,
 * pyh_number,
 * ord_hdrnumber,
 * carrier_inv,
 * pro_number,
 * ivh_shipdate,
 * origin,
 * destination
 *
 * PARAMETERS:
 * 001 -	@carrier_id varchar(8),
 * 002 -	@carrier_type1 varchar(6),
 * 003 -	@carrier_type2 varchar(6),
 * 004 -	@carrier_type3 varchar(6),
 * 005 -	@carrier_type4 varchar(6),
 * 006 -	@payment_status_array varchar(100),
 * 007 -	@beg_work_date datetime,
 * 008 -	@end_work_date datetime,
 * 009 -	@beg_pay_date datetime,
 * 010 -	@end_pay_date datetime,
 * 011 -	@payment_type_array varchar(8000),
 * 012 -	@carrier_accounting_type varchar(6),
 * 013 -	@beg_transfer_date datetime,
 * 014 -	@end_transfer_date datetime,
 * 015 -	@beg_invoice_bill_date datetime,
 * 016 -	@end_invoice_bill_date datetime
 *
 * REVISION HISTORY:
 * 08/22/2006.01 Phil Bidinger - PTS 33664 - Created proc based on d_paydetail_report_carrier_withorder_sp
 * 08/22/2006.02 Phil Bidinger - PTS 33664 - History below: 
 * Created to get carrier with order paydetail for settlement detail report  
 * 11/22/2006.03 Phil Bidinger - PTS33664 - Need to use DIS# and BCD# and BL#
 * 01/25/2009	 vjh 33665 - change so that not checking any paytypes (default behavior) behaves like Unknown
 *
 **/

-- Set up incoming 'string' fields as arrays
--IF @payment_status_array IS NULL OR @payment_status_array = ''
--   SELECT @payment_status_array = 'UNK'
SELECT @payment_status_array = ',' + LTRIM(RTRIM(ISNULL(@payment_status_array, '')))  + ','

--IF @payment_type_array IS NULL OR @payment_type_array = ''
--   SELECT @payment_type_array = 'UNK'
SELECT @payment_type_array = ',' + LTRIM(RTRIM(ISNULL(@payment_type_array, '')))  + ','

-- Create temporary table    
CREATE TABLE #carrier_withorder_paydetail_temp  (
asgn_type varchar(6) Null, 
asgn_id varchar(8) Null, 
pyd_payto varchar(12) Null, 
pyt_itemcode varchar(6) Null, 
mov_number int Null, 
pyd_description varchar(75) Null, 
pyd_quantity float Null, 
pyd_rate money Null, 
pyd_amount money Null, 
pyd_glnum varchar(32) Null, 
pyd_pretax char(1) Null, 
pyd_status varchar(6) Null, 
pyd_refnumtype varchar(6) Null, 
pyd_refnum varchar(30) Null, 
pyh_payperiod datetime Null, 
pyd_workperiod datetime Null, 
lgh_startcity int Null, 
lgh_endcity int Null, 
start_city varchar(30) Null, 
end_city varchar(30) Null,
load_state varchar(6) Null,
legheader_enddate datetime Null,
carrier_name varchar(64) Null,
ord_number varchar(12) Null,
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
-- PTS 25416 -- BL (start)
pyh_number int null,
-- PTS 25416 -- BL (end)
-- PTS 31363 -- BL (start)
ord_hdrnumber int null,
-- PTS 31363 -- BL (end)
carrier_inv varchar(30) NULL,
pro_number varchar(30) NULL,
ivh_shipdate datetime NULL,
origin varchar(60) NULL,
destination varchar(60) NULL,
ord_revtype1 varchar(6) NULL,
pyd_number INT,
ord_revtype2 varchar(6) NULL,
ord_revtype3 varchar(6) NULL,
ord_revtype4 varchar(6) NULL
)

-- Get paydetail info
INSERT INTO #carrier_withorder_paydetail_temp
  SELECT paydetail.asgn_type,   
         paydetail.asgn_id,   
         paydetail.pyd_payto,   
         paydetail.pyt_itemcode,   
         paydetail.mov_number,   
         paydetail.pyd_description,   
         paydetail.pyd_quantity,   
         paydetail.pyd_rate,   
         paydetail.pyd_amount,   
         paydetail.pyd_glnum,   
         paydetail.pyd_pretax,   
         paydetail.pyd_status,   
         paydetail.pyd_refnumtype,   
         paydetail.pyd_refnum,   
         paydetail.pyh_payperiod,   
         paydetail.pyd_workperiod,   
         paydetail.lgh_startcity,   
         paydetail.lgh_endcity,   
         sc.cty_nmstct,   
         ec.cty_nmstct,   
         paydetail.pyd_loadstate,   
         legheader.lgh_enddate,   
         carrier.car_name name,   
         ISNULL(orderheader.ord_number, '') ord_number,
		 null ivh_billdate,
		 null ivh_invoicenumber,
		 paydetail.pyh_number,
		 paydetail.ord_hdrnumber,
		 carrier_inv = (SELECT MIN(ref_number)
						FROM referencenumber
						WHERE ref_table = 'orderheader'
						AND ref_type = 'CAR#'
						AND ref_tablekey = paydetail.ord_hdrnumber),
		 pro_number =  (SELECT MIN(ref_number)
						FROM referencenumber
						WHERE ref_table = 'orderheader'
						AND ref_type = 'DIS#'
						AND ref_tablekey = paydetail.ord_hdrnumber),
		 null ivh_shipdate,
		 null origin,
		 null destination,
		 orderheader.ord_revtype1,
		 paydetail.pyd_number,
		 orderheader.ord_revtype2,
		 orderheader.ord_revtype3,
		 orderheader.ord_revtype4
	FROM paydetail
		 LEFT OUTER JOIN city sc ON paydetail.lgh_startcity = sc.cty_code
		 LEFT OUTER JOIN city ec ON paydetail.lgh_endcity = ec.cty_code 
		 LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
		 LEFT OUTER JOIN legheader ON paydetail.lgh_number = legheader.lgh_number
		 JOIN carrier ON paydetail.asgn_id = carrier.car_id AND
		 (@carrier_type1 = 'UNK' or @carrier_type1 = carrier.car_type1) and 
		 (@carrier_type2 = 'UNK' or @carrier_type2 = carrier.car_type2) and 
		 (@carrier_type3 = 'UNK' or @carrier_type3 = carrier.car_type3) and 
		 (@carrier_type4 = 'UNK' or @carrier_type4 = carrier.car_type4) and 
		 (@carrier_accounting_type = 'X' or @carrier_accounting_type = carrier.car_actg_type)
		 
	WHERE          
	(paydetail.asgn_type = 'CAR' and (@carrier_id = 'UNKNOWN' or @carrier_id = paydetail.asgn_id)) and 
-- vjh 33665 - change so that not checking any paytypes (default behavior) behaves like Unknown
	(@payment_type_array = ',,' OR @payment_type_array = ',UNK,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
	(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date ) or (paydetail.pyd_transdate IS null)) AND 
	(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) AND
	( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and 
	(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) 
--	and
--	(@revtype1 = 'UNK' or @revtype1 = orderheader.ord_revtype1) and 
--	(@revtype2 = 'UNK' or @revtype2 = orderheader.ord_revtype2) and 
--	(@revtype3 = 'UNK' or @revtype3 = orderheader.ord_revtype3) and 
--	(@revtype4 = 'UNK' or @revtype4 = orderheader.ord_revtype4)
	
/*  OLD JOIN CODE
     FROM paydetail,   
         city sc,   
         city ec,   
         orderheader,   
         legheader,   
         carrier
  WHERE  ( sc.cty_code =* paydetail.lgh_startcity) and  
         ( ec.cty_code =* paydetail.lgh_endcity) and  
         ( paydetail.ord_hdrnumber *= orderheader.ord_hdrnumber) and  
         ( paydetail.lgh_number *= legheader.lgh_number) and  
         (paydetail.asgn_type = 'CAR' and (@carrier_id = 'UNKNOWN' or @carrier_id = paydetail.asgn_id)) and 
	(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
	(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date ) or (paydetail.pyd_transdate IS null)) AND 
	(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) AND
	( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and 
	(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) and 
	paydetail.asgn_id = carrier.car_id and 
	(@carrier_type1 = 'UNK' or @carrier_type1 = carrier.car_type1) and 
	(@carrier_type2 = 'UNK' or @carrier_type2 = carrier.car_type2) and 
	(@carrier_type3 = 'UNK' or @carrier_type3 = carrier.car_type3) and 
	(@carrier_type4 = 'UNK' or @carrier_type4 = carrier.car_type4) and 
	(@carrier_accounting_type = 'X' or @carrier_accounting_type = carrier.car_actg_type)
*/

-- PTS 25416 -- BL (start)
if CHARINDEX('XFR', @payment_status_array) > 0 or CHARINDEX('COL', @payment_status_array) > 0 
-- Get paydetail info
INSERT INTO #carrier_withorder_paydetail_temp
  SELECT paydetail.asgn_type,   
         paydetail.asgn_id,   
         paydetail.pyd_payto,   
         paydetail.pyt_itemcode,   
         paydetail.mov_number,   
         paydetail.pyd_description,   
         paydetail.pyd_quantity,   
         paydetail.pyd_rate,   
         paydetail.pyd_amount,   
         paydetail.pyd_glnum,   
         paydetail.pyd_pretax,   
         paydetail.pyd_status,   
         paydetail.pyd_refnumtype,   
         paydetail.pyd_refnum,   
         paydetail.pyh_payperiod,   
         paydetail.pyd_workperiod,   
         paydetail.lgh_startcity,   
         paydetail.lgh_endcity,   
         sc.cty_nmstct,   
         ec.cty_nmstct,   
         paydetail.pyd_loadstate,   
         legheader.lgh_enddate,   
         carrier.car_name name,   
         ISNULL(orderheader.ord_number, '') ord_number,
null ivh_billdate,
null ivh_invoicenumber, 
paydetail.pyh_number,
paydetail.ord_hdrnumber,
carrier_inv = (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'CAR#'
				   AND ref_tablekey = paydetail.ord_hdrnumber),
pro_number =  (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'DIS#'
				   AND ref_tablekey = paydetail.ord_hdrnumber),
null ivh_shipdate,
null origin,
null destination,
orderheader.ord_revtype1,
paydetail.pyd_number,
		 orderheader.ord_revtype2,
		 orderheader.ord_revtype3,
		 orderheader.ord_revtype4
FROM  paydetail
        LEFT OUTER JOIN city sc ON sc.cty_code = paydetail.lgh_startcity
		LEFT OUTER JOIN city ec ON ec.cty_code = paydetail.lgh_endcity
		LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
		LEFT OUTER JOIN legheader ON paydetail.lgh_number = legheader.lgh_number
		JOIN carrier ON paydetail.asgn_id = carrier.car_id AND
		(@carrier_type1 = 'UNK' or @carrier_type1 = carrier.car_type1) and 
		(@carrier_type2 = 'UNK' or @carrier_type2 = carrier.car_type2) and 
		(@carrier_type3 = 'UNK' or @carrier_type3 = carrier.car_type3) and 
		(@carrier_type4 = 'UNK' or @carrier_type4 = carrier.car_type4) and 
		(@carrier_accounting_type = 'X' or @carrier_accounting_type = carrier.car_actg_type)
		JOIN payheader ph ON paydetail.pyh_number = ph.pyh_pyhnumber AND
		(CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0) AND
		paydetail.pyh_number not in (select distinct pyh_number
									 from #carrier_withorder_paydetail_temp)
        
  WHERE 
         (paydetail.asgn_type = 'CAR' and (@carrier_id = 'UNKNOWN' or @carrier_id = paydetail.asgn_id)) and 
	(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
	(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date ) or (paydetail.pyd_transdate IS null)) AND 
	( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and 
	(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) 
--	AND
--	(@revtype1 = 'UNK' or @revtype1 = orderheader.ord_revtype1) and 
--	(@revtype2 = 'UNK' or @revtype2 = orderheader.ord_revtype2) and 
--	(@revtype3 = 'UNK' or @revtype3 = orderheader.ord_revtype3) and 
--	(@revtype4 = 'UNK' or @revtype4 = orderheader.ord_revtype4)

/*  PRB OLD JOIN CODE
      FROM paydetail,   
         city sc,   
         city ec,   
         orderheader,   
         legheader,   
         carrier, payheader ph
  WHERE  ( sc.cty_code =* paydetail.lgh_startcity) and  
         ( ec.cty_code =* paydetail.lgh_endcity) and  
         ( paydetail.ord_hdrnumber *= orderheader.ord_hdrnumber) and  
         ( paydetail.lgh_number *= legheader.lgh_number) and   
         (paydetail.asgn_type = 'CAR' and (@carrier_id = 'UNKNOWN' or @carrier_id = paydetail.asgn_id)) and 
		(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
		(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date ) or (paydetail.pyd_transdate IS null)) AND 
		( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and 
		(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) and 
		paydetail.asgn_id = carrier.car_id and 
		(@carrier_type1 = 'UNK' or @carrier_type1 = carrier.car_type1) and 
		(@carrier_type2 = 'UNK' or @carrier_type2 = carrier.car_type2) and 
		(@carrier_type3 = 'UNK' or @carrier_type3 = carrier.car_type3) and 
		(@carrier_type4 = 'UNK' or @carrier_type4 = carrier.car_type4) and 
		(@carrier_accounting_type = 'X' or @carrier_accounting_type = carrier.car_actg_type)
		and paydetail.pyh_number = ph.pyh_pyhnumber 
		and (CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0)
		and paydetail.pyh_number not in (select distinct pyh_number
										 from #carrier_withorder_paydetail_temp)

*/


update 	#carrier_withorder_paydetail_temp
set 	ivh_billdate = (SELECT 	max(ivh_billdate)
						from 	invoiceheader
						where	#carrier_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where	#carrier_withorder_paydetail_temp.ord_hdrnumber > 0

update 	#carrier_withorder_paydetail_temp
set		ivh_invoicenumber = (select max(ivh_invoicenumber) 
							from 	invoiceheader 
							where 	ivh_billdate = #carrier_withorder_paydetail_temp.ivh_billdate)
where 	#carrier_withorder_paydetail_temp.ord_hdrnumber > 0


--Update the ShipDate PRB PTS33664
update 	#carrier_withorder_paydetail_temp
set 	ivh_shipdate = (SELECT 	max(ivh_shipdate)
						from 	invoiceheader
						where	#carrier_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where 	#carrier_withorder_paydetail_temp.ord_hdrnumber > 0

-- Update Origin PRB PTS33664
update 	#carrier_withorder_paydetail_temp
set 	origin =       (SELECT MAX(RTrim(LTrim(company.cmp_name)))
					 --(SELECT MAX(RTrim(LTrim(company.cmp_name)) + ' ' + RTrim(LTrim(substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))))))
						from 	invoiceheader
						LEFT OUTER JOIN company ON invoiceheader.ivh_originpoint = company.cmp_id
						where	#carrier_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where 	#carrier_withorder_paydetail_temp.ord_hdrnumber >= 0

-- Update destination PRB PTS33664
update 	#carrier_withorder_paydetail_temp
set 	destination =   (SELECT MAX(RTrim(LTrim(company.cmp_name)))
						from 	invoiceheader
						LEFT OUTER JOIN company ON invoiceheader.ivh_destpoint = company.cmp_id
						where	#carrier_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where 	#carrier_withorder_paydetail_temp.ord_hdrnumber >= 0

-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR 
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59') 
Begin
	-- Remove paydetails that do NOT fit in given invoice bill_date range
	Delete from #carrier_withorder_paydetail_temp  
	where ivh_billdate is NULL 
	or ivh_billdate > @end_invoice_bill_date 
	or ivh_billdate < @beg_invoice_bill_date 
end	

--	LOR	PTS# 35274
IF isNull(@revtype1,'UNK') <> 'UNK'
	Begin
		If @excl_revtype1 = 'Y'
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype1,'UNK') = @revtype1
		Else
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype1,'UNK') <> @revtype1
	End
IF isNull(@revtype2,'UNK') <> 'UNK'
	Begin
		If @excl_revtype2 = 'Y'
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype2,'UNK') = @revtype2
		Else
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype2,'UNK') <> @revtype2
	End
IF isNull(@revtype3,'UNK') <> 'UNK'
	Begin
		If @excl_revtype3 = 'Y'
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype3,'UNK') = @revtype3
		Else
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype3,'UNK') <> @revtype3
	End
IF isNull(@revtype4,'UNK') <> 'UNK'
	Begin
		If @excl_revtype4 = 'Y'
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype4,'UNK') = @revtype4
		Else
			DELETE FROM #carrier_withorder_paydetail_temp WHERE isNull(#carrier_withorder_paydetail_temp.ord_revtype4,'UNK') <> @revtype4
	End
--	LOR

--===========================================================================================================================
--========================================================== ** INCLUDE THIS Update cities code TOO*  ================================

-- Update cities
update 	#carrier_withorder_paydetail_temp
set 	lgh_startcity = (SELECT MAX(ivh_origincity)
						from 	invoiceheader
						where	#carrier_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where 	lgh_startcity is null or lgh_startcity = 0

update 	#carrier_withorder_paydetail_temp
set 	lgh_endcity =   (SELECT MAX(ivh_destcity)
						from 	invoiceheader
						where	#carrier_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where 	lgh_endcity is null or lgh_endcity = 0

update 	#carrier_withorder_paydetail_temp
set 	start_city =    cty_nmstct
from 	city
where 	lgh_startcity = cty_code and (start_city is null or start_city='UNKNOWN')

update 	#carrier_withorder_paydetail_temp
set 	end_city =    cty_nmstct
from 	city
where 	lgh_endcity = cty_code and (end_city is null or end_city='UNKNOWN')

--===========================================================================================================================
--===========================================================================================================================

-- Send result set back 
SELECT asgn_type,
asgn_id, 
pyd_payto, 
pyt_itemcode, 
mov_number, 
pyd_description, 
pyd_quantity, 
pyd_rate,
pyd_amount, 
pyd_glnum, 
pyd_pretax, 
pyd_status, 
pyd_refnumtype, 
pyd_refnum, 
pyh_payperiod, 
pyd_workperiod, 
lgh_startcity,
lgh_endcity, 
start_city, 
end_city,
load_state,
legheader_enddate,
carrier_name,
ord_number,
ivh_billdate,
ivh_invoicenumber,
-- PTS 25416 -- BL (start)
pyh_number,
-- PTS 25416 -- BL (end)
-- PTS 31363 -- BL (start)
ord_hdrnumber,
-- PTS 31363 -- BL (end)
carrier_inv,
pro_number,
ivh_shipdate,
origin,
destination,
'' As ref1,
'' As ref2,
'' As ref3,
'' As ref4,
ord_revtype1,
'RevType1' As revtype1userlabel
FROM #carrier_withorder_paydetail_temp 
 
DROP TABLE #carrier_withorder_paydetail_temp  
  
GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_carrier_withorder2_sp] TO [public]
GO
