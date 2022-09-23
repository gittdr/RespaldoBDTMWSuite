SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PENNTANK_V001_SP] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the revenue is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the calculated revenue rate
	@pl_tarnum int, -- the tariff number on the rate being used
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc revenue is zero the app will not create a zero paydetail.
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calcrevenue money out, -- return the calculated revenue here. Populate this with -1 if the calculation fails
	@ps_loadstate varchar(3) OUT, -- Return the Load Status
	@pdc_rate decimal OUT -- Return the Rate
	
					)
as 
/**
 *
 * COMMENTS:
	'PENNTANK'	BYoung 
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

/*
* BEGIN PENNTANK
*/
-- BYoung - PTS 30358
Begin
	/* PENN */
	declare @rate float
	declare @qty int
	declare @ivd int
	declare @totrev money
	select 	@totrev = 0
	select 	@ivd = 0
	
	declare @tarused int
	declare @ivh_rate float
	declare @trc_row int
	declare @trc_col int
	declare @row_basis varchar(6)
	declare @rate_to_use float
	declare @row_match varchar(25)
	declare @penn_fs_amt money
	declare @chtrateunit varchar(6)

/* 
BYoung 02-22-06 New logic for paying % of Rev Fuel Surcharge,
need to get chargetype code that's linked on the paytype, so that we can
get the rate billed later
*/
	declare @spec_fs_pay varchar(6)
	select  @spec_fs_pay = cht_itemcode
	  from  paytype
	 where	pyt_itemcode = @ps_paytype

	if @ps_paytype = 'BRKRPY' or @ps_paytype = 'FSSPEC'
	BEGIN

/* 
GET RATE FROM EACH DETAIL
THEN LOOKUP THE BRKRPAY RATE FROM THE SAME TARIFF USED TO BILL THE ORDER
*/
	if (select count(*) from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber ) > 0 
		BEGIN
			while 1=1
				begin
					select 	@ivd = min(ivd_number)
					  from 	invoicedetail INNER JOIN chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
					 where	ord_hdrnumber = @pl_ord_hdrnumber
							and chargetype.cht_primary = 'Y'
							and ivd_number > @ivd
--							and ivd_charge > 0 /* SLM 40014 comment out 
							AND tar_number > 0
				
					if @ivd is NULL BREAK
--	select @ivd
					select  @tarused = (select max(tar_number) from invoicedetail where ivd_number = @ivd)
					select 	@ivh_rate = ( select max(ivd_rate) from invoicedetail where ivd_number = @ivd)
					select	@row_basis = (select tar_rowbasis from tariffheader where tar_number = @tarused)
		
		--begin - there is more than 1 row with the same rate
					if (select count(*) from tariffrate where tar_number = @tarused and tra_rate = @ivh_rate) > 1
						and
						(select tar_colbasis from tariffheader where tar_number = @tarused) <> 'NOT'
					BEGIN
						if @row_basis = 'DCM'
							BEGIN
								select 	@row_match = max(ivh_consignee) from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber
		
								select  @trc_row = trc_number
								  from 	tariffrowcolumn
								 where 	tar_number = @tarused 
										and trc_matchvalue = @row_match
										and trc_rowcolumn = 'R'			
								
								select 	@rate = tra_rate
								  from	tariffrate
								 where	tar_number = @tarused
										and trc_number_row = @trc_row
										and trc_number_col = 	(
														select	trc_number
													  	from 	tariffrowcolumn
													 	where	tar_number = @tarused
																and trc_matchvalue = 'BRKRPAY'
																and trc_rowcolumn = 'C'	
																)	
							END
						if @row_basis = 'DCT'
							BEGIN
								select 	@row_match = max(ivh_destcity) from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber
		
								select  @trc_row = trc_number
								  from 	tariffrowcolumn
								 where 	tar_number = @tarused 
										and trc_matchvalue = @row_match
										and trc_rowcolumn = 'R'			
								
								select 	@rate = tra_rate
								  from	tariffrate
								 where	tar_number = @tarused
										and trc_number_row = @trc_row
										and trc_number_col = 	(
														select	trc_number
													  	from 	tariffrowcolumn
													 	where	tar_number = @tarused
																and trc_matchvalue = 'BRKRPAY'
																and trc_rowcolumn = 'C'	
																)		
							END

						/* PTS 35951 - Added logic to pull rate from a table with a row basis
														of Destination County */
						if @row_basis = 'DCNTY'
							BEGIN
								select 	@row_match = max(ivh_destcity) from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber
								select @row_match = cty_state + '/' + county_name from city where cty_code = @row_match

								select  @trc_row = trc_number
								  from 	tariffrowcolumn
								 where 	tar_number = @tarused 
										and trc_matchvalue = @row_match
										and trc_rowcolumn = 'R'			
								
								select 	@rate = tra_rate
								  from	tariffrate
								 where	tar_number = @tarused
										and trc_number_row = @trc_row
										and trc_number_col = 	(
														select	trc_number
													  	from 	tariffrowcolumn
													 	where	tar_number = @tarused
																and trc_matchvalue = 'BRKRPAY'
																and trc_rowcolumn = 'C'	
																)		
							END
					END
		--end - there is more than 1 row with the same rate
		--begin - there is only 1 row with the same rate
					if (select count(*) from tariffrate where tar_number = @tarused and tra_rate = @ivh_rate) = 1
					BEGIN
						select	@rate = tra_rate
						  from 	tariffrate
						 where	tar_number = @tarused
								and trc_number_row = 	(
									  	select 	trc_number_row
										  from 	tariffrate 
									   	 where 	tra_rate = @ivh_rate															 	
												and tar_number = @tarused
										)
								and trc_number_col = 	(
										select	trc_number
										  from 	tariffrowcolumn
										 where	tar_number = @tarused
												and trc_matchvalue = 'BRKRPAY'
												and trc_rowcolumn = 'C'
										)
					END
					if (select count(*) from tariffrate where tar_number = @tarused and tra_rate = @ivh_rate) > 1
						and
						(select tar_colbasis from tariffheader where tar_number = @tarused) = 'NOT'
					BEGIN
						select	@rate = tra_rate
						  from 	tariffrate
						 where	tar_number = @tarused
								and trc_number_row = 	(
									  	select 	trc_number_row
										  from 	tariffrate 
									   	 where 	tra_rate = @ivh_rate	
												and tar_number = @tarused
										)
								and trc_number_col = 	(
										select	trc_number
										  from 	tariffrowcolumn
										 where	tar_number = @tarused
												and trc_matchvalue = 'BRKRPAY'
												and trc_rowcolumn = 'C'
										)
					END

					select	@qty = ivd_quantity, @chtrateunit = ivd_rateunit
					  from	invoicedetail
					 where	ivd_number = @ivd
/* 
ACCORDING TO THE CLIENT, IF THE PROCESS DOESN'T FIND A SPECIAL PAY RATE
THEN USE THE SAME RATE THAT WAS BILLED
*/
					if isNull(@rate,0) = 0 
					BEGIN
						select @rate = @ivh_rate
					END	
					
					if isNull(@rate,0) = 0 OR isNull(@qty,0) = 0
						select @ps_returnmsg = 'Either the RATE or QTY on the invoice for this order is not available, please check the invoice'	
					else	

						/* PTS 35951 - use @rate * (@qty * .01) for invoice detail with
													and rate unit of $/100 lbs*/
						if @chtrateunit = 'CWT' 
							begin
								select 	@pdec_calcrevenue = @rate * (@qty * .01)
							end
						else
							begin
								select  @pdec_calcrevenue = @rate * @qty	
							end
			
			  			select	@totrev = @totrev + IsNull(@pdec_calcrevenue,0)
			
						--select 	@pdec_calcrevenue, @rate, @qty, @ivd
			
						select 	@pdec_calcrevenue = 0
								, @rate = 0
								, @qty = 0
			
				end
					if @ps_paytype = 'FSSPEC'
							begin
								--select @pl_disallowzeropaydetail=1
								select @spec_fs_pay = cht_itemcode
								  from paytype
								 where	pyt_itemcode = @ps_paytype
								
								select @penn_fs_amt = isnull(@totrev,0) * (select isNull(ivd_rate,0) from invoicedetail where ord_hdrnumber = @pl_ord_hdrnumber and cht_itemcode = @spec_fs_pay)
								if isNull(@penn_fs_amt,0) = 0
									begin
										select @pdec_calcrevenue = 0
										select @pl_disallowzeropaydetail=1
									end
								else
									begin
										select @pdec_calcrevenue = @penn_fs_amt
									end
	
							end
						else
							select @pdec_calcrevenue = @totrev
		END

	END
End


/*
* END PENNTANK
*/
GO
GRANT EXECUTE ON  [dbo].[PENNTANK_V001_SP] TO [public]
GO
