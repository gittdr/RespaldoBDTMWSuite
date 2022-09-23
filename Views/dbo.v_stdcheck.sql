SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[v_stdcheck]
AS
SELECT sd.asgn_type asgn_type,
       sd.asgn_id 'asgn_id',
       sd.sdm_itemcode 'itemcode', 
       std_description 'description', 
       std_issuedate 'issued', 
       CASE std_status 
            WHEN 'INI' THEN'Initial'
            WHEN 'CLD' THEN 'Closed'
            WHEN 'DRN' THEN 'Drawn'
            ELSE std_status
       END 'status', 
       CONVERT(varchar(10), std_closedate, 1) 'closed', 
       IsNull(SUM(pyd_amount), 0) 'total_settled',
       IsNull(CONVERT(money, std_endbalance),0) endbalance,
       IsNull(CONVERT(money, std_startbalance - std_endbalance), 0) 'Amount',
       sdm_minusbalance sdm_minusbalance,
       pyt_minus pyt_minus,
       IsNull(CONVERT(money, std_balance), 0) 'balance', 
       CONVERT(money, std_deductionrate) 'deduct', 
       CONVERT(money, std_reductionrate) 'reduce'
  FROM standingdeduction sd
       left outer join paydetail pd on (sd.std_number = pd.std_number AND sd.asgn_id = pd.asgn_id AND sd.asgn_type = pd.asgn_type) 
       join stdmaster on sd.sdm_itemcode = stdmaster.sdm_itemcode
       join paytype on stdmaster.pyt_itemcode = paytype.pyt_itemcode
GROUP BY sd.asgn_type, sd.asgn_id, sd.sdm_itemcode, std_description, std_issuedate, std_status,
         std_closedate, std_endbalance,sdm_minusbalance,pyt_minus,std_balance, std_startbalance, std_deductionrate, std_reductionrate

GO
GRANT SELECT ON  [dbo].[v_stdcheck] TO [public]
GO
