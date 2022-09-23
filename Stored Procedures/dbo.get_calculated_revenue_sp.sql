SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_calculated_revenue_sp] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the revenue is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the calculated revenue rate
	@pl_tarnum int, -- the tariff number on the rate being used
		@pdc_lh_pay money,	-- linehaul pay
		@ps_custom1	varchar(100),
		@ps_custom2 varchar(100),
		@ps_custom3 varchar(100),
		@ps_custom4 varchar(100),
		@ps_custom5 varchar(100),
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc revenue is zero the app will not create a zero paydetail.
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calcrevenue money out, -- return the calculated revenue here. Populate this with -1 if the calculation fails
	@ps_loadstate varchar(3) OUT, -- Return the Load Status
	@pdc_rate money OUT, -- Return the Rate --vjh 49449 use money, not decimal with it's implied {18,0}
		@ps_custom_description varchar(75) OUT,	--	customizable description
		@ps_custom2_out varchar(100) OUT,
		@ps_custom3_out varchar(100) OUT,
		@ps_custom4_out varchar(100) OUT,
		@ps_custom5_out varchar(100) OUT				
					)
as 

/**
 * 
 * NAME:
 * dbo.get_calculated_revenue_sp
 *
 * 
 * REVISION HISTORY:
 * 05/02/2008.01 PTS41625 - SLM  - get_calculated_revenue_sp was modified to become a Stub proc.
 *								   All previous client specific sections have been created as separate stored procedures and will be called by this proc.
 *								   TRANSF_V001_SP, RELIA_V001_SP, 'CONTI_V001_SP', ETC. Except for 5STAR, it is FIVESTAR_V001_SP
 * LOR	6/21/12 - added @pdc_lh_pay, @ps_custom_description and custom 1-5 fields	                                                                 
 *
 **/

DECLARE @proc_name varchar(60), @parms_number int

select @proc_name = IsNull(gi_string1,'') from generalinfo where gi_name ='CalculatedRevenueMethod' 
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

If Len(isnull(@proc_name,''))> 0
Begin
	select @parms_number = max(ordinal_position) from  INFORMATION_SCHEMA.PARAMETERS where specific_name = @proc_name

	If @parms_number = 12 
		EXECUTE @proc_name
		   @pl_ord_hdrnumber
		  ,@pl_lgh_number
		  ,@pl_isprimary
		  ,@ps_asgn_type
		  ,@ps_asgn_id
		  ,@ps_paytype
		  ,@pl_tarnum
		  ,@pl_disallowzeropaydetail OUTPUT
		  ,@ps_returnmsg OUTPUT
		  ,@pdec_calcrevenue OUTPUT
		  ,@ps_loadstate OUTPUT
		  ,@pdc_rate  OUTPUT

	If @parms_number > 12 
		EXECUTE @proc_name
		   @pl_ord_hdrnumber
		  ,@pl_lgh_number
		  ,@pl_isprimary
		  ,@ps_asgn_type
		  ,@ps_asgn_id
		  ,@ps_paytype
		  ,@pl_tarnum
		  ,@pdc_lh_pay
		  ,@ps_custom1
		  ,@ps_custom2
		  ,@ps_custom3
		  ,@ps_custom4
		  ,@ps_custom5
		  ,@pl_disallowzeropaydetail OUTPUT
		  ,@ps_returnmsg OUTPUT
		  ,@pdec_calcrevenue OUTPUT
		  ,@ps_loadstate OUTPUT
		  ,@pdc_rate  OUTPUT	  	  
	  	  ,@ps_custom_description OUTPUT
		  ,@ps_custom2_out OUT
		  ,@ps_custom3_out OUT
		  ,@ps_custom4_out OUT
		  ,@ps_custom5_out OUT
End
GO
GRANT EXECUTE ON  [dbo].[get_calculated_revenue_sp] TO [public]
GO
