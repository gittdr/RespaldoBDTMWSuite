SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_revenue_dist_sp] (@mov_number int) AS
/**
 * 
 * NAME:
 * dbo.d_revenue_dist_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -    
 * Calls002 -   
 *
 * CalledBy001 - 
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

SET NOCOUNT ON

DECLARE @tot_charges money,
	@err_message varchar(30)

-- Create a temporary work table to calculate total revenue
CREATE TABLE #revenuetotal
 (ivh_hdrnumber int null,
  det_charges money null,
  ivh_currency varchar(6) null,
  ivh_arcurrency varchar(6) null,
  ivh_currencydate datetime null,
  cex_rate money null,
  max_date datetime null,
  ar_charges money null)

-- Load the temporary revenue work table with the invoices for the move
INSERT #revenuetotal
 SELECT ivh_hdrnumber,
  0,
  ivh_currency,
  ivh_arcurrency,
  ivh_currencydate,
  1,
  null,
  0
 FROM invoiceheader
 WHERE mov_number = @mov_number

-- Update the temporary revenue work table
-- with total invoice charges minus tax based charges from invoice details
UPDATE #revenuetotal
 SET det_charges = (SELECT SUM(ISNULL(ivd.ivd_charge, 0))
                     FROM invoicedetail ivd, chargetype cht
                     WHERE ivd.ivh_hdrnumber = rt.ivh_hdrnumber
                     AND ivd.cht_itemcode = cht.cht_itemcode
                     AND cht.cht_basis != 'TAX')
 FROM invoicedetail ivd, #revenuetotal rt
 WHERE ivd.ivh_hdrnumber = rt.ivh_hdrnumber

-- Update the temporary revenue work table
-- with the maximum related date from the currency exhange table
UPDATE #revenuetotal
 SET max_date = (SELECT MAX(cex.cex_date)
                 FROM currency_exchange cex
                 WHERE cex.cex_date <= rt.ivh_currencydate
                 AND cex.cex_from_curr = rt.ivh_currency
                 AND cex.cex_to_curr = rt.ivh_arcurrency)
 FROM currency_exchange ce, #revenuetotal rt
 WHERE ce.cex_date <= rt.ivh_currencydate
 AND ce.cex_from_curr = rt.ivh_currency
 AND ce.cex_to_curr = rt.ivh_arcurrency

-- Update the temporary revenue work table
-- with the exchange rate from the currency exhange table
UPDATE #revenuetotal
 SET cex_rate = cex.cex_rate 
  FROM currency_exchange cex, #revenuetotal rt
  WHERE cex.cex_date = rt.max_date
  AND cex.cex_from_curr = rt.ivh_currency
  AND cex.cex_to_curr = rt.ivh_arcurrency

-- Check for invalid currency conversion
-- Calculate the charges in native currency (arcurrency)
IF (SELECT COUNT (*) FROM #revenuetotal WHERE cex_rate is null) > 0
	BEGIN

	SELECT @err_message = 'Currency conversion error'

	UPDATE #revenuetotal
	SET ar_charges = 0
	END
ELSE
	UPDATE #revenuetotal
	SET ar_charges = ROUND(det_charges * cex_rate, 2)

-- Calculate the total revenue in native currency
SELECT @tot_charges = ROUND(SUM(ar_charges), 2)
FROM #revenuetotal

-- Create a temporary work file to use as the return set 
CREATE TABLE #revenue_dist
	(lgh_number int not null,
	earnings float null,
	lgh_tractor varchar(8) null,
	trc_type1 varchar(6) null,
	lgh_alloc_revenue float null,
	allocated_revenue float null,
	lgh_allocfactor float null,
	pyd_status varchar(6) null,
	prod_hr float null,
	tot_hr float null,
	ld_unld_time float null,
	ld_load_time float null,
	pay_status varchar(6) null)

-- Load the work table with the legheaders 
INSERT #revenue_dist
SELECT DISTINCT lgh.lgh_number,
	null,
	lgh.lgh_tractor,
	lgh.trc_type1,
	lgh.lgh_alloc_revenue,
	null,
	lgh.lgh_allocfactor,
	asgn.pyd_status,
	lgh.lgh_prod_hr,
	lgh.lgh_tot_hr,
	lgh.lgh_ld_unld_time,
	lgh.lgh_load_time,
	'UNK'
FROM legheader lgh
		left outer join assetassignment asgn ON lgh.lgh_number = asgn.lgh_number
WHERE lgh.mov_number = @mov_number
AND pyd_status = 'PPD'  	-- due to outer join, 				
				-- pyd_status will be null if no asgns yet 	
				-- processed in settlements 			
				-- this will be tested for in window to see if 	
				-- all legheaders have been processed
  
-- Update the work table with the branch id's 
UPDATE #revenue_dist
SET trc_type1 = tp.trc_terminal
FROM tractorprofile tp
WHERE lgh_tractor = tp.trc_number

-- Update the work table with the settlements by leg header 
UPDATE 	#revenue_dist
SET 	earnings = ROUND((SELECT SUM(pd.pyd_amount)
                           FROM paydetail pd
                           WHERE pd.lgh_number = #revenue_dist.lgh_number
		           AND pd.pyd_pretax = 'Y'), 2),
	pay_status = (SELECT ISNULL(MIN(pyd.pyd_status), 'UNK')
			FROM paydetail pyd
			WHERE lgh_tractor = pyd.asgn_id
			AND   #revenue_dist.lgh_number = pyd.lgh_number
			AND pyd.asgn_type = 'TRC')
FROM paydetail pd
WHERE pd.lgh_number = #revenue_dist.lgh_number

-- If no earnings, set to 0
UPDATE #revenue_dist
SET earnings = IsNull(earnings, 0)

-- Select the return set 
SELECT @tot_charges,
	lgh_number,
	earnings,
	lgh_tractor,
	trc_type1,
	allocated_revenue,
	lgh_alloc_revenue,
	lgh_allocfactor,
	pyd_status,
	prod_hr,
	tot_hr,
	ld_unld_time,
	ld_load_time,
	pay_status,
	@err_message
FROM #revenue_dist

GO
GRANT EXECUTE ON  [dbo].[d_revenue_dist_sp] TO [public]
GO
