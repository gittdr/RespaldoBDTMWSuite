SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[MCCLY_V001_SP] (
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
	'MCCLY'		Coded by BYOUNG
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'


/*
* BEGIN MCCLY
*/

Begin
 if @pl_isprimary = 1 
 begin

		declare @r money --tar rate
		declare @or float --bill rate
		declare @cmd varchar(8) --cmd
		declare @ship varchar(12) --cmd
		declare @tar int --tar #
		declare @adj float
		
		--declare @trans_cost money
		
		/* Get the SELL rate.. the rate charged to the customer */
		select 	@or = max(ivd_rate)
		from 	invoicedetail 
		where 	ivd_unit IN ('TON', 'LHTON','CUYD','FLAT','FLT') and ord_hdrnumber = @pl_ord_hdrnumber


		--db
		--select @or
			
		/* 
		Get tar number to get the board price.
		This will also need to include a WHERE clause
		for a Vendor Material File rate.. like trk_revtype4 = 'VMF'
		*/
		select 	@tar = tar_number 
		  from 	tariffkey
		 where 	trk_originpoint = (select ivh_shipper from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber)
				and trk_revtype4 = 'VMF'


		--db
		--select @tar
		
		/* 
		Get the cmd, and shipper from the order to look up on the
		tariff (@tar)
		*/

	select @ship = ivh_shipper
	  from invoiceheader
	 where	ord_hdrnumber = @pl_ord_hdrnumber
	
	select @cmd = min(cmd_code)
	  from	freightdetail
	 where	stp_number in (select stp_number from stops where ord_hdrnumber = @pl_ord_hdrnumber and stp_type = 'drp')


		select  @r = tra_rate 
		from 	tariffrate
		where 	tar_number = @tar
				and trc_number_row = (	select 	trc_number 
						from 	tariffrowcolumn 
						where 	trc_rowcolumn = 'r' 
							and trc_matchvalue = @cmd and tar_number = @tar)
				and trc_number_col = (	select trc_number
						from tariffrowcolumn where trc_rowcolumn = 'c' 
						and trc_matchvalue = @ship  and tar_number = @tar)
		
		
		SELECT @pdec_calcrevenue = max(ivd_quantity) * (@or - @r) --+ dbo.mcc_getadjfactor_fct(@ord, @tar))
		from 	invoicedetail
		where 	ord_hdrnumber = @pl_ord_hdrnumber
				and ivd_unit IN ('TON', 'LHTON','CUYD','FLAT','FLT')
				AND ivd_charge > 0 
		
		
  	
 end 
 
End 
/*
* END MCCLY
*/
GO
GRANT EXECUTE ON  [dbo].[MCCLY_V001_SP] TO [public]
GO
