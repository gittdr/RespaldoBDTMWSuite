SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[CARTRANS_V001_SP] (
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
	'CARTRANS'	CAR Transport, coded by Shampra Marshall PTS 37129 06/11/2007
**/


select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'


-- BEGIN CAR Transport

     Begin
          Select @pdec_calcrevenue = SUM(stp_count) 
          From stops 
          Where lgh_number   = @pl_lgh_number and 
                stp_event in ('LLD', 'XDL') 
     End
-- END CAR Transport


GO
GRANT EXECUTE ON  [dbo].[CARTRANS_V001_SP] TO [public]
GO
