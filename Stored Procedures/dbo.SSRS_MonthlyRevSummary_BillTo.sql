SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[SSRS_MonthlyRevSummary_BillTo]
 (@billto varchar(8))


AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

--		exec SSRS_MonthlyRevSummary_BillTo 'FAUSTE'

DECLARE @cur_year int, @prev_year INT
DECLARE @s_date DATETIME, @e_date DATETIME

SET @cur_year = DATEPART(yyyy, getdate())
--SET @cur_year = 2007
SET @prev_year = (@cur_year - 1)

DECLARE @trip_data	TABLE
(  ord_hdrnumber	INT
  ,ord_billto		VARCHAR (10)
  ,revenue			MONEY
  ,pay				MONEY
  ,start_month		INT
  ,start_monthname	VARCHAR(20)
  ,start_year		INT)

 
SELECT @s_date = CONVERT(DATETIME, CONVERT(VARCHAR(4), @prev_year) + '-01-01')
SELECT @e_date = CONVERT(DATETIME, CONVERT(VARCHAR(4), @cur_year) + '-12-31 23:59:59.999')
 
INSERT INTO @trip_data
SELECT
  o.ord_hdrnumber
 ,o.ord_billto
 ,CASE  WHEN o.ord_invoicestatus = 'PPD' 
			THEN ISNULL((SELECT SUM(ivh.ivh_totalcharge) from invoiceheader ivh where ivh.ord_hdrnumber = o.ord_hdrnumber),0)
		ELSE o.ord_totalcharge
  END AS [revenue]
 ,ISNULL((SELECT SUM(pyd.pyd_amount) FROM paydetail pyd WHERE pyd.ord_hdrnumber = o.ord_hdrnumber and pyd_minus = 1),0) as [pay]
 ,DATEPART(mm, o.ord_startdate)
 ,DATENAME(mm, o.ord_startdate) 
 ,DATEPART(yy, o.ord_startdate)
FROM orderheader o
 INNER JOIN company cmp ON o.ord_billto = cmp.cmp_id
WHERE o.ord_startdate BETWEEN @s_date AND @e_date
AND o.ord_billto = @billto 
AND o.ord_status IN ('CMP','DSP','MPN','PND','PLN','STD')


SELECT
	 t.start_year
	,t.start_month
	,t.start_monthname 
	,SUM(t.revenue) as [Rev]
	,SUM(t.pay) as [Pay]
	,CASE WHEN SUM(t.revenue) > 0
			THEN CONVERT(DEC(9,4), (SUM(t.pay) / SUM(t.revenue)))
		  ELSE 0
	 END AS [Margin]
FROM @trip_data t 
GROUP BY 	 
	 t.start_year
	,t.start_month
	,t.start_monthname 


GO
GRANT EXECUTE ON  [dbo].[SSRS_MonthlyRevSummary_BillTo] TO [public]
GO
