SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[create_holddefinition_sp] (@customer varchar(20), @hld_type varchar(6), @startdate datetime, @enddate datetime, @exception varchar(30) = null, @auth as varchar(30) = null, 
	@cbcode as varchar(30) = null,@comment as varchar(1000) = null,@ruleid integer = null out, @errmsg varchar(500) = null out)
AS

/*
*	Created: PTS 64228 - DJM - Proc to create a Hold Definition record. Designed to support Import from Excel.
*/

-- Check the dates.
if @startdate > @enddate
	Begin
		select @errmsg = 'Cannot begin the Hold before Ending the Hold. Please correct Start/End dates'
		Select @ruleid = 0
	end
	
-- Verify that a Type is entered
if isnull(@hld_type,'null') = 'null' or @hld_type = '' 
	Begin
		select @errmsg = 'Hold definition requires a Hold Definition Type'
		Select @ruleid = 0
	end

-- Verify that a valid Type is entered
if  not exists(SELECT 1 FROM [labelfile] where labeldefinition = 'HoldCategory' and abbr = @hld_type)
	Begin
		select @errmsg = 'Hold definition must be a valid Hold Category Type'
		Select @ruleid = 0
	end

if @errmsg > ''
begin
	Select 0 as 'HoldID', @errmsg as 'HoldError'
	Return
end
else
begin try
		select @errmsg = 'Success'

		Insert into OrderHoldDefinition (
			hld_customer
			,hld_type
			,hld_startdate
			,hld_enddate
			,hld_exception
			,hld_authorization
			,hld_cbcode
			,hld_effective_comment)
		Values(
			@customer
			,@hld_type
			,@startdate
			,@enddate
			,@exception
			,@auth
			,@cbcode
			,@comment)
end try
Begin catch
	select @errmsg = ERROR_MESSAGE()
	Select 0 as 'HoldID', @errmsg as 'HoldError'
	Return
end Catch

Select @ruleid = SCOPE_IDENTITY()
Select @ruleid as 'HoldID', @errmsg as 'HoldError'

GO
GRANT EXECUTE ON  [dbo].[create_holddefinition_sp] TO [public]
GO
