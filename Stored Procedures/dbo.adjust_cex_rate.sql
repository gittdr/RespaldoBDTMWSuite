SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create procedure [dbo].[adjust_cex_rate]
		(@vs_currency	varchar(6)
		,@vdec_base		money)
as
/*
Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	-----------------------------------------
	08/12/2003	Vern Jewett		19494	(none)	Original.
*/

--The base value they have chosen must already exist (exact value) in the table for
--the given bill-to currency..
if not exists
		(select	1
		  from	currency_surcharge_rate
		  where	csr_billto_currency = @vs_currency
			and	csr_to_billto_cex_rate = @vdec_base)
begin
	print 'The passed-in CURRENCY and BASE value must match an existing entry in ' + 
			'table currency_surcharge_rate.  Canceling.'
	return
end


--Only the entry which has a multiplier of 0.00 (no currency surcharge will be levied
--in this case) may be used as the base..
if	(select	csr_surcharge_multiplier
	  from	currency_surcharge_rate
	  where	csr_billto_currency = @vs_currency
		and	csr_to_billto_cex_rate = @vdec_base) <> 0.00
begin
	print 'The designated BASE exchange rate must be the one which already has a ' +
			'multiplier of 0.000000.  Canceling.'
	return
end


--Update the entries..
update	currency_surcharge_rate
  set	csr_to_billto_cex_rate = csr_to_billto_cex_rate - @vdec_base
  where	csr_billto_currency = @vs_currency
GO
GRANT EXECUTE ON  [dbo].[adjust_cex_rate] TO [public]
GO
