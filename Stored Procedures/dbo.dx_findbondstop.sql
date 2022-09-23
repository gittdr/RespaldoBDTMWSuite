SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
declare @cmp_id varchar(8)
exec dx_findbondstop 204910, 'CAMDEN,NJ', @cmp_id output
select @cmp_id 
COLUMBUS,OH
CAMDEN,NJ
*/
CREATE  PROCEDURE [dbo].[dx_findbondstop] (
@mov_number int,
@bondlocation varchar(50),
@bondCompanyID varchar(8) output
)

AS

	set @bondlocation = @bondlocation + '%'
	set @bondCompanyID = ''
	select top 1 @bondCompanyID = stops.cmp_id from stops 
						left join company on stops.cmp_id = company.cmp_id
						where stops.mov_Number = @mov_number and IsNull(cmp_isbond, '') = 'Y' and cty_nmstct like @bondlocation 
						order by stops.stp_mfh_sequence desc
GO
GRANT EXECUTE ON  [dbo].[dx_findbondstop] TO [public]
GO
