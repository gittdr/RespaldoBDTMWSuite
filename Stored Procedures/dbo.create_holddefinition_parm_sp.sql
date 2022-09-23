SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[create_holddefinition_parm_sp] (@hldid integer, @parmtype as varchar(6), @parmvalue as varchar(100), @errmsg varchar(500) = null out)
AS

/*
*	Created: PTS 64228 - DJM - Proc to create a Hold Definition parameter record. Designed to support Import from Excel.
*/

select @errmsg = ''

-- Check the dates.
if @hldid is null or @hldid = 0 
	Begin
		select @errmsg = 'Hold Definition Id is missing'
	end
	
if not exists (select 1 from OrderHoldDefinition where hld_id = @hldid)
	Begin
		select @errmsg = 'The Hold ID: ' + cast(@hldid as varchar(10)) + ' is not a valid Hold Definition ID'
	end

	
-- Verify that a Type is entered
if  @parmtype is null or @parmtype = '' 
	Begin
		select @errmsg = 'Hold Parameter requires a valid Parameter Type'
	end

-- Verify that a valid Type is entered

--if  CHARINDEX(','+@parmtype +',',',V,D,O,M,MO,YR,') < 1 
if  CHARINDEX(','+@parmtype +',',',D,MAKE,MODEL,O,VIN,YEAR,') < 1 
	Begin
		--select @errmsg = 'Hold Parameter Type must be one of the Following values: V,D,O,M,MO,YR '
		select @errmsg = 'Hold Parameter Type must be one of the Following values: D,MAKE,MODEL,O,VIN,YEAR '
	end

-- Verify that a Value is entered
if  @parmvalue is null or @parmvalue = '' 
	Begin
		select @errmsg = 'Hold Parameter requires a valid Parameter Value'
	end

if @errmsg > ''
begin
	select @errmsg as 'HoldDefParmError'
	Return
end
else
begin try
		select @errmsg = 'Success' 

		Insert into OrderHoldparms (
			hld_id
			,hparm_type
			,hparm_value)
		Values(
			@hldid
			,@parmtype
			,@parmvalue)
			
			-- Use create_orderholdfromrule_sp. Pass @hldid
			if (@parmtype = 'VIN')
			begin
				--select [ord_number] into #new_holds from [orderheader] where ord_reftype = 'VIN' and ord_status in ('AVL', 'ASN') and ord_refnum = @parmvalue
				--if exists(select [ord_number] from #new_holds)
				--begin
					--update [orderheader] set ord_status = LEFT(ord_status,2) + 'H'
					--where [ord_number] in ( select [ord_number] from #new_holds )
				--end
				exec create_orderholdfromrule_sp @hldid, @errmsg output
			end
end try
Begin catch
	select @errmsg = ERROR_MESSAGE()

	select @errmsg as 'HoldDefParmError'
	Return
end Catch

select @errmsg as 'HoldDefParmError'

GO
GRANT EXECUTE ON  [dbo].[create_holddefinition_parm_sp] TO [public]
GO
