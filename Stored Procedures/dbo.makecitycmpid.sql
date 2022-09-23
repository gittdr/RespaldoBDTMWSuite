SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[makecitycmpid] (@stp_number int)
as
/**
 * 
 * NAME:
 * dbo.makecitycmpid
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


/*this should only be called if the following is true
	select stp_number
	from stops
	where ord_hdrnumber >0 and
		substring(cmp_id,1,1)='_' */

declare @cmp_id varchar(8),
	@stp_city int,
	@cty_nmstct varchar(25)

select @cmp_id = cmp_id,
	@stp_city = stp_city,
	@cty_nmstct = city.cty_nmstct
from stops, city
where stp_number = @stp_number and	
	stp_city = cty_code and
	ord_hdrnumber >0 and
	(substring(cmp_id,1,1)='_' or cmp_id='UNKNOWN')
if @stp_city > 0 
begin
	if isnull(@cmp_id,'UNKNOWN')<> '_'+convert(varchar(7),@stp_city)
	begin
		if (select count(*)
			from company
			where cmp_id = '_'+convert(varchar(7),@stp_city)) < 1
		begin
			INSERT INTO company ( cmp_id, cmp_name, cmp_shipper, cmp_consingee, cmp_billto, cmp_city, cmp_updatedby, cmp_updateddate, cmp_othertype1, cmp_othertype2, cmp_revtype1, cmp_revtype2, cmp_revtype3, cmp_revtype4, cmp_currency, cmp_creditlimit, cmp_creditavail, cmp_mastercompany, cmp_defaultbillto, cmp_region1, cmp_region2, cmp_region3, cmp_region4, cty_nmstct, cmp_invcopies, cmp_acc_balance, cmp_artype, cmp_invoicetype, cmp_edi214, cmp_edi210, cmp_edi204, cmp_payfrom, cmp_mbdays, cmp_max_dunnage, cmp_agedinvflag, cmp_createdate, cmp_quickentry, cmp_active, cmp_taxtable1, cmp_taxtable2, cmp_taxtable3, cmp_taxtable4, cmp_transfertype ) 
			VALUES ( '_'+convert(varchar(7),@stp_city), @cty_nmstct, 'N', 'N', 'N', @stp_city, 'AUTOCITY', getdate(),'UNK', 'UNK', 'UNK', 'UNK', 'UNK', 'UNK', 'US', 0, 0, 'UNKNOWN', 'UNKNOWN', 'UNK', 'UNK', 'UNK', 'UNK', @cty_nmstct, 1, 0.0000, 'CSH', 'INV', 0, 0, 0, 'UNKNOWN', 0, 0, 'N', getdate(), 'Y', 'Y', 'Y', 'Y', 'N', 'N', 'INV' )
		end
		
		update stops
		set cmp_id =  '_'+convert(varchar(7),@stp_city)
		where stp_number = @stp_number
	end
end

GO
GRANT EXECUTE ON  [dbo].[makecitycmpid] TO [public]
GO
