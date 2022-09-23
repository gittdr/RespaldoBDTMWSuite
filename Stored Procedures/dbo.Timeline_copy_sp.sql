SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Timeline_copy_sp]
	@tlh_number int,
	@tlh_effective datetime,
	@tlh_expires datetime

AS

/**
 * 
 * NAME:
 * dbo.Timeline_copy_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Copy timelines
 *
 * RETURNS: 
 *	-1
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @tlh_number int  			timeline to copy.
 * 002 - @tlh_effective datetime		Effective date of the new timeline
 * 003 - @tlh_expires datetime			Expiration date of teh new timeline
 * 
 * REVISION HISTORY:
 * 06/13/2006.01 - MRH ? Created
**/

Declare @NewTlh_number int

-- Copy the header
INSERT INTO [Timeline_header]([tlh_name], [tlh_effective], [tlh_expires], [tlh_supplier], [tlh_plant], [tlh_dock], [tlh_jittime], [tlh_leaddays], [tlh_leadbasis], [tlh_sequence], [tlh_direction], [tlh_sunday], [tlh_saturday], [tlh_branch], [tlh_timezone], [tlh_SubrouteDomicle], [tlh_DOW], [tlh_specialist], [tlh_updatedby], [tlh_updatedon]) 
	select [tlh_name], @tlh_effective, @tlh_expires, [tlh_supplier], [tlh_plant], [tlh_dock], [tlh_jittime], [tlh_leaddays], [tlh_leadbasis], [tlh_sequence], [tlh_direction], [tlh_sunday], [tlh_saturday], [tlh_branch], [tlh_timezone], [tlh_SubrouteDomicle], [tlh_DOW], [tlh_specialist], 'TimelineCopy', [tlh_updatedon] from Timeline_header where tlh_number = @tlh_number
select @NewTlh_number = max(tlh_number) from Timeline_header where [tlh_updatedby] = 'TimelineCopy'
-- Copy the details
INSERT INTO [Timeline_detail]([tlh_number], [tld_sequence], [tld_master_ordnum], [tld_route], [tld_origin], [tld_arrive_orig], [tld_arrive_orig_lead], [tld_depart_orig], [tld_depart_orig_lead], [tld_dest], [tld_arrive_yard], [tld_arrive_lead], [tld_arrive_dest], [tld_arrive_dest_lead])
	select @NewTlh_number, [tld_sequence], NULL, [tld_route], [tld_origin], [tld_arrive_orig], [tld_arrive_orig_lead], [tld_depart_orig], [tld_depart_orig_lead], [tld_dest], [tld_arrive_yard], [tld_arrive_lead], [tld_arrive_dest], [tld_arrive_dest_lead] from timeline_detail where tlh_number = @tlh_number

GO
GRANT EXECUTE ON  [dbo].[Timeline_copy_sp] TO [public]
GO
