SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROC [dbo].[SSRS_RB_SETTLEMENT_ByLegHeaderNumber](@lgh_number int)  
AS  
 
-- CREATE a temp table to the pay header AND detail numbers  
CREATE TABLE #temp_pay (  
 pyd_number INT NOT NULL,  
 pyh_number INT NOT NULL,  
 pyd_status VARCHAR(6) NULL,  
 asgn_type1 VARCHAR(6) NULL)  
  
 -- Get the driver pay header AND detail numbers for pay released to this payperiod  
 -- AND collected   
 
  INSERT INTO #temp_pay  
  SELECT pd.pyd_number, pd.pyh_number, pd.pyd_status, ph.asgn_id  
    FROM paydetail pd
	join payheader ph  on pd.pyh_number = ph.pyh_pyhnumber
   WHERE pd.lgh_number = @lgh_number  
    
  
-- CREATE a temp table to hold the pay header AND detail numbers  
-- CREATE a temp table to hold the pay details  
CREATE TABLE #temp_pd(  
 pyd_number  INT NOT NULL,  
 pyh_number  INT NOT NULL,  
 asgn_number  INT NULL,  
 asgn_type  VARCHAR(6) NOT NULL,  
 asgn_id   VARCHAR(13) NOT NULL,  
 ivd_number  INT NULL,  
 pyd_prorap  VARCHAR(6) NULL,   
 pyd_payto  VARCHAR(20) NULL,   
 pyt_itemcode  VARCHAR(6) NULL,   
 pyt_fee1  MONEY NULL,  
 pyt_fee2  MONEY NULL,  
 pyd_description  VARCHAR(200) NULL,   
 pyr_ratecode  VARCHAR(6) NULL,   
 pyd_quantity  FLOAT NULL,  --extension (BTC)  
 pyd_rateunit  VARCHAR(6) NULL,  
 pyd_unit  VARCHAR(6) NULL,  
 pyd_pretax  char(1) NULL,  
 pyd_status  VARCHAR(6) NULL,  
 pyh_payperiod  DATETIME NULL,  
 lgh_startcity  INT NULL,  
 lgh_endcity  INT NULL,  
 pyd_MINus  INT NULL,  
 pyd_workperiod  DATETIME NULL,  
 pyd_sequence  INT NULL,  
 pyd_rate  MONEY NULL,  --rate (BTC)  
 pyd_amount  FLOAT NULL,  
 pyd_payrevenue  MONEY NULL,    
 mov_number  INT NULL,  
 lgh_number  INT NULL,  
 ord_hdrnumber  int NULL,  
 pyd_transdate  DATETIME NULL,  
 payperiodstart  DATETIME NULL,  
 payperiodend  DATETIME NULL,  
 pyd_loadstate  VARCHAR(6) NULL,  
 summary_code  VARCHAR(6) NULL,  
 name   VARCHAR(150) NULL,  
 terMINal  VARCHAR(12) NULL,  
 type1   VARCHAR(12) NULL,  
 pyh_totalcomp  MONEY NULL,  
 pyh_totaldeduct  MONEY NULL,  
 pyh_totalreimbrs MONEY NULL,  
 crd_cardnumber  CHAR(40) NULL, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/  
 lgh_startdate  DATETIME NULL,  
 std_balance  MONEY NULL,  
 itemsection  INT NULL,  
 ord_startdate  DATETIME NULL,  
 ord_number  VARCHAR(20) NULL,  
 ref_number  VARCHAR(30) NULL,  
 stp_arrivaldate  DATETIME NULL,  
 shipper_name  VARCHAR(150) NULL,  
 shipper_city  VARCHAR(60) NULL,  
 shipper_state  CHAR(6) NULL,  
 consignee_name  VARCHAR(150) NULL,  
 consignee_city  VARCHAR(60) NULL,  
 consignee_state  char(6) NULL,  
 cmd_name  VARCHAR(100) NULL,  
 pyd_billedweight INT NULL,  --billed weight (BTC)  
 adjusted_billed_rate MONEY NULL,  --rate (BTC)  
 cht_basis  VARCHAR(6) NULL,  
 cht_basisunit  VARCHAR(6) NULL,  
 cht_unit  VARCHAR(6) NULL,  
 cht_rateunit  VARCHAR(6) NULL,  
 std_number  INT NULL,  
 stp_number  INT NULL,  
 unc_factor  FLOAT NULL,  
 stp_mfh_sequence INT NULL,  
 pyt_description  VARCHAR(150) NULL,  
 cht_itemcode  VARCHAR(6) NULL,  
 userlabelname  VARCHAR(200) NULL,  
 label_name  VARCHAR(20) NULL,  
 otherid   VARCHAR(12) NULL,  --this is the error need to fix it in the template ssrs sttlement sheet proc
 trc_drv   VARCHAR(8) NULL,  
 start_city  VARCHAR(60) NULL,  
 start_state  CHAR(2) NULL,  
 end_city  VARCHAR(60) NULL,  
 end_state  CHAR(2) NULL,  
 lgh_count  INT NULL,  
 pyh_issuedate DATETIME NULL,
 pyd_glnum VARCHAR(100)NULL,
 tar_tarriffnumber INT NULL)  
  --pyt_ap_glnum
  --pyd_glnum
  
-- Insert into the temp pay details table with the paydetail data per #temp_pay  
INSERT INTO #temp_pd  
SELECT pd.pyd_number,  
 pd.pyh_number,  
 pd.asgn_number,  
 pd.asgn_type,  
 pd.asgn_id,  
 pd.ivd_number,  
 pd.pyd_prorap,  
 pd.pyd_payto,  
 pd.pyt_itemcode,  
 pd.pyt_fee1,  
 pd.pyt_fee2,  
 --pd.pyd_mileagetable,  
 pd.pyd_description,  
 pd.pyr_ratecode,  
 pd.pyd_quantity,  
 pd.pyd_rateunit,   
 pd.pyd_unit,  
 pd.pyd_pretax,  
 tp.pyd_status,  
 pd.pyh_payperiod,  
 pd.lgh_startcity,  
 pd.lgh_endcity,  
 pd.pyd_MINus,  
 pd.pyd_workperiod,  
 pd.pyd_sequence,  
 pd.pyd_rate,  
 ROUND(pd.pyd_amount, 2),  
 pd.pyd_payrevenue,  
 pd.mov_number,    
 pd.lgh_number,    
 pd.ord_hdrnumber,  
 pd.pyd_transdate,  
 ph.pyh_payperiod,  
 '',  
 pd.pyd_loadstate,  
 pd.pyd_unit,  
 '' Name,  
 '' Terminal,  
 tp.asgn_type1,  
 0.0,  
 0.0,  
 0.0,  
 NULL,  
 NULL,  
 NULL,  
 0,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 pd.pyd_billedweight,  
 0.0,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 pd.std_number,  
 NULL,  
 1.0,  
 NULL,  
 NULL,  
 pd.cht_itemcode,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 NULL,  
 0,  
 NULL  ,
 pd.pyd_glnum,
pd.tar_tarriffnumber
FROM paydetail pd
join #temp_pay tp on pd.pyd_number = tp.pyd_number  
join payheader ph on pd.pyh_number = ph.PYH_pyhnumber


  
--Update the temp pay details with legheader data  
UPDATE #temp_pd  
SET mov_number = lh.mov_number,  
 lgh_number = lh.lgh_number,  
 lgh_startdate = lh.lgh_startdate  
FROM  legheader lh  
WHERE #temp_pd.lgh_number = lh.lgh_number  
   
UPDATE #temp_pd      
   SET lgh_count = (SELECT COUNT(lgh_number)       
                      FROM legheader lh       
                     WHERE lh.mov_number = #temp_pd.mov_number)     
  
--Update the temp pay details with orderheader data  
UPDATE #temp_pd  
SET ord_startdate = oh.ord_startdate,  
 ord_number = oh.ord_number  
FROM  orderheader oh  
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber  
  
UPDATE #temp_pd      
   SET ord_number = ord_number + '/S'      
 WHERE ord_hdrnumber > 0       
       AND lgh_count > 1   
  
--Update the temp pay details with shipper data  
UPDATE #temp_pd  
SET shipper_name = co.cmp_name,  
 shipper_city = ct.cty_name,  
 shipper_state = ct.cty_state  
FROM  company co
	join city ct on co.cmp_city = ct.cty_code  
	join orderheader oh  on oh.ord_shipper = co.cmp_id 
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber  
  AND oh.ord_shipper <> 'UNKNOWN'   
  
UPDATE #temp_pd  
SET  shipper_name = 'UNKNOWN',  
 shipper_city = ct.cty_name,  
 shipper_state = ct.cty_state  
FROM    orderheader oh
	join city ct  on oh.ord_origincity  = ct.cty_code 
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber  
  AND oh.ord_shipper = 'UNKNOWN'   
  
  
  
--Update the temp pay details with consignee data  
UPDATE #temp_pd  
SET consignee_name = co.cmp_name,  
 consignee_city = ct.cty_name,  
 consignee_state = ct.cty_state  
FROM  company co
	join city ct on co.cmp_city = ct.cty_code   
	join orderheader oh  on oh.ord_consignee = co.cmp_id 
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber  
  AND oh.ord_consignee <> 'UNKNOWN'  
  
UPDATE #temp_pd  
SET  consignee_name  = 'UNKNOWN',  
 consignee_city  = ct.cty_name,  
 consignee_state  = ct.cty_state  
FROM    orderheader oh
	join city ct  on oh.ord_destcity  = ct.cty_code 
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber  
    AND oh.ord_consignee = 'UNKNOWN'   
  
  
--Update the temp pay details with stANDingdeduction data  
UPDATE #temp_pd  
SET std_balance = sd.std_balance  
FROM  stANDingdeduction sd  
WHERE #temp_pd.std_number = sd.std_number  
  
  
--Update the temp pay details for summary code  
UPDATE #temp_pd  
SET summary_code = 'OTHER'  
WHERE summary_code != 'MIL'  
  
--Update the temp pay details for load status  
UPDATE #temp_pd  
SET pyd_loadstate = 'NA'  
WHERE pyd_loadstate IS NULL  
  
--Update the temp pay details with payheader data  
UPDATE #temp_pd  
SET crd_cardnumber = ph.crd_cardnumber,  
pyh_issuedate = ISNULL(ph.pyh_issuedate,ph.pyh_payperiod)  
FROM  payheader ph  
WHERE #temp_pd.pyh_number = ph.pyh_pyhnumber  
  
--Update the temp pay details with paytype data  
UPDATE #temp_pd  
SET pyt_description = pt.pyt_description  
FROM  paytype pt  
WHERE #temp_pd.pyt_itemcode = pt.pyt_itemcode 


UPDATE #temp_pd  
SET pyd_glnum = pt.pyt_ap_glnum
FROM  paytype pt  
WHERE #temp_pd.pyt_itemcode = pt.pyt_itemcode 
AND ISNULL(pyd_glnum,'') = ''


--Need to get the stop of the 1st delivery AND find the commodity AND arrival date  
--associated with it.  
--Update the temp pay details table with stop data for the 1st unload stop  
UPDATE #temp_pd  
SET stp_mfh_sequence = (SELECT MIN(st.stp_mfh_sequence)  
 FROM stops st  
  
 WHERE st.ord_hdrnumber > 0 AND #temp_pd.ord_hdrnumber > 0 --JD Added this clause to stop joins on zero ord_hdrnumbers 35949  
   AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber  
   AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL'))   
  
  
UPDATE #temp_pd  
SET stp_number = st.stp_number  
FROM stops st  
WHERE st.ord_hdrnumber > 0 AND #temp_pd.ord_hdrnumber > 0 --JD Added this clause to stop joins on zero ord_hdrnumbers 35949  
 AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber  
  AND st.stp_mfh_sequence = #temp_pd.stp_mfh_sequence  
  
--Update the temp pay details with commodity data  
UPDATE #temp_pd  
SET cmd_name = cd.cmd_name,  
 stp_arrivaldate = st.stp_arrivaldate  
FROM   freightdetail fd
	join commodity cd on cd.cmd_code = fd.cmd_code 
	join stops st  on fd.stp_number = st.stp_number  
WHERE st.stp_number = #temp_pd.stp_number  

  
--Need to get the bill-of-lading FROM the reference number table  
--Update the temp pay details with reference number data  
UPDATE #temp_pd  
SET ref_number = rn.ref_number  
FROM  referencenumber rn  
WHERE rn.ref_tablekey = #temp_pd.ord_hdrnumber  
  AND rn.ref_table = 'orderheader'  
  AND rn.ref_type = 'SID'  
  
--Need to get revenue charge type data FROM the chargetype table  
UPDATE #temp_pd  
SET cht_basis = ct.cht_basis,  
 cht_basisunit = ct.cht_basisunit,  
 cht_unit = ct.cht_unit,  
 cht_rateunit = ct.cht_rateunit  
FROM  chargetype ct  
WHERE #temp_pd.cht_itemcode = ct.cht_itemcode  
  
UPDATE #temp_pd  
SET unc_factor = uc.unc_factor  
FROM unitconversion uc  
WHERE uc.unc_FROM = #temp_pd.cht_basisunit  
  AND uc.unc_to = #temp_pd.cht_rateunit  
  AND uc.unc_convflag = 'R'  
  
UPDATE #temp_pd  
SET adjusted_billed_rate = ROUND(pyd_payrevenue / pyd_billedweight / unc_factor, 2)  
WHERE pyd_billedweight > 0  
  AND unc_factor > 0  
  AND pyd_payrevenue > 0  
  
--CREATE a temp table for YTD balances  
CREATE TABLE #YTDBAL (asgn_type VARCHAR (6) NOT NULL,  
 asgn_id   VARCHAR (13) NOT NULL,  
 ytdcomp   MONEY NULL,  
 ytddeduct  MONEY NULL,  
 ytdreimbrs  MONEY NULL,  
 pyh_payperiod  DATETIME NULL,  
 pyh_issuedate  DATETIME NULL)  
  
--Insert into the temp YTD balances table the assets FROM the temp pay details table  
-- JD pts 28499 06/29/05 commented the following insert out, this table needs to have just one row for the later update on the #temp_pd table to work consistently  
-- we are running into issues when the ytdbal has 2 rows since we have details that are on the 12/31/49 payperiod.  
--INSERT INTO #YTDBAL  
--SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate  
--FROM #temp_pd  
  
  
UPDATE #YTDBAL  
SET ytdcomp = ytdcomp + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))  
   FROM #temp_pd tp  
   WHERE tp.asgn_id = yb.asgn_id  
     AND tp.asgn_type = yb.asgn_type  
      AND tp.pyd_pretax = 'Y'  
      AND tp.pyd_status <> 'HLD'  
    AND pyh_number = 0), 0)  
FROM #YTDBAL yb  
  
UPDATE #YTDBAL  
SET ytddeduct = ytddeduct + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))   
    FROM #temp_pd tp  
    WHERE tp.asgn_id = yb.asgn_id  
       AND tp.asgn_type = yb.asgn_type  
       AND tp.pyd_pretax = 'N'  
       AND tp.pyd_MINus = -1  
       AND tp.pyd_status <> 'HLD'  
        AND pyh_number = 0), 0)  
FROM #YTDBAL yb  
  
UPDATE #YTDBAL  
SET ytdreimbrs = ytdreimbrs + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))  
    FROM #temp_pd tp  
    WHERE tp.asgn_id = yb.asgn_id  
       AND tp.asgn_type = yb.asgn_type  
       AND tp.pyd_pretax = 'N'  
       AND tp.pyd_MINus = 1  
       AND tp.pyd_status <> 'HLD'  
        AND pyh_number = 0), 0)  
FROM #YTDBAL yb  
  
UPDATE #temp_pd  
SET pyh_totalcomp = yb.ytdcomp,  
 pyh_totaldeduct = yb.ytddeduct,  
 pyh_totalreimbrs = yb.ytdreimbrs  
FROM #YTDBAL yb  
WHERE #temp_pd.asgn_type = yb.asgn_type  
   AND #temp_pd.asgn_id = yb.asgn_id  
  
UPDATE #temp_pd  
SET itemsection = 2  
WHERE pyd_pretax = 'N'  
   AND pyd_MINus = 1  
  
UPDATE #temp_pd  
SET itemsection = 3  
WHERE pyd_pretax = 'N'  
   AND pyd_MINus = -1  
  
UPDATE #temp_pd  
SET itemsection = 4  
WHERE pyt_itemcode = 'MN+' /*MINimum credit */  
   OR pyt_itemcode = 'MN-' /*MINimum debit */  
  
--Update the temp pay details with labelfile data AND drv alt id  
UPDATE #temp_pd  
SET  #temp_pd.userlabelname = l.userlabelname,  
 #temp_pd.label_name = l.name,  
 #temp_pd.otherid = m.mpp_otherid  
FROM  labelfile l
	join manpowerprofile m  on  m.mpp_type1 = l.abbr  and  l.labeldefinition = 'DrvType1'  
WHERE  m.mpp_id = #temp_pd.asgn_id

  
--Update the temp pay details with start/end city/state data - LOR PTS# 4457  
UPDATE #temp_pd  
SET  start_city = ct.cty_name,  
 start_state = ct.cty_state  
FROM   city ct  
WHERE  ct.cty_code = #temp_pd.lgh_startcity  
  
UPDATE #temp_pd  
SET  end_city = ct.cty_name,  
 end_state = ct.cty_state  
FROM    city ct  
WHERE  ct.cty_code = #temp_pd.lgh_endcity  
  
SELECT tar_tarriffnumber,pyd_glnum,
pyd_number,   
 pyh_number,   
 asgn_number,   
 asgn_type,   
 asgn_id,   
 ivd_number,   
 pyd_prorap,  
 pyd_payto,  
 pyt_itemcode,  
 pyt_fee1,  
 pyt_fee2,  
 pyd_description,  
 pyr_ratecode,   
 pyd_quantity,  
 pyd_rateunit,   
 pyd_unit,   
 pyd_pretax,   
 pyd_status,   
 pyh_payperiod,   
 lgh_startcity,  
 lgh_endcity,   
 pyd_MINus,  
 pyd_workperiod,  
 pyd_sequence,  
 pyd_rate,  
 ROUND(pyd_amount, 2) AS pyd_amount,  
 pyd_payrevenue,  
 mov_number,  
 lgh_number,  
 ord_hdrnumber,  
 pyd_transdate,  
 payperiodstart,  
 payperiodend,  
 pyd_loadstate,  
 summary_code,  
 [name],  
 terMINal,  
 type1,  
 ROUND(pyh_totalcomp, 2) AS pyh_totalcomp,  
 ROUND(pyh_totaldeduct, 2) AS pyh_totaldeduct,  
 ROUND(pyh_totalreimbrs, 2) AS pyh_totalreimbrs,  
 crd_cardnumber,  
 lgh_startdate,  
 std_balance,  
 itemsection,  
 ord_startdate,  
 ord_number,  
 ref_number,  
 stp_arrivaldate,  
 shipper_name,  
 shipper_city,  
 shipper_state,  
 consignee_name,  
 consignee_city,  
 consignee_state,  
 cmd_name,  
 pyd_billedweight,  
 adjusted_billed_rate,  
 cht_basis,  
 cht_basisunit,  
 pyt_description,  
 userlabelname,  
 label_name,  
 otherid,  
 trc_drv,  
 start_city,  
 start_state,  
 end_city,  
 end_state,  
 lgh_count,  
 CASE WHEN Type1 = 'DD' AND asgn_type = 'DRV' THEN 'Y' ELSE 'N' END AS deposit,  
 ref_bol = ISNULL((SELECT top 1 ref_number FROM referencenumber WHERE referencenumber.ord_hdrnumber = ord_hdrnumber),'')  
  
FROM #temp_pd  
ORDER BY itemsection,ord_startdate, ord_number, pyd_sequence



GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_SETTLEMENT_ByLegHeaderNumber] TO [public]
GO
