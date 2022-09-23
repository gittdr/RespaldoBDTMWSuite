SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_EDIUnmatchedCompanyType] (
 @p_dxident bigint,
 @p_BilltoChecked varchar(1) = '' OUTPUT,
 @p_ShipperChecked varchar(1) = '' OUTPUT,
 @p_ConsigneeChecked varchar(1) = '' OUTPUT
)
AS
 DECLARE @v_sourcedate datetime, @v_ordhdr bigint, @CompanyType varchar(2), @cmpAltId varchar(30),
		 @CompanyName varchar(35), @Address1 varchar(35), @City varchar(20), @STATE varchar(2)

 select @p_BilltoChecked = 'N',
		@p_ShipperChecked = 'N',
		@p_ConsigneeChecked = 'N'

 select @Companytype = dx_field003, @v_sourcedate = dx_sourcedate, @v_ordhdr = dx_orderhdrnumber,
		@CompanyName = dx_field004, @Address1 = dx_field005, @City = dx_field007,
		@STATE = dx_field008, @cmpAltId = dx_field013
	from dx_archive where dx_ident = @p_dxident
 

if exists (select 1 FROM dx_archive 
	where @v_sourcedate = dx_sourcedate and @v_ordhdr = dx_orderhdrnumber
	and dx_field001 = '06'
	and dx_field003 = 'BT' 
	and ((isnull(@cmpAltId,'') > '' and dx_field013 = @cmpAltId)
	or  (@CompanyName = dx_field004 and @Address1 = dx_field005 and @City = dx_field007
		and @STATE = dx_field008)))
		select @p_BilltoChecked = 'Y'

if exists (select 1 FROM dx_archive 
	where @v_sourcedate = dx_sourcedate and @v_ordhdr = dx_orderhdrnumber
	and dx_field001 = '06'
	and dx_field003 = 'ST' 
	and ((isnull(@cmpAltId,'') > '' and dx_field013 = @cmpAltId)
	or  (@CompanyName = dx_field004 and @Address1 = dx_field005 and @City = dx_field007
		and @STATE = dx_field008)))
		BEGIN
		select @p_ShipperChecked = 'Y'
		select @p_ConsigneeChecked = 'Y'
		END

		
if @p_ShipperChecked = 'N' and @p_BilltoChecked = 'N' 
	if exists(select 1 FROM dx_archive 
	where @v_sourcedate = dx_sourcedate and @v_ordhdr = dx_orderhdrnumber
	and dx_field001 = '06'
	and dx_field003 = 'SH' 
	and ((isnull(@cmpAltId,'') > '' and dx_field013 = @cmpAltId)
	or  (@CompanyName = dx_field004 and @Address1 = dx_field005 and @City = dx_field007
		and @STATE = dx_field008)))
		select @p_ShipperChecked = 'Y'

if @p_ConsigneeChecked = 'N' 
	if exists(select 1 FROM dx_archive 
	where @v_sourcedate = dx_sourcedate and @v_ordhdr = dx_orderhdrnumber
	and dx_field001 = '06'
	and dx_field003 = 'CO' 
	and ((isnull(@cmpAltId,'') > '' and dx_field013 = @cmpAltId)
	or  (@CompanyName = dx_field004 and @Address1 = dx_field005 and @City = dx_field007
		and @STATE = dx_field008)))
		select @p_ConsigneeChecked = 'Y'

GO
GRANT EXECUTE ON  [dbo].[dx_EDIUnmatchedCompanyType] TO [public]
GO
