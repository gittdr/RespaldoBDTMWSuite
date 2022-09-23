SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[ERLMRTN_V001_SP] (
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
	'ERLMRTN'	ADAM HILLEBRAND (modified version of CONTI) 10/31/07.  Shampra Marshall PTS 40226 11/19/2007
**/


select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'


--Begin ERLMRTN

----40375 JJF 20071203 - repair
--declare @W_rate money
Begin
----40375 JJF 20071203 - repair
	declare @W_rate money
	
	If (select trl_type1 from trailerprofile, invoiceheader
		where trl_number = ivh_trailer
		and ord_hdrnumber = @pl_ord_hdrnumber
		and ivh_definition in ('LH','RBIL')) = 'DUMP'

		BEGIN

			If (select ivh_totalweight from invoiceheader
			where ord_hdrnumber = @pl_ord_hdrnumber) > '52000'
 
			BEGIN

			
			--JWK temp change to test in my db
			--select @V_rate = ivd_rate from invoicedetail where ivd_type = 'SUB' and cht_itemcode = 'LHTON'
			
			-- PTS 40356 SLM 11/28/2007 Comment out the following line that used ivd_charge instead of ivd_rate
			--select @W_rate = ivd_charge from invoicedetail where cht_itemcode = 'LHTON'
			select @W_rate = ivd_rate from invoicedetail where ivd_type = 'SUB'and cht_itemcode = 'LHTON'
			and ivh_hdrnumber = (
			 select Max(ivh_hdrnumber)
			from invoiceheader 
			where   ivd_charge > 0
			and ivh_definition in ('LH','RBIL')
			and ord_hdrnumber = @pl_ord_hdrnumber
			)
	
			Select @W_rate = IsNull(@W_rate,0)
			  --if @pl_isprimary = 1
			  --BEGIN
			select @pdec_calcrevenue = 26 * @W_rate
			  --END

			END
	END


ELSE
	
	If (select trl_type1 from trailerprofile, invoiceheader
		where trl_number = ivh_trailer
		and ord_hdrnumber = @pl_ord_hdrnumber
		and ivh_definition in ('LH','RBIL')) = 'HPR'
		BEGIN
			If (select ivh_totalweight from invoiceheader			
            where ord_hdrnumber = @pl_ord_hdrnumber) > '54000'
          -- SLM PTS 40356 11/28/2007 changed the where clause to 54K from 52K			
          --where ord_hdrnumber = @pl_ord_hdrnumber) > '52000'
			BEGIN

			--declare @W_rate money
			select @W_rate = ivd_rate from invoicedetail where ivd_type = 'SUB' and cht_itemcode = 'LHTON'
			and ivh_hdrnumber = (
			 select Max(ivh_hdrnumber)
			from invoiceheader 
			where   ivd_charge > 0
			and ivh_definition in ('LH','RBIL')
			and ord_hdrnumber = @pl_ord_hdrnumber
			)
	
			Select @W_rate = IsNull(@W_rate,0)
			  --if @pl_isprimary = 1
			  --BEGIN
			select @pdec_calcrevenue = 27 * @W_rate
			  --END
			END
		END

END
--End ERLMRTN



GO
GRANT EXECUTE ON  [dbo].[ERLMRTN_V001_SP] TO [public]
GO
