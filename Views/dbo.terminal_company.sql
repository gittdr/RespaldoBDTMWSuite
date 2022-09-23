SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[terminal_company]
AS
SELECT     tz.cmp_id AS terminal, c.cmp_id, c.cmp_name, c.cmp_address1, c.cmp_address2, cty.cty_name, c.cmp_zip, c.cmp_state, c.cmp_updateddate, cl.route_id, cl.unit_pos, 
                      cl.carrier, cl.stop_sun, cl.stop_mon, cl.stop_tue, cl.stop_wed, cl.stop_thr, cl.stop_fri, cl.stop_sat, cl.last_stop_date, c.cmp_RateBy, cl.service_level,
       c.cmp_ctw_conv, c.cmp_ctw_break,c.cmp_wtc_conv,c.cmp_ctw_weightunits,c.cmp_ctw_volumeunits, cl.billing_auditor, cl.sales_rep, c.cmp_revtype1, 
       c.cmp_revtype2, c.cmp_revtype3, c.cmp_revtype4, cl.default_master_order,
       tz.advance_carrier, tz.beyond_carrier, tz.bill_to, tz.requestor, cl.ord_auto_prepare
FROM         dbo.company AS c LEFT OUTER JOIN
                      dbo.company_ltl_info AS cl ON cl.cmp_id = c.cmp_id INNER JOIN
                      dbo.terminalzipcode AS tz ON c.cmp_zip BETWEEN tz.zipcode_low AND tz.zipcode_high INNER JOIN
                      dbo.city AS cty ON c.cmp_city = cty.cty_code
       AND EXISTS (SELECT 1 FROM RowRestrictValidAssignments_company_fn() rsva WHERE c.rowsec_rsrv_id = rsva.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
GO
GRANT DELETE ON  [dbo].[terminal_company] TO [public]
GO
GRANT INSERT ON  [dbo].[terminal_company] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminal_company] TO [public]
GO
GRANT SELECT ON  [dbo].[terminal_company] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminal_company] TO [public]
GO
