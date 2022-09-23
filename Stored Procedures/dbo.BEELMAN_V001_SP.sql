SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[BEELMAN_V001_SP] (
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
	'BEELMAN'	BYoung 
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

/*
* BEGIN BEELMAN
*/
BEGIN

declare @bman_class4 varchar(8)
declare @bman_trc_terminal varchar(8)
declare @bman_trl_type3 varchar(8)
declare @unit	varchar(6)
declare @conv float
--11/17/07 BYoung: 40375
declare @lh_rate money

--PTS 33584 bYoung code for multi-invoice, use 'first' for the order, the A Invoice
declare @ivhhdr int
select  @ivhhdr =  ivh_hdrnumber
	from	invoiceheader
	 where	ord_hdrnumber= @pl_ord_hdrnumber 
			and ivh_invoicenumber like '%A'

--35994 JJF 1/29/07
if @ivhhdr IS NULL 
        select TOP 1 @ivhhdr =  ivh_hdrnumber 
        from    invoiceheader 
         where  ord_hdrnumber= @pl_ord_hdrnumber 
        order by ivh_hdrnumber 

--11/17/07 BYoung: 40375
select 	@lh_rate = isNull(ivd_rate,0)
  from	invoicedetail 
 where	ivh_hdrnumber = @ivhhdr and upper(ivd_type) = 'SUB'


declare @gross float
declare @tare float

select	@bman_class4 = left(isNull(lgh_class4,'UNK'),2)
		, @bman_trc_terminal = left(isNull(trc_terminal,'UNK'),2)
		, @bman_trl_type3 = left(isNull(trl_type3,'UNK'),2)
  from	legheader 
 where	lgh_number = @pl_lgh_number

select	@gross = isNull(ord_grossweight,0)
		, @tare = isNull(ord_tareweight,0)
  from	orderheader
 where	ord_hdrnumber = @pl_ord_hdrnumber

 if @ps_paytype = 'PERCRE'
  BEGIN
	 if @bman_class4 = 'CZ'
		BEGIN
			 select	@unit = ISNULL(ivh_ratingunit, 'TON')
			 from	invoiceheader
			 where	ivh_hdrnumber = @ivhhdr
	
			 select @conv = unc_factor
			 from	unitconversion
			 where	unc_from = 'LBS' and
					unc_to = @unit and
					unc_convflag = 'Q'

			if 	(@bman_trc_terminal != 'CZ' AND @bman_trl_type3 != 'CZ') --neither;max net weight is 60000 lbs. '
				BEGIN
					if (@gross - @tare) > 60000
						begin
--							select	@pdec_calcrevenue = max(ivh_rate) * (60000 * ISNULL(@conv, .0005))
--							from 	invoiceheader
--							where 	ivh_hdrnumber = @ivhhdr --ord_hdrnumber = @pl_ord_hdrnumber

							--11/17/07 BYoung: 40375
							select	@pdec_calcrevenue = @lh_rate * (60000 * ISNULL(@conv, .0005))
						end
					ELSE
						begin
							select	@pdec_calcrevenue = ivh_charge
							from 	invoiceheader
							where 	ivh_hdrnumber = @ivhhdr --ord_hdrnumber = @pl_ord_hdrnumber
						END
				END
			if 	(@bman_trc_terminal = 'CZ' OR  @bman_trl_type3 = 'CZ') --either;max net weight is 70000 lbs. '
				BEGIN
					if (@gross - @tare) > 70000
						begin
--							select	@pdec_calcrevenue = max(ivh_rate) * (70000 * ISNULL(@conv, .0005))
--							from 	invoiceheader
--							where 	ivh_hdrnumber = @ivhhdr -- ord_hdrnumber = @pl_ord_hdrnumber

							--11/17/07 BYoung: 40375
							select	@pdec_calcrevenue = @lh_rate * (70000 * ISNULL(@conv, .0005))
						end
					ELSE
						begin
							select	@pdec_calcrevenue = ivh_charge
							from 	invoiceheader
							where 	ivh_hdrnumber = @ivhhdr -- ord_hdrnumber = @pl_ord_hdrnumber
						END
				END
			if 	(@bman_trc_terminal = 'CZ' AND @bman_trl_type3 = 'CZ') --both;max net weight is 90000 lbs. '
				BEGIN
					if (@gross - @tare) > 90000
						begin
--							select	@pdec_calcrevenue = max(ivh_rate) * (90000 * ISNULL(@conv, .0005))
--							from 	invoiceheader
--							where 	ivh_hdrnumber = @ivhhdr --ord_hdrnumber = @pl_ord_hdrnumber

							--11/17/07 BYoung: 40375
							select	@pdec_calcrevenue = @lh_rate * (90000 * ISNULL(@conv, .0005))
						end
					ELSE
						begin
							select	@pdec_calcrevenue = ivh_charge
							from 	invoiceheader
							where 	ivh_hdrnumber = @ivhhdr --ord_hdrnumber = @pl_ord_hdrnumber
						END
				END
		END
	ELSE
		BEGIN
		 select	@unit = ISNULL(ivh_ratingunit, 'TON')
		 from	invoiceheader
		 where	ivh_hdrnumber = @ivhhdr
								 
		 select @conv = unc_factor
		 from	unitconversion
		 where	unc_from = 'LBS' and
				unc_to = @unit and
				unc_convflag = 'Q'
				
		 if @gross > 81000 and @unit not in ('FLT', 'HRS')
		   	BEGIN
--				select	@pdec_calcrevenue = max(ivh_rate) * ((81000-@tare) * ISNULL(@conv, .0005))
--				from 	invoiceheader
--				where 	ivh_hdrnumber = @ivhhdr

				--11/17/07 BYoung: 40375
				select	@pdec_calcrevenue = @lh_rate * ((81000-@tare) * ISNULL(@conv, .0005))
			END
		  ELSE
			BEGIN
				select	@pdec_calcrevenue = ivh_charge
				from 	invoiceheader
				where 	ivh_hdrnumber = @ivhhdr
			END
		END
  END
  --11/17/07 BYoung: 40375
  select  @pdec_calcrevenue = round(@pdec_calcrevenue,2)

End 
/* end bman */



GO
GRANT EXECUTE ON  [dbo].[BEELMAN_V001_SP] TO [public]
GO
