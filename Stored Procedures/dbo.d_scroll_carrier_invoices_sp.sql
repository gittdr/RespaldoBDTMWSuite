SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_scroll_carrier_invoices_sp] (	
		@ps_carrier			varchar(13),
		@ps_carinv			varchar(30)
)
AS
--	sample call
--
--	d_scroll_carrier_invoices_sp 'HJBT', 99999

/**
 * 
 * NAME:
 * dbo.d_scroll_carrier_invoices_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure retrieves the pay details that have a carrier invoice number on them
 *
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @ps_carrier			varchar(10)		Carrier ID
 * 002 - @ps_carinv				varchar(6)		Invoice number
 *
 * 
 * REVISION HISTORY:
 * 09/08/2006 ? PTS 60172 - vjh ? Original Release
 * 09/04/2013 - PTS 71952 - SGB - Remove debug line at bottom update paydetail set ord_hdrnumber = null where pyd_number = 16423
 **/

select pyd_number,
	pyd_carinvnum,
	pyd_carinvdate,
	pyd_number,
	pyh_number,
	lgh_number,
	ord_number,
	p.ord_hdrnumber,
	p.mov_number,
	pyd_amount,
	pyh_payperiod,
	pyd_transdate,
	car_id,
	car_name
from paydetail p
left outer join orderheader o on p.ord_hdrnumber = o.ord_hdrnumber
left join carrier c on p.asgn_id = c.car_id
where asgn_type = 'CAR'
and (@ps_carrier = 'UNKNOWN' or asgn_id = @ps_carrier)
and (@ps_carinv = '' or pyd_carinvnum = @ps_carinv)

GO
GRANT EXECUTE ON  [dbo].[d_scroll_carrier_invoices_sp] TO [public]
GO
