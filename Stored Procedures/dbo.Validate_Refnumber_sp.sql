SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[Validate_Refnumber_sp]
	@ref_table		varchar(18),
	@ref_tablekey	integer,
	@ref_type		varchar(6),
	@ref_value		varchar(50),
	@valid			varchar(1) output
	
	
as

-- set the default value
Select @valid = '1'

Declare @test1 as varchar(50)
declare @checkmod as integer
declare @checkint as integer
declare @mod as integer

/*
/***************** production *******************************/    

Created PTS 51883 - DJM - provide a proc to allow customers to validate Reference Number values.

Requirements: This proc accepts the the Table for the Referenceunmber, the Referencenumnber Type, value and the 
	Key for the referencenumber.  The value returned should be either '1' or '0'. '1' indicates that the ReferenceNumber value
	PASSES whatever validation code the customer Adds. The Zero (0) indicates the value FAILS the test.
	The default return value is '1'.
	
NOTE: Please take extreme care to minimize the performance footprint of this proc.  This proc is called during the Save routine
	in visual dispatch.
	
*/

/*
NOTE: The following code is supplied as an example ONLY. Customer will need to add code to perform the
	actual check.
	
	
if @ref_table = 'orderheader'
	begin
		-- NOTE: Customer will need to supply the required Reference Number code here
		if @ref_type = 'PRO'
			begin
				if 1 <> 1 
					select @valid = 0
					
			end
		
	end
	
*/


Return @valid

GO
GRANT EXECUTE ON  [dbo].[Validate_Refnumber_sp] TO [public]
GO
