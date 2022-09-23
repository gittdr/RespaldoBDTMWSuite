SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[EVANS_V001_SP] (
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
	'EVANS'		REED DALLMAN ported by JD 02/01/06 31568 modified Ron Kost Tom Cz PTS 34511
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

/*
* EVANS 
* 33599 Jude
*/

declare @evans_mov_number int
declare @evans_mov_miles float
declare @evans_lgh_miles float
declare @pctmilesleg float
declare @evans_ord_rev money


BEGIN
    select @pl_isprimary = 0
    select @pdec_calcrevenue = 0
	if @pl_ord_hdrnumber > 0 
    BEGIN
	    select @evans_ord_rev = IsNull(sum(ivh_charge),0) from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber
	    select @evans_mov_number = mov_number from legheader where lgh_number = @pl_lgh_number               
	    select @evans_mov_miles = sum(stp_lgh_mileage) from stops where mov_number = @evans_mov_number
	    select @evans_lgh_miles = sum(stp_lgh_mileage) from stops where lgh_number = @pl_lgh_number                        
	    SET @pctmilesleg = 0
	    IF (@evans_mov_miles > 0)
	    BEGIN
            SET @pctmilesleg = round(@evans_lgh_miles / @evans_mov_miles, 4)
	    END 
	    SET @pdec_calcrevenue = @evans_ord_rev * @pctmilesleg
    END

END

/* 
* END EVANS
*/


GO
GRANT EXECUTE ON  [dbo].[EVANS_V001_SP] TO [public]
GO
