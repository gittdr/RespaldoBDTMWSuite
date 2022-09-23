SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE   PROC [dbo].[d_paydetail_report_idwithorder3_sp] (@driver_id varchar(8), @driver_type1 varchar(6), @driver_type2 varchar(6), 
	@driver_type3 varchar(6), @driver_type4 varchar(6), @payment_status_array varchar(100), 
	@company varchar(6), @fleet varchar(6), @division varchar(6), @domicile varchar(6),
	@beg_work_date datetime, @end_work_date datetime, 
	@beg_pay_date datetime, @end_pay_date datetime, @payment_type_array varchar(8000),
	@driver_accounting_type varchar(6), @beg_transfer_date datetime, @end_transfer_date datetime,
	@beg_invoice_bill_date datetime, @end_invoice_bill_date datetime, @sch_date1 datetime, @sch_date2 datetime, 
	@revtype1 varchar(6), @revtype2 varchar(6), @revtype3 varchar(6), @revtype4 varchar(6),
	@excl_revtype1 char(1), @excl_revtype2 char(1), @excl_revtype3 char(1), @excl_revtype4 char(1),
	@resourcetypeonleg char(1))            
   
AS

/**
 * 
 * NAME:
 * dbo.d_paydetail_report_idwithorder3_sp
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
 * 001 -	@driver_id varchar(8),
 * 002 -	@driver_type1 varchar(6),
 * 003 -	@driver_type2 varchar(6),
 * 004 -	@driver_type3 varchar(6),
 * 005 -	@driver_type4 varchar(6),
 * 006 -	@payment_status_array varchar(100),
 * 007 -	@company varchar(6),
 * 008 -	@fleet varchar(6),
 * 009 -	@division varchar(6),
 * 010 -	@domicile varchar(6),
 * 011 -	@beg_work_date datetime,
 * 012 -	@end_work_date datetime,
 * 013 -	@beg_pay_date datetime,
 * 014 -	@end_pay_date datetime,
 * 015 -	@payment_type_array varchar(8000),
 * 016 -	@driver_accounting_type varchar(6)
 * 017 -    @beg_transfer_date datetime
 * 018 -    @end_transfer_date datetime
 * 019 -    @beg_invoice_bill_date datetime
 * 020 -    @end_invoice_bill_date datetime
 * 021 -    @sch_date1 datetime
 * 022 -    @sch_date2 datetime
 *
 * REVISION HISTORY:
 * 08/22/2006.01 Phil Bidinger - PTS 33664 - Created proc based on d_paydetail_report_idwithorder3
 * 08/22/2006.02 Phil Bidinger - PTS 33664 - History below: 
 * Created to get driver id with order paydetail for settlement detail report    
 * PTS 48237 - DJM - 6/15/2010 - Added 'resourcetypeonleg' parameter to allow the proc to look at the asset type
 *							on the leg instead of just the Asset Master (Driver and Tractor only)
 **/


-- Set up incoming 'string' fields as arrays
--IF @payment_status_array IS NULL OR @payment_status_array = ''
--   SELECT @payment_status_array = 'UNK'
SELECT @payment_status_array = ',' + LTRIM(RTRIM(ISNULL(@payment_status_array, '')))  + ','

--IF @payment_type_array IS NULL OR @payment_type_array = ''
--   SELECT @payment_type_array = 'UNK'
SELECT @payment_type_array = ',' + LTRIM(RTRIM(ISNULL(@payment_type_array, '')))  + ','

-- Create temporary table    
CREATE TABLE #driver_idwithorder_paydetail_temp  (
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
driver_name varchar(64) Null,
ord_number varchar(12) Null,
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
-- PTS 25416 -- BL (start)
pyh_number int null,
-- PTS 25416 -- BL (end)
-- PTS 31363 -- BL (start)
ord_hdrnumber int null,
carrier_inv varchar(30) NULL,
pro_number varchar(30) NULL,
ivh_shipdate datetime NULL,
origin varchar(60) NULL,
destination varchar(60) NULL,
ord_revtype1 varchar(6) NULL,
ord_revtype2 varchar(6) NULL,
ord_revtype3 varchar(6) NULL,
ord_revtype4 varchar(6) NULL,
lgh_number	int	null)

-- Get paydetail info
INSERT INTO #driver_idwithorder_paydetail_temp
SELECT  paydetail.asgn_type ,
           paydetail.asgn_id ,
           paydetail.pyd_payto ,
           paydetail.pyt_itemcode ,
           paydetail.mov_number ,
           paydetail.pyd_description ,
           paydetail.pyd_quantity ,
           paydetail.pyd_rate ,
           paydetail.pyd_amount ,
           paydetail.pyd_glnum ,
           paydetail.pyd_pretax ,
           paydetail.pyd_status ,
           paydetail.pyd_refnumtype ,
           paydetail.pyd_refnum ,
           paydetail.pyh_payperiod ,
           paydetail.pyd_workperiod ,
           paydetail.lgh_startcity ,
           paydetail.lgh_endcity ,
           sc.cty_nmstct ,
           ec.cty_nmstct ,
           paydetail.pyd_loadstate ,
           legheader.lgh_enddate ,
           manpowerprofile.mpp_lastname +',  '+ manpowerprofile.mpp_firstname name,
           ISNULL(orderheader.ord_number,  '') ord_number,
	null ivh_billdate,
	null ivh_invoicenumber, 
	paydetail.pyh_number,
	paydetail.ord_hdrnumber,
	carrier_inv = (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'CARINV'
				   AND ref_tablekey = paydetail.ord_hdrnumber),
    pro_number =  (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'PRO#'
				   AND ref_tablekey = paydetail.ord_hdrnumber),
	null ivh_shipdate,
	null origin,
    null destination,
	orderheader.ord_revtype1,
	orderheader.ord_revtype2,
	orderheader.ord_revtype3,
	orderheader.ord_revtype4,
	paydetail.lgh_number -- PTS 48237
 FROM  paydetail
		JOIN manpowerprofile ON paydetail.asgn_id = manpowerprofile.mpp_id
        LEFT OUTER JOIN city sc ON sc.cty_code = paydetail.lgh_startcity
		LEFT OUTER JOIN city ec ON ec.cty_code = paydetail.lgh_endcity
		LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
		LEFT OUTER JOIN legheader ON paydetail.lgh_number = legheader.lgh_number
  WHERE --( sc.cty_code =* paydetail.lgh_startcity) and          
--( ec.cty_code =* paydetail.lgh_endcity) and          
--( paydetail.ord_hdrnumber *= orderheader.ord_hdrnumber) and          
--( paydetail.lgh_number *= legheader.lgh_number) and          
--( paydetail.asgn_id = manpowerprofile.mpp_id ) and          
(paydetail.asgn_type = 'DRV' and                   
( (@driver_id = 'UNKNOWN' or @driver_id =  paydetail.asgn_id)) ) and          
(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
(paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date or ( paydetail.pyd_transdate is null) ) and          
(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) AND
( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and          
(paydetail.pyd_workperiod between @beg_work_date and @end_work_date or ( paydetail.pyd_workperiod is null) ) and          
-- paydetail.asgn_id = manpowerprofile.mpp_id ) and           
--( (@driver_type1 = 'UNK' or @driver_type1 =  manpowerprofile.mpp_type1) ) and          
--( (@driver_type2 = 'UNK' or @driver_type2 =  manpowerprofile.mpp_type2) ) and          
--( (@driver_type3 = 'UNK' or @driver_type3 =  manpowerprofile.mpp_type3) ) and          
--( (@driver_type4 = 'UNK' or @driver_type4 =  manpowerprofile.mpp_type4) ) and          
( (@company = 'UNK' or @company = manpowerprofile.mpp_company) ) and          
( (@fleet = 'UNK' or @fleet =  manpowerprofile.mpp_fleet) ) and          
( (@division = 'UNK' or @division =  manpowerprofile.mpp_division) ) and          
( (@domicile = 'UNK' or @domicile =  manpowerprofile.mpp_domicile) ) and          
( (@driver_accounting_type = 'X' or @driver_accounting_type = manpowerprofile.mpp_actg_type) ) AND
( (@revtype1 = 'UNK' or @revtype1 = orderheader.ord_revtype1) ) and 
( (@revtype2 = 'UNK' or @revtype2 = orderheader.ord_revtype2) ) and 
( (@revtype3 = 'UNK' or @revtype3 = orderheader.ord_revtype3) ) and 
( (@revtype4 = 'UNK' or @revtype4 = orderheader.ord_revtype4) )


if CHARINDEX('XFR', @payment_status_array) > 0 or CHARINDEX('COL', @payment_status_array) > 0 
-- Get paydetail info
INSERT INTO #driver_idwithorder_paydetail_temp
SELECT  paydetail.asgn_type ,
           paydetail.asgn_id ,
           paydetail.pyd_payto ,
           paydetail.pyt_itemcode ,
           paydetail.mov_number ,
           paydetail.pyd_description ,
           paydetail.pyd_quantity ,
           paydetail.pyd_rate ,
           paydetail.pyd_amount ,
           paydetail.pyd_glnum ,
           paydetail.pyd_pretax ,
           paydetail.pyd_status ,
           paydetail.pyd_refnumtype ,
           paydetail.pyd_refnum ,
           paydetail.pyh_payperiod ,
           paydetail.pyd_workperiod ,
           paydetail.lgh_startcity ,
           paydetail.lgh_endcity ,
           sc.cty_nmstct ,
           ec.cty_nmstct ,
           paydetail.pyd_loadstate ,
           legheader.lgh_enddate ,
           manpowerprofile.mpp_lastname +',  '+ manpowerprofile.mpp_firstname name,
           ISNULL(orderheader.ord_number,  '') ord_number,
	null ivh_invoicenumber, 
	paydetail.pyh_number,
	paydetail.ord_hdrnumber,
	carrier_inv = (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'CARINV'
				   AND ref_tablekey = paydetail.ord_hdrnumber),
    pro_number =  (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'PO#'
				   AND ref_tablekey = paydetail.ord_hdrnumber),
	null ivh_shipdate,
	null origin,
    null destination,
	orderheader.ord_revtype1,
	orderheader.ord_revtype2,
	orderheader.ord_revtype3,
	orderheader.ord_revtype4,
	paydetail.lgh_number -- PTS 48237
  FROM  paydetail
		JOIN manpowerprofile ON paydetail.asgn_id = manpowerprofile.mpp_id
        LEFT OUTER JOIN city sc ON sc.cty_code = paydetail.lgh_startcity
		LEFT OUTER JOIN city ec ON ec.cty_code = paydetail.lgh_endcity
		LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
		LEFT OUTER JOIN legheader ON paydetail.lgh_number = legheader.lgh_number,
		payheader ph
  WHERE --( sc.cty_code =* paydetail.lgh_startcity) and          
--( ec.cty_code =* paydetail.lgh_endcity) and          
--( paydetail.ord_hdrnumber *= orderheader.ord_hdrnumber) and          
--( paydetail.lgh_number *= legheader.lgh_number) and          
--( paydetail.asgn_id = manpowerprofile.mpp_id ) and          
(paydetail.asgn_type = 'DRV' and                 
( (@driver_id = 'UNKNOWN' or @driver_id =  paydetail.asgn_id)) ) and          
(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
(paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date or ( paydetail.pyd_transdate is null) ) and          
( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and          
(paydetail.pyd_workperiod between @beg_work_date and @end_work_date or ( paydetail.pyd_workperiod is null) ) and          
--( paydetail.asgn_id = manpowerprofile.mpp_id ) and           
--( (@driver_type1 = 'UNK' or @driver_type1 =  manpowerprofile.mpp_type1) ) and          
--( (@driver_type2 = 'UNK' or @driver_type2 =  manpowerprofile.mpp_type2) ) and          
--( (@driver_type3 = 'UNK' or @driver_type3 =  manpowerprofile.mpp_type3) ) and          
--( (@driver_type4 = 'UNK' or @driver_type4 =  manpowerprofile.mpp_type4) ) and          
( (@company = 'UNK' or @company = manpowerprofile.mpp_company) ) and          
( (@fleet = 'UNK' or @fleet =  manpowerprofile.mpp_fleet) ) and          
( (@division = 'UNK' or @division =  manpowerprofile.mpp_division) ) and          
( (@domicile = 'UNK' or @domicile =  manpowerprofile.mpp_domicile) ) and       
( (@revtype1 = 'UNK' or @revtype1 = orderheader.ord_revtype1) ) and 
( (@revtype2 = 'UNK' or @revtype2 = orderheader.ord_revtype2) ) and 
( (@revtype3 = 'UNK' or @revtype3 = orderheader.ord_revtype3) ) and 
( (@revtype4 = 'UNK' or @revtype4 = orderheader.ord_revtype4) ) and   
( (@driver_accounting_type = 'X' or @driver_accounting_type =  manpowerprofile.mpp_actg_type) )   
	and paydetail.pyh_number = ph.pyh_pyhnumber 
	and (CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0)
	and paydetail.pyh_number not in 
		(select distinct pyh_number
		from #driver_idwithorder_paydetail_temp)

--PTS 48237 - DJM
	if @resourcetypeonleg = 'N'
		Begin

			IF @driver_type1 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type1 <> @driver_type1

			IF @driver_type2 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type2 <> @driver_type2

			IF @driver_type3 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type3 <> @driver_type3
			
			IF @driver_type4 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type4 <> @driver_type4
		end
	else
		Begin
			IF @driver_type1 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_idwithorder_paydetail_temp.lgh_number and isNull(#driver_idwithorder_paydetail_temp.lgh_number,0) > 0 and l.mpp_type1 <> @driver_type1

			IF @driver_type2 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_idwithorder_paydetail_temp.lgh_number and isNull(#driver_idwithorder_paydetail_temp.lgh_number,0) > 0 and l.mpp_type2 <> @driver_type2

			IF @driver_type3 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_idwithorder_paydetail_temp.lgh_number and isNull(#driver_idwithorder_paydetail_temp.lgh_number,0) > 0 and l.mpp_type3 <> @driver_type3
			
			IF @driver_type4 <> 'UNK'
				delete #driver_idwithorder_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_idwithorder_paydetail_temp.lgh_number and isNull(#driver_idwithorder_paydetail_temp.lgh_number,0) > 0 and l.mpp_type4 <> @driver_type4
		
		End
-- End 48237

-- PTS 31363 -- BL (start)
-- Update billdate and invoicenumber rather than set it during the insert
update 	#driver_idwithorder_paydetail_temp
set 	ivh_billdate = (SELECT 	max(ivh_billdate)
						from 	invoiceheader
						where	#driver_idwithorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where	#driver_idwithorder_paydetail_temp.ord_hdrnumber > 0

update 	#driver_idwithorder_paydetail_temp
set		ivh_invoicenumber = (select max(ivh_invoicenumber) 
							from 	invoiceheader 
							where 	ivh_billdate = #driver_idwithorder_paydetail_temp.ivh_billdate)
where 	#driver_idwithorder_paydetail_temp.ord_hdrnumber > 0
-- PTS 31363 -- BL (end)

-- Update shipdate
update 	#driver_idwithorder_paydetail_temp
set 	ivh_billdate = (SELECT 	max(ivh_shipdate)
						from 	invoiceheader
						where	#driver_idwithorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where	#driver_idwithorder_paydetail_temp.ord_hdrnumber > 0
-- END update shipdate

-- Update Origin
update 	#driver_idwithorder_paydetail_temp
set 	origin =       (SELECT MAX(RTrim(LTrim(company.cmp_name)) + ' ' + RTrim(LTrim(substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))))))
						from 	invoiceheader
						LEFT OUTER JOIN company ON invoiceheader.ivh_originpoint = company.cmp_id
						where	#driver_idwithorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where	#driver_idwithorder_paydetail_temp.ord_hdrnumber > 0
  --(SELECT substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))
-- End Update Origin

-- Update Destination
update 	#driver_idwithorder_paydetail_temp
set 	destination =   (SELECT MAX(LTrim(RTrim(company.cmp_name)) + ' ' + LTrim(RTrim(substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))))))
						from 	invoiceheader
						LEFT OUTER JOIN company ON invoiceheader.ivh_destpoint = company.cmp_id
						where	#driver_idwithorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where	#driver_idwithorder_paydetail_temp.ord_hdrnumber > 0
-- End Update Destination

-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR 
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59') 
Begin
	-- Remove paydetails that do NOT fit in given invoice bill_date range
	Delete from #driver_idwithorder_paydetail_temp  
	where ivh_billdate is NULL 
	or ivh_billdate > @end_invoice_bill_date 
	or ivh_billdate < @beg_invoice_bill_date 
end	

--LOR	PTS# 32588
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR 
      @sch_date2 < convert(datetime, '2049-12-31 23:59') 
	Delete from #driver_idwithorder_paydetail_temp  
	where #driver_idwithorder_paydetail_temp.ord_hdrnumber > 0 and 
		#driver_idwithorder_paydetail_temp.ord_hdrnumber in (select ord_hdrnumber 
						from stops
						where stp_sequence = 1 and
							(stp_schdtearliest > @sch_date2  or 
							stp_schdtearliest < @sch_date1))	
-- LOR

--	LOR	PTS# 35274
IF isNull(@revtype1,'UNK') <> 'UNK'
	Begin
		If @excl_revtype1 = 'Y'
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype1,'UNK') = @revtype1
		Else
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype1,'UNK') <> @revtype1
	End
IF isNull(@revtype2,'UNK') <> 'UNK'
	Begin
		If @excl_revtype2 = 'Y'
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype2,'UNK') = @revtype2
		Else
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype2,'UNK') <> @revtype2
	End
IF isNull(@revtype3,'UNK') <> 'UNK'
	Begin
		If @excl_revtype3 = 'Y'
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype3,'UNK') = @revtype3
		Else
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype3,'UNK') <> @revtype3
	End
IF isNull(@revtype4,'UNK') <> 'UNK'
	Begin
		If @excl_revtype4 = 'Y'
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype4,'UNK') = @revtype4
		Else
			DELETE FROM #driver_idwithorder_paydetail_temp WHERE isNull(#driver_idwithorder_paydetail_temp.ord_revtype4,'UNK') <> @revtype4
	End
--	LOR
-- Send result set back 
--SELECT * from #driver_idwithorder_paydetail_temp  

Select asgn_type, 
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
	pyd_status , 
	pyd_refnumtype, 
	pyd_refnum, 
	pyh_payperiod, 
	pyd_workperiod, 
	lgh_startcity, 
	lgh_endcity , 
	start_city, 
	end_city,
	load_state,
	legheader_enddate,
	driver_name,
	ord_number,
	ivh_billdate,
	ivh_invoicenumber,
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
	'RevType1' As retype1userlabel
from #driver_idwithorder_paydetail_temp 

DROP TABLE #driver_idwithorder_paydetail_temp  
  
GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_idwithorder3_sp] TO [public]
GO
