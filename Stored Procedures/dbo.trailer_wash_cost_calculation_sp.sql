SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[trailer_wash_cost_calculation_sp]
AS
BEGIN
	DECLARE @daysback smallint

	CREATE TABLE #cost
		(cmp_id varchar(8), 
		cmd_code varchar(8),
		psh_number integer,
		cost money)

	SELECT @daysback = CASE WHEN gi_integer1 > 0 THEN gi_integer1 * -1
			WHEN gi_integer1 = 0 THEN -9999
			ELSE gi_integer1 END
	FROM generalinfo
	WHERE gi_name = 'TrailerWashCostDaysBack'

	INSERT INTO #cost
	SELECT psh.psh_vendor_id, oh.cmd_code, psh.psh_number, SUM((psd_qty * psd_rate))
	FROM purchaseserviceheader psh
		JOIN company c on psh.psh_vendor_id = c.cmp_id and cmp_service_location = 'Y'
		JOIN purchaseservicedetail psd on psh.psh_number = psd.psh_number
		JOIN orderheader oh on psh.ord_hdrnumber = oh.ord_hdrnumber --and ord_completiondate > dateadd(day, @daysback, getdate())
		JOIN generalinfo g on g.gi_name = 'TrailerWashCostExcludes'
		JOIN commodity cmd on cmd.cmd_code = oh.cmd_code
	WHERE psh_drop_dt > DATEADD(DAY, @daysback, GETDATE())
		AND CHARINDEX(',' + psd.psd_type + ',', ',' + g.gi_string1 + ',') = 0
	GROUP BY psh.psh_vendor_id, oh.cmd_code, psh.psh_number
	
	TRUNCATE TABLE trailer_wash_costs
	
	INSERT trailer_wash_costs (cmp_id, cmd_code, twc_wash_count, twc_total_wash_cost)
	SELECT cmp_id, cmd_code, COUNT(*), SUM(cost)
	FROM #cost
	GROUP BY cmp_id, cmd_code
	
	DROP TABLE #cost
END
GO
GRANT EXECUTE ON  [dbo].[trailer_wash_cost_calculation_sp] TO [public]
GO
