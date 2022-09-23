SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*  
  Created to get driver item paydetail for settlement detail report  
*/  
  
CREATE   PROC	[dbo].[d_paydetail_report_id_item_sp] (
				@driver_id varchar(8), @driver_type1 varchar(6), @driver_type2 varchar(6), @driver_type3 varchar(6), @driver_type4 varchar(6), 
				@payment_status_array varchar(100), 
				@company varchar(6), @fleet varchar(6), @division varchar(6), 
					--@domicile varchar(6), -- PTS40222 commented out
				@mpp_terminal varchar(6), -- PTS40222 - SLM
				@beg_work_date datetime, @end_work_date datetime,  @beg_pay_date datetime, @end_pay_date datetime, 
				@payment_type_array varchar(8000),
				@driver_accounting_type varchar(6), @beg_transfer_date datetime, @end_transfer_date datetime,
				@beg_invoice_bill_date datetime, @end_invoice_bill_date datetime,
				@sch_date1 datetime, @sch_date2 datetime,
				@revtype1 varchar(6), @revtype2 varchar(6), @revtype3 varchar(6), @revtype4 varchar(6),
				@excl_revtype1 char(1), @excl_revtype2 char(1), @excl_revtype3 char(1), @excl_revtype4 char(1),
				@resourcetypeonleg char(1))      
AS  
SET NOCOUNT ON
/**  
 * DESCRIPTION:  
 *  
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
 * 01/02/2008.01 - PTS40222 - SLM  - Modify stored proc to restrict by mpp_terminal instead of mpp_domicile.  
 *                                  removed all references to mpp_domicile.  
 * -- PTS 35274 11/2008 JSwindell RECODE:  Add Revtype1 -> 4 and excl_revtype1 -> 4  
 * PTS 48237 - DJM - 6/15/2010 - Added 'resourcetypeonleg' parameter to allow the proc to look at the asset type  
 *       on the leg instead of just the Asset Master (Driver and Tractor only)  
 * 07/06/2010 PTS 52542 SPN  
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
CREATE TABLE #driver_item_paydetail_temp  (  
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
driver_name varchar(64) Null,  
start_city varchar(30) Null,   
end_city varchar(30) Null,  
paydetail_pyt_itemcode varchar(6) Null,  
ivh_billdate datetime Null,  
ivh_invoicenumber varchar(12) Null,  
-- PTS 25416 -- BL (start)  
pyh_number int null,  
-- PTS 25416 -- BL (end)  
-- PTS 31363 -- BL (start)  
--ord_hdrnumber int null)  
-- PTS 31363 -- BL (end)  
-- PTS 35274 11/2008 JSwindell RECODE<<start>>  
ord_hdrnumber int null,  
ord_revtype1 varchar(6) NULL,  
ord_revtype2 varchar(6) NULL,  
ord_revtype3 varchar(6) NULL,  
ord_revtype4 varchar(6) NULL,  
-- PTS 35274 11/2008 JSwindell RECODE<<end>>  
lgh_number int null)  
  
-- Get paydetail info  
INSERT INTO #driver_item_paydetail_temp  
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
manpowerprofile.mpp_lastname +', '+ manpowerprofile.mpp_firstname name ,   
sc.cty_nmstct,   
ec.cty_nmstct,   
paydetail.pyt_itemcode,  
-- PTS 19822 -- BL (start)   
--ivh_billdate,  
--ivh_invoicenumber   
-- PTS 31363 -- BL (start)  
-- (select max(ivh_billdate) from invoiceheader where ord_hdrnumber <> 0 and ord_hdrnumber = paydetail.ord_hdrnumber) ivh_billdate,  
-- (select max(ivh_invoicenumber) from invoiceheader where ivh_billdate =   
--  (select max(ivh_billdate) from invoiceheader where ord_hdrnumber <> 0 and ord_hdrnumber = paydetail.ord_hdrnumber)) ivh_invoicenumber,  
null ivh_billdate,  
null ivh_invoicenumber,   
-- PTS 31363 -- BL (end)  
-- PTS 19822 -- BL (end)   
-- PTS 25416 -- BL (start)  
paydetail.pyh_number,  
-- PTS 25416 -- BL (end)  
-- PTS 31363 -- BL (start)  
paydetail.ord_hdrnumber,  
-- PTS 31363 -- BL (end)  
-- PTS 35274 11/2008 JSwindell RECODE<<start>>  
orderheader.ord_revtype1,  
orderheader.ord_revtype2,  
orderheader.ord_revtype3,  
orderheader.ord_revtype4,  
-- PTS 35274 11/2008 JSwindell RECODE<<end>>  
paydetail.lgh_number -- PTS 48237  
  
-- PTS 35274 11/2008 JSwindell RECODE added LEFT OUTER JOIN orderheader... 1 line.   
FROM city sc  RIGHT OUTER JOIN  paydetail  ON  sc.cty_code  = paydetail.lgh_startcity     
  LEFT OUTER JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity  
  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber,    
  manpowerprofile  
-- PTS 19822 -- BL (start)   
-- (COMMENT OUT CODE)  
--  (select *  
--  from invoiceheader d  
--  where (convert(varchar(28), ivh_billdate, 20) + ivh_invoicenumber) =   
--  (select max(convert(varchar(28), ivh_billdate, 20) + ivh_invoicenumber)  
--  from invoiceheader e  
--  where e.ord_hdrnumber = d.ord_hdrnumber  
--  and e.ord_hdrnumber <> 0)) invoiceheader  
--WHERE paydetail.ord_hdrnumber *= invoiceheader.ord_hdrnumber and  
-- PTS 19822 -- BL (end)   
WHERE   
--sc.cty_code =* paydetail.lgh_startcity and   
--ec.cty_code =* paydetail.lgh_endcity and   
-- PTS 32226 -- BL (start)   (31363)  
--(paydetail.asgn_type = 'DRV' and @driver_id in ( 'UNKNOWN', paydetail.asgn_id)) and   
(paydetail.asgn_type = 'DRV' and (@driver_id = 'UNKNOWN' or @driver_id = paydetail.asgn_id)) and   
-- PTS 32226 -- BL (end)   (31363)  
--BEGIN PTS 52542 SPN  
--(@payment_type_array = ',,' OR CHARINDEX(',' + paydetail.pyt_itemcode + ',', @payment_type_array) > 0) AND  
(@payment_type_array = ',,' OR @payment_type_array = ',XXX,' OR  
  paydetail.pyt_itemcode IN (select temp_report_argument_value  
                               from temp_report_arguments  
                              where current_session_id = @@SPID  
                                and temp_report_name = 'PAYDETAIL_REPORT'  
                                and temp_report_argument_name = 'PAYTYPE'  
                                and temp_report_argument_value IS NOT NULL  
                            )  
) AND  
--END PTS 52542 SPN  
(@payment_status_array = ',,' OR CHARINDEX(',' + paydetail.pyd_status + ',', @payment_status_array) > 0) AND  
(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date) or (paydetail.pyd_transdate IS null)) and   
( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date) and   
(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) and   
paydetail.asgn_id = manpowerprofile.mpp_id and   
-- PTS 32226 -- BL (start)   (31363)  
--@driver_type1 in ('UNK', manpowerprofile.mpp_type1) and   
--@driver_type2 in ('UNK', manpowerprofile.mpp_type2) and   
--@driver_type3 in ('UNK', manpowerprofile.mpp_type3) and   
--@driver_type4 in ('UNK', manpowerprofile.mpp_type4) and   
--@company in ('UNK',manpowerprofile.mpp_company) and   
--@fleet in ('UNK', manpowerprofile.mpp_fleet) and   
--@division in ( 'UNK', manpowerprofile.mpp_division) and   
--@domicile in ('UNK', manpowerprofile.mpp_domicile ) and   
--@driver_accounting_type in ('X', manpowerprofile.mpp_actg_type)  
--(@driver_type1 = 'UNK' or @driver_type1 = manpowerprofile.mpp_type1) and   
--(@driver_type2 = 'UNK' or @driver_type2 = manpowerprofile.mpp_type2) and   
--(@driver_type3 = 'UNK' or @driver_type3 = manpowerprofile.mpp_type3) and   
--(@driver_type4 = 'UNK' or @driver_type4 = manpowerprofile.mpp_type4) and   
(@company = 'UNK' or @company = manpowerprofile.mpp_company) and   
(@fleet = 'UNK' or @fleet = manpowerprofile.mpp_fleet) and   
(@division = 'UNK' or @division = manpowerprofile.mpp_division) and   
--PTS40222 - SLM  replace domicile with mpp_terminal  
--(@domicile = 'UNK' or @domicile = manpowerprofile.mpp_domicile ) and   
(@driver_accounting_type = 'X' or @driver_accounting_type = manpowerprofile.mpp_actg_type)   
-- PTS 32226 -- BL (end)   (31363)  
  
-- PTS 25416 -- BL (start)  
if CHARINDEX('XFR', @payment_status_array) > 0 or CHARINDEX('COL', @payment_status_array) > 0   
-- Get paydetail info  
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
manpowerprofile.mpp_lastname +', '+ manpowerprofile.mpp_firstname name ,   
sc.cty_nmstct,   
ec.cty_nmstct,   
paydetail.pyt_itemcode,  
null ivh_billdate,  
null ivh_invoicenumber,   
paydetail.pyh_number,  
paydetail.ord_hdrnumber,  
orderheader.ord_revtype1,  
orderheader.ord_revtype2,  
orderheader.ord_revtype3,  
orderheader.ord_revtype4,  
paydetail.lgh_number 
FROM paydetail  LEFT JOIN   city sc ON  sc.cty_code  = paydetail.lgh_startcity     --change from RIGHT to LEFT JOIN
  LEFT  JOIN  city ec  ON  ec.cty_code  = paydetail.lgh_endcity  
  LEFT JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber    
  INNER JOIN manpowerprofile ON paydetail.asgn_id = manpowerprofile.mpp_id  --take out of where clause below
  INNER JOIN  payheader ph  ON paydetail.pyh_number = ph.pyh_pyhnumber --take out of where clause below

WHERE   

(paydetail.asgn_type = 'DRV' and (@driver_id = 'UNKNOWN' or @driver_id = paydetail.asgn_id)) and   

(@payment_type_array = ',,' OR @payment_type_array = ',XXX,' OR  
  paydetail.pyt_itemcode IN (select temp_report_argument_value  
                               from temp_report_arguments  
                              where current_session_id = @@SPID  
 and temp_report_name = 'PAYDETAIL_REPORT'  
                                and temp_report_argument_name = 'PAYTYPE'  
                                and temp_report_argument_value IS NOT NULL  
                            )  
) AND  

(( paydetail.pyd_transdate between @beg_transfer_date and @end_transfer_date) or (paydetail.pyd_transdate IS null)) and   
( paydetail.pyh_payperiod between @beg_pay_date and @end_pay_date) and   
(paydetail.pyd_workperiod between @beg_work_date and @end_work_date OR paydetail.pyd_workperiod IS null) and   
(@company = 'UNK' or @company = manpowerprofile.mpp_company) and   
(@fleet = 'UNK' or @fleet = manpowerprofile.mpp_fleet) and   
(@division = 'UNK' or @division = manpowerprofile.mpp_division) and   

(@driver_accounting_type = 'X' or @driver_accounting_type = manpowerprofile.mpp_actg_type)  
 and (CHARINDEX(',' + ph.pyh_paystatus + ',', ',XFR,COL,') > 0)  
 and paydetail.pyh_number not in   
  (select distinct pyh_number  
  from #driver_item_paydetail_temp) 
  
--PTS 48237 - DJM  
 if @resourcetypeonleg = 'N'  
  Begin  
  
   IF @driver_type1 <> 'UNK'  
    delete #driver_item_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type1 <> @driver_type1  
  
   IF @driver_type2 <> 'UNK'  
    delete #driver_item_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type2 <> @driver_type2  
  
   IF @driver_type3 <> 'UNK'  
    delete #driver_item_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type3 <> @driver_type3  
     
   IF @driver_type4 <> 'UNK'  
    delete #driver_item_paydetail_temp from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type4 <> @driver_type4  
  end  
 else  
  Begin  
   IF @driver_type1 <> 'UNK'  
    delete #driver_item_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_item_paydetail_temp.lgh_number and isNull(#driver_item_paydetail_temp.lgh_number,0) > 0 and l.mpp_type1 <> @driver_type1  
  
   IF @driver_type2 <> 'UNK'  
    delete #driver_item_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_item_paydetail_temp.lgh_number and isNull(#driver_item_paydetail_temp.lgh_number,0) > 0 and l.mpp_type2 <> @driver_type2  
  
   IF @driver_type3 <> 'UNK'  
    delete #driver_item_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_item_paydetail_temp.lgh_number and isNull(#driver_item_paydetail_temp.lgh_number,0) > 0 and l.mpp_type3 <> @driver_type3  
     
   IF @driver_type4 <> 'UNK'  
    delete #driver_item_paydetail_temp from legheader l where asgn_type = 'DRV' and l.lgh_number = #driver_item_paydetail_temp.lgh_number and isNull(#driver_item_paydetail_temp.lgh_number,0) > 0 and l.mpp_type4 <> @driver_type4  
    
  End  
-- End 48237  
  
--BEGIN PTS 52542 SPN  
---- PTS 31363 -- BL (start)  
---- Update billdate and invoicenumber rather than set it during the insert  
--update  #driver_item_paydetail_temp  
--set  ivh_billdate = (SELECT  max(ivh_billdate)  
--      from  invoiceheader  
--      where #driver_item_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber)  
--where #driver_item_paydetail_temp.ord_hdrnumber > 0  
--  
--update  #driver_item_paydetail_temp  
--set  ivh_invoicenumber = (select max(ivh_invoicenumber)   
--       from  invoiceheader   
--       where  ivh_billdate = #driver_item_paydetail_temp.ivh_billdate)  
--where  #driver_item_paydetail_temp.ord_hdrnumber > 0  
---- PTS 31363 -- BL (end)  
UPDATE #driver_item_paydetail_temp  
   SET ivh_billdate      = (SELECT MAX(ivh_billdate)  
                              FROM invoiceheader  
                             WHERE #driver_item_paydetail_temp.ord_hdrnumber IS NOT NULL  
                               AND invoiceheader.ord_hdrnumber IS NOT NULL  
                               AND #driver_item_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber  
                               AND #driver_item_paydetail_temp.ord_hdrnumber <> 0  
                           )  
     , ivh_invoicenumber = (SELECT MAX(ivh_invoicenumber)  
                              FROM invoiceheader  
                             WHERE #driver_item_paydetail_temp.ord_hdrnumber IS NOT NULL  
                               AND invoiceheader.ord_hdrnumber IS NOT NULL  
                               AND #driver_item_paydetail_temp.ord_hdrnumber = invoiceheader.ord_hdrnumber  
                               AND #driver_item_paydetail_temp.ord_hdrnumber <> 0  
                           )  
 WHERE #driver_item_paydetail_temp.ord_hdrnumber IS NOT NULL  
   AND #driver_item_paydetail_temp.ord_hdrnumber <> 0  
   AND ivh_billdate  IS NULL  
   AND ivh_invoicenumber IS NULL  
  
UPDATE #driver_item_paydetail_temp  
   SET ivh_billdate      = (SELECT MAX(ivh_billdate)  
                              FROM invoiceheader  
                             WHERE #driver_item_paydetail_temp.mov_number IS NOT NULL  
                               AND invoiceheader.mov_number IS NOT NULL  
                               AND #driver_item_paydetail_temp.mov_number = invoiceheader.mov_number  
                               AND #driver_item_paydetail_temp.mov_number <> 0  
                           )  
     , ivh_invoicenumber = (SELECT MAX(ivh_invoicenumber)  
                              FROM invoiceheader  
                             WHERE #driver_item_paydetail_temp.mov_number IS NOT NULL  
                               AND invoiceheader.mov_number IS NOT NULL  
                               AND #driver_item_paydetail_temp.mov_number = invoiceheader.mov_number  
                               AND #driver_item_paydetail_temp.mov_number <> 0  
                           )  
 WHERE #driver_item_paydetail_temp.mov_number IS NOT NULL  
   AND #driver_item_paydetail_temp.mov_number <> 0  
   AND ivh_billdate  IS NULL  
   AND ivh_invoicenumber IS NULL  
--END PTS 52542 SPN  
  
-- See if user entered in an Invoice bill_date range  
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR   
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59')   
Begin  
 -- Remove paydetails that do NOT fit in given invoice bill_date range  
 Delete from #driver_item_paydetail_temp    
 where ivh_billdate is NULL   
 or ivh_billdate > @end_invoice_bill_date   
 or ivh_billdate < @beg_invoice_bill_date   
end   
  
--LOR PTS# 32588  
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR   
      @sch_date2 < convert(datetime, '2049-12-31 23:59')   
 Delete from #driver_item_paydetail_temp  
 where #driver_item_paydetail_temp.ord_hdrnumber > 0 and   
  #driver_item_paydetail_temp.ord_hdrnumber in (select ord_hdrnumber   
      from stops  
      where stp_sequence = 1 and  
       (stp_schdtearliest > @sch_date2  or   
       stp_schdtearliest < @sch_date1))   
-- LOR  
  
-- Send result set back   
--SELECT * from #driver_item_paydetail_temp    
  
-- BEGIN PTS 40222 Remove reference to @domicile  
IF @mpp_terminal <> 'UNK'  
 delete #driver_item_paydetail_temp from manpowerprofile mp where asgn_type = 'DRV' and asgn_id = mp.mpp_id and mp.mpp_terminal <> @mpp_terminal  
  
  
-- PTS 35274 11/2008 JSwindell RECODE<<start>>  
 -- LOR PTS# 35274  
 IF isNull(@revtype1,'UNK') <> 'UNK'  
  Begin  
   If @excl_revtype1 = 'Y'  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype1,'UNK') = @revtype1  
   Else  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype1,'UNK') <> @revtype1  
  End  
 IF isNull(@revtype2,'UNK') <> 'UNK'  
  Begin  
   If @excl_revtype2 = 'Y'  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype2,'UNK') = @revtype2  
   Else  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype2,'UNK') <> @revtype2  
  End  
 IF isNull(@revtype3,'UNK') <> 'UNK'  
  Begin  
   If @excl_revtype3 = 'Y'  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype3,'UNK') = @revtype3  
   Else  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype3,'UNK') <> @revtype3  
  End  
 IF isNull(@revtype4,'UNK') <> 'UNK'  
  Begin  
   If @excl_revtype4 = 'Y'  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype4,'UNK') = @revtype4  
   Else  
    DELETE FROM #driver_item_paydetail_temp WHERE isNull(#driver_item_paydetail_temp.ord_revtype4,'UNK') <> @revtype4  
  End  
 -- LOR  
-- PTS 35274 11/2008 JSwindell RECODE<<end>>  
  
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
 pyd_status,   
 pyd_refnumtype,   
 pyd_refnum ,   
 pyh_payperiod,   
 pyd_workperiod,   
 lgh_startcity,   
 lgh_endcity,   
 driver_name,  
 start_city,   
 end_city,  
-- PTS 34067 -- BL (start)  
-- paydetail_pyt_itemcodel,  
 paydetail_pyt_itemcode,  
-- PTS 34067 -- BL (start)  
 ivh_billdate,  
 ivh_invoicenumber,  
-- PTS 35274 11/2008 JSwindell RECODE<<start>>  
 pyh_number,  
 ord_hdrnumber   
-- PTS 35274 11/2008 JSwindell RECODE<<end>>  
from #driver_item_paydetail_temp    
  
DROP TABLE #driver_item_paydetail_temp    
    
GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_id_item_sp] TO [public]
GO
