SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

  
CREATE   PROC [dbo].[d_paydetail_report_tpr_withorder_sp] (@tpr_id varchar(8), @tpr_type varchar(12), @payment_status_array varchar(100), 
	@beg_work_date datetime, @end_work_date datetime, 
	@beg_pay_date datetime, @end_pay_date datetime, @payment_type_array varchar(8000),
	@tpr_accounting_type varchar(6), @beg_transfer_date datetime, @end_transfer_date datetime,
	@beg_invoice_bill_date datetime, @end_invoice_bill_date datetime,
	@sch_date1 datetime,
	@sch_date2 datetime)     
   
AS  
/*
 * 
 * NAME:
 * dbo.d_paydetail_report_tpr_withorder_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * REVISION HISTORY:
 * Date ? 	PTS# - 	AuthorName	Revision Description
 * 1/10/2007	35189	SLM		Create stored proc for Third Party Pay Settlement Detail Report
 *                                      Created from d_paydetail_report_trailer_withorder_sp
 * 11/1/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
*/


-- Set up incoming 'string' fields as arrays
SELECT @payment_status_array = ',' + LTRIM(RTRIM(ISNULL(@payment_status_array, '')))  + ','

SELECT @payment_type_array = ',' + LTRIM(RTRIM(ISNULL(@payment_type_array, '')))  + ','

-- Create temporary table    
CREATE TABLE #tpr_withorder_paydetail_temp  (
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
tpr_name varchar(64) Null,
ord_number varchar(12) Null,
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
pyh_number int null,
ord_hdrnumber int null)

-- Get paydetail info
INSERT INTO #tpr_withorder_paydetail_temp
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
         thirdpartyprofile.tpr_name,   
         ISNULL(orderheader.ord_number, '') ord_number,
         null ivh_billdate,
         null ivh_invoicenumber, 
         paydetail.pyh_number,
         paydetail.ord_hdrnumber
    --pts40115 jguo outer join conversion
    FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity   
			LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity   
			LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber   
			LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number ,
	     thirdpartyprofile
	WHERE ( paydetail.asgn_id = thirdpartyprofile.tpr_id ) and          
		(paydetail.asgn_type = 'TPR' and          
		( (@tpr_id = 'UNKNOWN' or @tpr_id =  paydetail.asgn_id)) ) and          
		(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
		(paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date or ( paydetail.pyd_transdate is null) ) and          
		(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) AND
		( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and          
		(paydetail.pyd_workperiod between @beg_work_date and @end_work_date or ( paydetail.pyd_workperiod is null) ) and          
		( paydetail.asgn_id = thirdpartyprofile.tpr_id ) and          
		--( (@tpr_type = 'UNK' or @tpr_type =  thirdpartyprofile.tpr_type) ) and          
		( (@tpr_type = 'UNK' or @tpr_type = 'UNKNOWN' or @tpr_type =  thirdpartyprofile.tpr_type) ) and          
		( (@tpr_accounting_type = 'X' or @tpr_accounting_type =  thirdpartyprofile.tpr_actg_type) )   

if CHARINDEX('XFR', @payment_status_array) > 0 or CHARINDEX('COL', @payment_status_array) > 0 
-- Get paydetail info
INSERT INTO #tpr_withorder_paydetail_temp
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
         thirdpartyprofile.tpr_name,   
         ISNULL(orderheader.ord_number, '') ord_number,
         null ivh_billdate,
         null ivh_invoicenumber, 
         paydetail.pyh_number,
         paydetail.ord_hdrnumber
    FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity   
			LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity   
			LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber   
			LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number ,
	     thirdpartyprofile,
	     payheader ph
	WHERE ( paydetail.asgn_id = thirdpartyprofile.tpr_id ) and          
		(paydetail.asgn_type = 'TPR' and          
		( (@tpr_id = 'UNKNOWN' or @tpr_id =  paydetail.asgn_id)) ) and          
		(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
		(paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date or ( paydetail.pyd_transdate is null) ) and          
		( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and          
		(paydetail.pyd_workperiod between @beg_work_date and @end_work_date or ( paydetail.pyd_workperiod is null) ) and          
		( paydetail.asgn_id = thirdpartyprofile.tpr_id ) and          
		--( (@tpr_type = 'UNK' or @tpr_type =  thirdpartyprofile.tpr_type) ) and
		( (@tpr_type = 'UNK' or @tpr_type = 'UNKNOWN' or @tpr_type =  thirdpartyprofile.tpr_type) ) and          
		( (@tpr_accounting_type = 'X' or @tpr_accounting_type =  thirdpartyprofile.tpr_actg_type) )   
			and paydetail.pyh_number = ph.pyh_pyhnumber 
			and (CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0)
			and paydetail.pyh_number not in 
				(select distinct pyh_number
				from #tpr_withorder_paydetail_temp)

-- Update billdate and invoicenumber rather than set it during the insert
update 	#tpr_withorder_paydetail_temp
set 	ivh_billdate = (SELECT 	max(ivh_billdate)
				from 	invoiceheader
				where	#tpr_withorder_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where	#tpr_withorder_paydetail_temp.ord_hdrnumber > 0

update 	#tpr_withorder_paydetail_temp
set		ivh_invoicenumber = (select max(ivh_invoicenumber) 
					from 	invoiceheader 
					where 	ivh_billdate = #tpr_withorder_paydetail_temp.ivh_billdate)
where 	#tpr_withorder_paydetail_temp.ord_hdrnumber > 0

-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR 
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59') 
Begin
	-- Remove paydetails that do NOT fit in given invoice bill_date range
	Delete from #tpr_withorder_paydetail_temp  
	where ivh_billdate is NULL 
	or ivh_billdate > @end_invoice_bill_date 
	or ivh_billdate < @beg_invoice_bill_date 
end	

if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR 
      @sch_date2 < convert(datetime, '2049-12-31 23:59') 
	Delete from #tpr_withorder_paydetail_temp
	where #tpr_withorder_paydetail_temp.ord_hdrnumber > 0 and 
		#tpr_withorder_paydetail_temp.ord_hdrnumber in (select ord_hdrnumber 
						from stops
						where stp_sequence = 1 and
							(stp_schdtearliest > @sch_date2  or 
							stp_schdtearliest < @sch_date1))	

-- Send result set back 
SELECT * from #tpr_withorder_paydetail_temp  
DROP TABLE #tpr_withorder_paydetail_temp  
  


GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_tpr_withorder_sp] TO [public]
GO
