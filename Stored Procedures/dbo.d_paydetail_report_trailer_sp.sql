SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROC	[dbo].[d_paydetail_report_trailer_sp] (
				@trailer_number varchar(13), @trailer_type1 varchar(6), @trailer_type2 varchar(6), 
				@trailer_type3 varchar(6), @trailer_type4 varchar(6), @payment_status_array varchar(100), 
				@company varchar(6), @fleet varchar(6), @division varchar(6), @domicile varchar(6),
				@beg_work_date datetime, @end_work_date datetime, 
				@beg_pay_date datetime, @end_pay_date datetime, @payment_type_array varchar(8000),
				@trailer_accounting_type varchar(1), @beg_transfer_date datetime, @end_transfer_date datetime,
				@beg_invoice_bill_date datetime, @end_invoice_bill_date datetime,
				@sch_date1 datetime, @sch_date2 datetime,    
				@revtype1 varchar(6), @revtype2 varchar(6), @revtype3 varchar(6), @revtype4 varchar(6),
				@excl_revtype1 char(1), @excl_revtype2 char(1), @excl_revtype3 char(1), @excl_revtype4 char(1))     
AS  
/**
 * DESCRIPTION:
 *   Created to get trailer paydetail for settlement detail report  
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * -- PTS 35274 11/2008 JSwindell RECODE:  Add Revtype1 -> 4 and excl_revtype1 -> 4
 * -- PTS 51698 05/2010 SPN - introducing subquery from temp_report_arguments instead of payment_type_array
 * -- PTS 53314 07/2010 SPN - getting appropriate invoice date and number by move or ord_hdrnumber
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
CREATE TABLE #trailer_paydetail_temp  (
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
trailer_name varchar(64) Null,
start_city varchar(30) Null, 
end_city varchar(30) Null,
paydetail_pyt_itemcode varchar(6) Null,
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
ord_hdrnumber int null,
-- PTS 25416 -- BL (start)
pyh_number int null,
-- PTS 25416 -- BL (end)
-- PTS 35274 11/2008 JSwindell RECODE<<start>>
ord_revtype1 varchar(6) NULL,
ord_revtype2 varchar(6) NULL,
ord_revtype3 varchar(6) NULL,
ord_revtype4 varchar(6) NULL)
-- PTS 35274 11/2008 JSwindell RECODE<<end>>

-- Get paydetail info
INSERT INTO #trailer_paydetail_temp
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
null ,--t.trl_owner +' ' + t.trl_make name , 
sc.cty_nmstct, 
ec.cty_nmstct, 
paydetail.pyt_itemcode,
NULL,
NULL,
paydetail.ord_hdrnumber,
-- PTS 25416 -- BL (start)
--paydetail.pyh_number
-- PTS 25416 -- BL (end)
-- PTS 35274 11/2008 JSwindell RECODE<<start>>
paydetail.pyh_number,
		 orderheader.ord_revtype1,
		 orderheader.ord_revtype2,
		 orderheader.ord_revtype3,
		 orderheader.ord_revtype4
-- PTS 35274 11/2008 JSwindell RECODE<<end>>

-- PTS 35274 11/2008 JSwindell RECODE added LEFT OUTER JOIN orderheader... 1 line.
FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity   
			  LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity
			  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber   
--trailerprofile t , 
WHERE 	(paydetail.asgn_type = 'TRL') and 
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
		--@trailer_number in ( 'UNKNOWN', paydetail.asgn_id)) and 
		--sc.cty_code =* paydetail.lgh_startcity and 
		--ec.cty_code =* paydetail.lgh_endcity 
/*		paydetail.asgn_id = t.trl_id and 
		@trailer_type1 in ('UNK', t.trl_type1) and 
		@trailer_type2 in ('UNK',t.trl_type2) and 
		@trailer_type3 in ('UNK', t.trl_type3) and 
		@trailer_type4 in ('UNK', t.trl_type4) and 
		@company in ('UNK',t.trl_company) and 
		@fleet in ('UNK', t.trl_fleet) and 
		@division in ( 'UNK', t.trl_division) and 
		@domicile in ('UNK', t.trl_terminal ) and 
		@trailer_accounting_type in ('X', t.trl_actg_type)*/


-- PTS 25416 -- BL (start)
if CHARINDEX('XFR', @payment_status_array) > 0 or CHARINDEX('COL', @payment_status_array) > 0 
-- Get paydetail info
INSERT INTO #trailer_paydetail_temp
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
null ,--t.trl_owner +' ' + t.trl_make name , 
sc.cty_nmstct, 
ec.cty_nmstct, 
paydetail.pyt_itemcode,
NULL,
NULL,
paydetail.ord_hdrnumber,
paydetail.pyh_number,
-- PTS 35274 11/2008 JSwindell RECODE<<start>>
	 orderheader.ord_revtype1,
	 orderheader.ord_revtype2,
	 orderheader.ord_revtype3,
	 orderheader.ord_revtype4
-- PTS 35274 11/2008 JSwindell RECODE<<end>>

-- PTS 35274 11/2008 JSwindell RECODE added LEFT OUTER JOIN orderheader... 1 line.
FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity   
		LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity
		LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber,
				--trailerprofile t , 
		payheader ph 
WHERE 	(paydetail.asgn_type = 'TRL') and 
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
--		(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) AND
		--@trailer_number in ( 'UNKNOWN', paydetail.asgn_id)) and 
		--sc.cty_code =* paydetail.lgh_startcity and 
		--ec.cty_code =* paydetail.lgh_endcity 
/*		paydetail.asgn_id = t.trl_id and 
		@trailer_type1 in ('UNK', t.trl_type1) and 
		@trailer_type2 in ('UNK',t.trl_type2) and 
		@trailer_type3 in ('UNK', t.trl_type3) and 
		@trailer_type4 in ('UNK', t.trl_type4) and 
		@company in ('UNK',t.trl_company) and 
		@fleet in ('UNK', t.trl_fleet) and 
		@division in ( 'UNK', t.trl_division) and 
		@domicile in ('UNK', t.trl_terminal ) and 
		@trailer_accounting_type in ('X', t.trl_actg_type)*/
	and paydetail.pyh_number = ph.pyh_pyhnumber 
	and (CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0)
	and paydetail.pyh_number not in 
		(select distinct pyh_number
		from #trailer_paydetail_temp)
-- PTS 25416 -- BL (end)
-- PTS 19738 - DJM - Modified SQL to reference trailerprofile by trl_id instead of trl_number

	IF @trailer_number <> 'UNKNOWN' 
		delete #trailer_paydetail_temp  where asgn_type = 'TRL' and asgn_id <> @trailer_number

	IF @company <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_company <> @company

	IF @fleet <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_fleet <> @fleet

	IF @division <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_division <> @division

	IF @domicile <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_terminal <> @domicile

	IF @trailer_type1 <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type1 <> @trailer_type1

	IF @trailer_type2 <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type2 <> @trailer_type2

	IF @trailer_type3 <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type3 <> @trailer_type3
	
	IF @trailer_type4 <> 'UNK'
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type4 <> @trailer_type4

	IF @trailer_accounting_type <>'X' 
		delete #trailer_paydetail_temp from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_actg_type <> @trailer_accounting_type 

	Update #trailer_paydetail_temp set trailer_name = trl_owner + ' ' + trl_make from trailerprofile where asgn_type = 'TRL' and asgn_id = trl_id




--BEGIN PTS 53314 SPN
UPDATE #trailer_paydetail_temp
   SET ivh_billdate      = (SELECT MAX(ivh_billdate)
                              FROM invoiceheader
                             WHERE #trailer_paydetail_temp.ord_hdrnumber IS NOT NULL
                               AND invoiceheader.ord_hdrnumber IS NOT NULL
                               AND #trailer_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber
                               AND #trailer_paydetail_temp.ord_hdrnumber <> 0
                           )
     , ivh_invoicenumber = (SELECT MAX(ivh_invoicenumber)
                              FROM invoiceheader
                             WHERE #trailer_paydetail_temp.ord_hdrnumber IS NOT NULL
                               AND invoiceheader.ord_hdrnumber IS NOT NULL
                               AND #trailer_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber
                               AND #trailer_paydetail_temp.ord_hdrnumber <> 0
                           )
 WHERE #trailer_paydetail_temp.ord_hdrnumber IS NOT NULL
   AND #trailer_paydetail_temp.ord_hdrnumber <> 0
   AND ivh_billdate	 IS NULL
   AND ivh_invoicenumber IS NULL

UPDATE #trailer_paydetail_temp
   SET ivh_billdate      = (SELECT MAX(ivh_billdate)
                              FROM invoiceheader
                             WHERE #trailer_paydetail_temp.mov_number IS NOT NULL
                               AND invoiceheader.mov_number IS NOT NULL
                               AND #trailer_paydetail_temp.mov_number = invoiceheader.mov_number
                               AND #trailer_paydetail_temp.mov_number <> 0
                           )
     , ivh_invoicenumber = (SELECT MAX(ivh_invoicenumber)
                              FROM invoiceheader
                             WHERE #trailer_paydetail_temp.mov_number IS NOT NULL
                               AND invoiceheader.mov_number IS NOT NULL
                               AND #trailer_paydetail_temp.mov_number = invoiceheader.mov_number
                               AND #trailer_paydetail_temp.mov_number <> 0
                           )
 WHERE #trailer_paydetail_temp.mov_number IS NOT NULL
   AND #trailer_paydetail_temp.mov_number <> 0
   AND ivh_billdate	 IS NULL
   AND ivh_invoicenumber IS NULL
--END PTS 53314 SPN

-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR 
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59') 
Begin
--BEGIN PTS 53314 SPN
--	 Update #trailer_paydetail_temp set ivh_billdate = invoiceheader.ivh_billdate , ivh_invoicenumber = invoiceheader.ivh_invoicenumber
--	 from 	invoiceheader  where #trailer_paydetail_temp.ord_hdrnumber > 0 and #trailer_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber and 
--			invoiceheader.ivh_billdate = (select max(ivh_billdate) from invoiceheader b
--												where #trailer_paydetail_temp.ord_hdrnumber = b.ord_hdrnumber and invoiceheader.ivh_hdrnumber = b.ivh_hdrnumber)
--END PTS 53314 SPN

	 Delete from #trailer_paydetail_temp  
	 where (ord_hdrnumber > 0 and ivh_billdate is NULL )
	 or (ord_hdrnumber > 0 and (ivh_billdate > @end_invoice_bill_date  or ivh_billdate < @beg_invoice_bill_date)) 
	

end 

--LOR	PTS# 32588
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR 
      @sch_date2 < convert(datetime, '2049-12-31 23:59') 
	Delete from #trailer_paydetail_temp
	where #trailer_paydetail_temp.ord_hdrnumber > 0 and 
		#trailer_paydetail_temp.ord_hdrnumber in (select ord_hdrnumber 
						from stops
						where stp_sequence = 1 and
							(stp_schdtearliest > @sch_date2  or 
							stp_schdtearliest < @sch_date1))	
-- LOR

-- PTS 35274 11/2008 JSwindell RECODE<<start>>
	--	LOR	PTS# 35274
	IF isNull(@revtype1,'UNK') <> 'UNK'
		Begin
			If @excl_revtype1 = 'Y'
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype1,'UNK') = @revtype1
			Else
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype1,'UNK') <> @revtype1
		End
	IF isNull(@revtype2,'UNK') <> 'UNK'
		Begin
			If @excl_revtype2 = 'Y'
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype2,'UNK') = @revtype2
			Else
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype2,'UNK') <> @revtype2
		End
	IF isNull(@revtype3,'UNK') <> 'UNK'
		Begin
			If @excl_revtype3 = 'Y'
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype3,'UNK') = @revtype3
			Else
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype3,'UNK') <> @revtype3
		End
	IF isNull(@revtype4,'UNK') <> 'UNK'
		Begin
			If @excl_revtype4 = 'Y'
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype4,'UNK') = @revtype4
			Else
				DELETE FROM #trailer_paydetail_temp WHERE isNull(#trailer_paydetail_temp.ord_revtype4,'UNK') <> @revtype4
		End
	--	LOR
-- PTS 35274 11/2008 JSwindell RECODE<<end>>

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
	trailer_name ,
	start_city ,
	end_city ,
	paydetail_pyt_itemcode ,
	ivh_billdate ,
	ivh_invoicenumber 
from  #trailer_paydetail_temp  
DROP TABLE #trailer_paydetail_temp  
  
GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_trailer_sp] TO [public]
GO
