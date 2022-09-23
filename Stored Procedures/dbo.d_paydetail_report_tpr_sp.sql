SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

  
CREATE   PROC [dbo].[d_paydetail_report_tpr_sp] (@tpr_id varchar(8), @tpr_type varchar(12), @payment_status_array varchar(100), 	
	@beg_work_date datetime, @end_work_date datetime, 
	@beg_pay_date datetime, @end_pay_date datetime, @payment_type_array varchar(8000),
	@tpr_accounting_type varchar(1), @beg_transfer_date datetime, @end_transfer_date datetime,
	@beg_invoice_bill_date datetime, @end_invoice_bill_date datetime,
	@sch_date1 datetime,
	@sch_date2 datetime)     
   
AS  
/*
 * 
 * NAME:
 * dbo.d_paydetail_report_tpr_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * REVISION HISTORY:
 * Date ? 	PTS# - 	AuthorName	Revision Description
 * 1/8/2007	35189	SLM		Create stored proc for Third Party Pay Settlement Detail Report
 *                                      Created from d_paydetail_report_trailer_sp
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * -- PTS 51698 05/2010 SPN - introducing subquery from temp_report_arguments instead of payment_type_array
 * -- PTS 53314 07/2010 SPN - getting appropriate invoice date and number by move or ord_hdrnumber
 *
*/


-- Set up incoming 'string' fields as arrays
SELECT @payment_status_array = ',' + LTRIM(RTRIM(ISNULL(@payment_status_array, '')))  + ','

SELECT @payment_type_array = ',' + LTRIM(RTRIM(ISNULL(@payment_type_array, '')))  + ','

-- Create temporary table    
CREATE TABLE #tpr_paydetail_temp  (
asgn_type varchar(6) Null, 
asgn_id varchar(13) Null, 
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
tpr_name varchar(64) Null,
start_city varchar(30) Null, 
end_city varchar(30) Null,
paydetail_pyt_itemcode varchar(6) Null,
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
ord_hdrnumber int null,
pyh_number int null)

-- Get paydetail info
INSERT INTO #tpr_paydetail_temp
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
null ,
sc.cty_nmstct, 
ec.cty_nmstct, 
paydetail.pyt_itemcode,
NULL,
NULL,
paydetail.ord_hdrnumber,
paydetail.pyh_number
FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity   
		LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity   
WHERE 	(paydetail.asgn_type = 'TPR') and 
		(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date ) or ( paydetail.pyd_transdate IS null)) and 
		( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and 
		(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) and 
--BEGIN PTS 51698 SPN
(@payment_type_array = ',,' OR @payment_type_array = ',XXX,' OR
  paydetail.pyt_itemcode IN (select temp_report_argument_value
                               from temp_report_arguments
                              where current_session_id = @@SPID
                                and temp_report_name = 'PAYDETAIL_REPORT'
                                and temp_report_argument_name = 'PAYTYPE'
                                and temp_report_argument_value IS NOT NULL
                            )
) AND
--		(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND
--END PTS 51698 SPN
		(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) 
		--sc.cty_code =* paydetail.lgh_startcity and 
		--ec.cty_code =* paydetail.lgh_endcity 

if CHARINDEX('XFR', @payment_status_array) > 0 or CHARINDEX('COL', @payment_status_array) > 0 

-- Get paydetail info
INSERT INTO #tpr_paydetail_temp
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
null ,
sc.cty_nmstct, 
ec.cty_nmstct, 
paydetail.pyt_itemcode,
NULL,
NULL,
paydetail.ord_hdrnumber,
paydetail.pyh_number
FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity   
		LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity ,
	 payheader ph
WHERE 	(paydetail.asgn_type = 'TPR') and 
		(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date ) or ( paydetail.pyd_transdate IS null)) and 
		( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date ) and 
		(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) and 
--BEGIN PTS 51698 SPN
(@payment_type_array = ',,' OR @payment_type_array = ',XXX,' OR
  paydetail.pyt_itemcode IN (select temp_report_argument_value
                               from temp_report_arguments
                              where current_session_id = @@SPID
                                and temp_report_name = 'PAYDETAIL_REPORT'
                                and temp_report_argument_name = 'PAYTYPE'
                                and temp_report_argument_value IS NOT NULL
                            )
) 
--		(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) 
--END PTS 51698 SPN
		--sc.cty_code =* paydetail.lgh_startcity and 
		--ec.cty_code =* paydetail.lgh_endcity 
	and paydetail.pyh_number = ph.pyh_pyhnumber 
	and (CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0)
	and paydetail.pyh_number not in 
		(select distinct pyh_number
		from #tpr_paydetail_temp)

--SLM PTS 35189
--	IF @tpr_id <> 'UNKNOWN' 
--	IF @tpr_type <> 'UNK' and @tpr_type <> 'UNKNOWN'
	IF @tpr_id <> 'UNKNOWN' and @tpr_id <> 'UNK'
		delete #tpr_paydetail_temp  where asgn_type = 'TPR' and asgn_id <> @tpr_id

--	IF @tpr_type <> 'UNK'
	IF @tpr_type <> 'UNK' and @tpr_type <> 'UNKNOWN'
		delete #tpr_paydetail_temp from thirdpartyprofile tp 
where asgn_type = 'TPR' and asgn_id = tp.tpr_id and tpr_type <> @tpr_type

	IF @tpr_accounting_type <>'X' 
		delete #tpr_paydetail_temp from thirdpartyprofile tp where asgn_type = 'TPR' and asgn_id = tp.tpr_id and tpr_actg_type
 <> @tpr_accounting_type 

	Update #tpr_paydetail_temp set tpr_name = tp.tpr_name from thirdpartyprofile tp where asgn_type = 'TPR' and 
asgn_id = tp.tpr_id


--BEGIN PTS 53314 SPN
UPDATE #tpr_paydetail_temp
   SET ivh_billdate      = (SELECT MAX(ivh_billdate)
                              FROM invoiceheader
                             WHERE #tpr_paydetail_temp.ord_hdrnumber IS NOT NULL
                               AND invoiceheader.ord_hdrnumber IS NOT NULL
                               AND #tpr_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber
                               AND #tpr_paydetail_temp.ord_hdrnumber <> 0
                           )
     , ivh_invoicenumber = (SELECT MAX(ivh_invoicenumber)
                              FROM invoiceheader
                             WHERE #tpr_paydetail_temp.ord_hdrnumber IS NOT NULL
                               AND invoiceheader.ord_hdrnumber IS NOT NULL
                               AND #tpr_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber
                               AND #tpr_paydetail_temp.ord_hdrnumber <> 0
                           )
 WHERE #tpr_paydetail_temp.ord_hdrnumber IS NOT NULL
   AND #tpr_paydetail_temp.ord_hdrnumber <> 0
   AND ivh_billdate	 IS NULL
   AND ivh_invoicenumber IS NULL

UPDATE #tpr_paydetail_temp
   SET ivh_billdate      = (SELECT MAX(ivh_billdate)
                              FROM invoiceheader
                             WHERE #tpr_paydetail_temp.mov_number IS NOT NULL
                               AND invoiceheader.mov_number IS NOT NULL
                               AND #tpr_paydetail_temp.mov_number = invoiceheader.mov_number
                               AND #tpr_paydetail_temp.mov_number <> 0
                           )
     , ivh_invoicenumber = (SELECT MAX(ivh_invoicenumber)
                              FROM invoiceheader
                             WHERE #tpr_paydetail_temp.mov_number IS NOT NULL
                               AND invoiceheader.mov_number IS NOT NULL
                               AND #tpr_paydetail_temp.mov_number = invoiceheader.mov_number
                               AND #tpr_paydetail_temp.mov_number <> 0
                           )
 WHERE #tpr_paydetail_temp.mov_number IS NOT NULL
   AND #tpr_paydetail_temp.mov_number <> 0
   AND ivh_billdate	 IS NULL
   AND ivh_invoicenumber IS NULL
--END PTS 53314 SPN

-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR 
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59') 
Begin
--BEGIN PTS 53314 SPN
--	 Update #tpr_paydetail_temp set ivh_billdate = invoiceheader.ivh_billdate , ivh_invoicenumber = invoiceheader.ivh_invoicenumber
--	 from 	invoiceheader  where #tpr_paydetail_temp.ord_hdrnumber > 0 and #tpr_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber and 
--			invoiceheader.ivh_billdate = (select max(ivh_billdate) from invoiceheader b
--							where #tpr_paydetail_temp.ord_hdrnumber = b.ord_hdrnumber and invoiceheader.ivh_hdrnumber = b.ivh_hdrnumber)
--END PTS 53314 SPN

	 Delete from #tpr_paydetail_temp  
	 where (ord_hdrnumber > 0 and ivh_billdate is NULL )
	 or (ord_hdrnumber > 0 and (ivh_billdate > @end_invoice_bill_date  or ivh_billdate < @beg_invoice_bill_date)) 
	

end 

if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR 
      @sch_date2 < convert(datetime, '2049-12-31 23:59') 
	Delete from #tpr_paydetail_temp
	where #tpr_paydetail_temp.ord_hdrnumber > 0 and 
		#tpr_paydetail_temp.ord_hdrnumber in (select ord_hdrnumber 
						from stops
						where stp_sequence = 1 and
							(stp_schdtearliest > @sch_date2  or 
							stp_schdtearliest < @sch_date1))	

-- Send result set back 
SELECT 
	asgn_type ,
	asgn_id ,
	pyd_payto ,
	pyt_itemcode,
	mov_number ,
	pyd_description ,
	pyd_quantity ,
	pyd_rate ,
	pyd_amount ,
	pyd_glnum ,
	pyd_pretax ,
	pyd_status ,
	pyd_refnumtype ,
	pyd_refnum ,
	pyh_payperiod ,
	pyd_workperiod ,
	lgh_startcity ,
	lgh_endcity ,
	tpr_name ,
	start_city ,
	end_city ,
	paydetail_pyt_itemcode ,
	ivh_billdate ,
	ivh_invoicenumber 
from  #tpr_paydetail_temp  
DROP TABLE #tpr_paydetail_temp  
  

GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_tpr_sp] TO [public]
GO
