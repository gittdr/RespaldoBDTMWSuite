SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[reset_permitrequirements_sp] (@p_mov_number int)
AS

/**
 * 
 * NAME:
 * dbo.reset_permitrequirements_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This proc is the SQL 2000 version of the reset_permitrequirements_sp that builds all the 
 * default permits for all legs on a given movement
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * 001 - @p_mov_number, int, input
 *       This parameter indicates the move number to generate permit requirements for
 *
 * 
 * REVISION HISTORY:
 * 03/06/2006 ? PTS31766 - Jason Bauwin ? original
 *
 **/


declare @state_counter varchar(2)
declare @lgh_counter int, @prc_counter int
declare @max_weight float, @max_length float, @max_width float, @max_height float

declare @inactive table(PM_id      int NULL, 
                        lgh_number int NULL, 
                        asgn_type  varchar(6) NULL, 
                        PR_default char(1) NULL)

declare @permit_requirements_temp table (prd_id int NULL,
                                         pm_id int NULL,
                                         mov_number int NULL,
                                         lgh_number int NULL,
                                         asgn_type varchar (6) NULL,
                                         PR_Default char (1) NULL,
                                         PR_Escort_Required char (1) NULL,
                                         PR_Escort_Type varchar (6) NULL,
                                         PR_Escort_Qty smallint NULL,
                                         PRD_RequiredFrom datetime NULL,
                                         PRD_RequiredTo datetime NULL,
                                         prc_sequence smallint NULL,
                                         pr_comment varchar(50) NULL)
declare @cmd_classes table (cmd_code varchar(8) NULL,
                            cmd_class varchar (8) NULL)

--get the first leg for the movement
select @lgh_counter = min(lgh_number)
  from stops 
 where mov_number = @p_mov_number
   and lgh_number > 0

while @lgh_counter is not null
  begin
   --get the max weight, length, width, height for the leg
   exec permit_calculate_max_weight_sp @lgh_counter, @max_weight OUTPUT
--select @max_weight
   exec permit_calculate_max_length_sp @lgh_counter, @max_length OUTPUT
--select @max_length
   exec permit_calculate_max_width_sp @lgh_counter, @max_width OUTPUT
--select @max_width
   exec permit_calculate_max_height_sp @lgh_counter, @max_height OUTPUT
--select @max_height

--populate all the commodity classes on the leg
  insert into @cmd_classes (cmd_code, cmd_class)
  select commodity.cmd_code, commodity.cmd_class
    from commodity
    join freightdetail on freightdetail.cmd_code = commodity.cmd_code
    join stops on stops.stp_number = freightdetail.stp_number
    join legheader on legheader.lgh_number = stops.lgh_number
   where legheader.lgh_number = @lgh_counter
     and commodity.cmd_class <> 'UNKNOWN'

--select * from @cmd_classes
	-- keep a list of all default permits which are tagged as disabled for this leg
   insert into @inactive (PM_id, lgh_number, asgn_type, PR_default)
	select 	PM_id, 
				lgh_number, 
				asgn_type,
				PR_default
	  from permit_requirements
	 where lgh_number = @lgh_counter
	   AND PR_Default = 'X'

   --remove all the system defaulted permits for the leg
	delete permit_requirements
    where lgh_number = @lgh_counter
      and PR_Default in ('Y','X')

   --create all the system default state permit requirements for the leg
	insert into @permit_requirements_temp (prd_id,
                                          pm_id,
                                          mov_number,
                                          lgh_number,
                                          asgn_type,
                                          PR_Default,
                                          PR_Escort_Required,
                                          PR_Escort_Type,
                                          PR_Escort_Qty,
                                          PRD_RequiredFrom,
                                          PRD_RequiredTo,
                                          prc_sequence,
                                          pr_comment)
	select permit_requirements_default.prd_id,
          permit_requirements_default.pm_id, 
          @p_mov_number, 
          @lgh_counter, 
          permit_requirements_default.asgn_type, 
          'Y', 
          permit_req_default_criteria.PRC_escort_required,
          permit_req_default_criteria.PRC_escort_type,
          permit_req_default_criteria.PRC_escort_qty,
          permit_requirements_default.PRD_RequiredFrom,
          permit_requirements_default.PRD_RequiredTo,
          permit_req_default_criteria.prc_sequence,
          permit_req_default_criteria.prc_comment
	  from permit_requirements_default
     left outer join permit_req_default_criteria on permit_requirements_default.prd_id = permit_req_default_criteria.prd_id
	  join permit_master on permit_master.pm_id = permit_requirements_default.pm_id
	  join permit_issuing_authority on permit_master.pia_id = permit_issuing_authority.pia_id
	 where st_abbr in (select distinct isnull(statemiles.sm_state,'zz')
								from stops
								join mileagetable on stops.stp_lgh_mileage_mtid  = mileagetable.mt_identity
								join statemiles on mileagetable.mt_identity = statemiles.mt_identity
							   where stops.mov_number = @p_mov_number
							     and stops.lgh_number = @lgh_counter
							     and stops.stp_loadstatus = 'LD')
     and permit_issuing_authority.pia_type = 'STATE'
     and getdate() BETWEEN isnull(permit_requirements_default.prd_requiredfrom, '01/01/50 00:00:00.000') and isnull(permit_requirements_default.prd_requiredto, '12/31/49 23:59:59.999')
     and (  ((isnull(permit_req_default_criteria.prc_min_length,0) <= isnull(@max_length, 0) and isnull(permit_req_default_criteria.prc_min_length,0) > 0) or (isnull(permit_req_default_criteria.prc_min_length,0) = 0))
         AND ((isnull(permit_req_default_criteria.prc_min_width,0) <= isnull(@max_width, 0) and isnull(permit_req_default_criteria.prc_min_width,0) > 0) or (isnull(permit_req_default_criteria.prc_min_width,0) = 0))
         AND ((isnull(permit_req_default_criteria.prc_min_height,0) <= isnull(@max_height, 0) and isnull(permit_req_default_criteria.prc_min_height,0) > 0) or (isnull(permit_req_default_criteria.prc_min_height,0) = 0))
         AND ((isnull(permit_req_default_criteria.prc_min_weight,0) <= isnull(@max_weight, 0) and isnull(permit_req_default_criteria.prc_min_weight,0) > 0) or (isnull(permit_req_default_criteria.prc_min_weight,0) = 0))
         AND ((isnull(permit_req_default_criteria.cmd_class, 'UNKNOWN') in (select distinct cmd_class
                                                                              from @cmd_classes)) or (isnull(permit_req_default_criteria.cmd_class, 'UNKNOWN')='UNKNOWN')))

--select * from @permit_requirements_temp

   --create all the system default city permits for the leg
	insert into @permit_requirements_temp (prd_id,
                                          pm_id,
                                          mov_number,
                                          lgh_number,
                                          asgn_type,
                                          PR_Default,
                                          PR_Escort_Required,
                                          PR_Escort_Type,
                                          PR_Escort_Qty,
                                          PRD_RequiredFrom,
                                          PRD_RequiredTo,
                                          prc_sequence,
                                          pr_comment)
	select permit_requirements_default.prd_id,
          permit_requirements_default.pm_id, 
          @p_mov_number, 
          @lgh_counter, 
          permit_requirements_default.asgn_type, 
          'Y', 
          permit_req_default_criteria.PRC_escort_required,
          permit_req_default_criteria.PRC_escort_type,
          permit_req_default_criteria.PRC_escort_qty,
          permit_requirements_default.PRD_RequiredFrom,
          permit_requirements_default.PRD_RequiredTo,
          permit_req_default_criteria.prc_sequence,
          permit_req_default_criteria.prc_comment
	  from permit_requirements_default
     left outer join permit_req_default_criteria on permit_requirements_default.prd_id = permit_req_default_criteria.prd_id
	  join permit_master on permit_master.pm_id = permit_requirements_default.pm_id
	  join permit_issuing_authority on permit_master.pia_id = permit_issuing_authority.pia_id
	 where cty_code in (select distinct isnull(stp_city,0)
								from stops
							  where stops.mov_number = @p_mov_number
							    and stops.lgh_number = @lgh_counter
							    and stops.stp_type in ('PUP', 'DRP'))
     and permit_issuing_authority.pia_type = 'CITY'
     and getdate() BETWEEN isnull(permit_requirements_default.prd_requiredfrom, '01/01/50 00:00:00.000') and isnull(permit_requirements_default.prd_requiredto, '12/31/49 23:59:59.999')
     and (  ((isnull(permit_req_default_criteria.prc_min_length,0) <= isnull(@max_length, 0) and isnull(permit_req_default_criteria.prc_min_length,0) > 0) or (isnull(permit_req_default_criteria.prc_min_length,0) = 0))
         AND ((isnull(permit_req_default_criteria.prc_min_width,0) <= isnull(@max_width, 0) and isnull(permit_req_default_criteria.prc_min_width,0) > 0) or (isnull(permit_req_default_criteria.prc_min_width,0) = 0))
         AND ((isnull(permit_req_default_criteria.prc_min_height,0) <= isnull(@max_height, 0) and isnull(permit_req_default_criteria.prc_min_height,0) > 0) or (isnull(permit_req_default_criteria.prc_min_height,0) = 0))
         AND ((isnull(permit_req_default_criteria.prc_min_weight,0) <= isnull(@max_weight, 0) and isnull(permit_req_default_criteria.prc_min_weight,0) > 0) or (isnull(permit_req_default_criteria.prc_min_weight,0) = 0))
         AND ((isnull(permit_req_default_criteria.cmd_class, 'UNKNOWN') in (select distinct cmd_class
                                                                              from @cmd_classes)) or (isnull(permit_req_default_criteria.cmd_class, 'UNKNOWN')='UNKNOWN')))

	--delete all but the highest sequence for each requirement default
	select @prc_counter = min(prd_id) from @permit_requirements_temp
	while @prc_counter is not null
	  begin
	    delete @permit_requirements_temp 
	     where prd_id = @prc_counter 
	       and prc_sequence <> (select max(prc_sequence)
	                              from @permit_requirements_temp
	                             where prd_id = @prc_counter)
	    select @prc_counter = min(prd_id) from @permit_requirements_temp where prd_id > @prc_counter
	  end

   --now copy the temp table to the permit_requirements table
   insert into permit_requirements( pm_id,   
                                    mov_number,
                                    lgh_number,
                                    asgn_type,
                                    PR_Default,
                                    PR_Escort_Required,
                                    PR_Escort_Type,
                                    PR_Escort_Qty,
                                    pr_comment )
	select pm_id, 
          mov_number, 
          lgh_number, 
          asgn_type,
          'Y',
          PR_Escort_Required,
          PR_Escort_Type,
          PR_Escort_Qty,
          pr_comment
     from @permit_requirements_temp
    where lgh_number = @lgh_counter
      and mov_number = @p_mov_number

   --disable those requirements that were previously disabled
	update permit_requirements
      set PR_default = 'X'
     from @inactive inactive
    where inactive.PM_id = permit_requirements.pm_id
      and inactive.asgn_type = permit_requirements.asgn_type
      and inactive.lgh_number = permit_requirements.lgh_number

	--go to the next leg for the move
	select @lgh_counter = min(lgh_number)
	  from stops 
	 where mov_number = @p_mov_number
      and lgh_number > @lgh_counter
  end


GO
GRANT EXECUTE ON  [dbo].[reset_permitrequirements_sp] TO [public]
GO
