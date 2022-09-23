SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[CSA_create_expirations_sp] (
		@Query_ID  varchar(40), @mpp_id varchar(8) = 'UNKNOWN'
        )
AS

/**
 * 
 * NAME:
 * dbo.CSA_create_expirations_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to create expirations for the CSA process
 * Rollup method might be configurable in the future.  Probably based on the rollup column for the overall
 * but for now, just use this method
 * each rank is multiplied by the rollup factor for that category
 * a total is accumulated and divided by the sum of the rollup factors (if not 0)
 *
 * RETURNS:
 * NA
 * 
 * RESULT SETS: 
 * NA
 *
 * PARAMETERS:
 * See prototype above
 *
 * REVISION HISTORY:
 * 08/22/2011 PTS58291 - vjh - new proc to create expirations for the CSA process
 * 09/10/2013          - vjh - correct logic for percentage accumulation
 * 06/26/2014 PTS79673 0 vjh - SQL2005 compliancy issue with math operator +=
 */
 
		
--  Sample call 
--first will process all entries, second just the single row for the selected driver
--					CSA_create_expirations_sp 409386955838194
--					CSA_create_expirations_sp 409386955838194, 'casad'


declare @dt datetime
declare @thisid varchar(8)
declare	@percentaccum	int,
		@factoraccum	int
declare	@overalscore	int
declare	@CSAOverall_enabled			char(1),
		@CSACargo_enabled			char(1),
		@CSACSA_enabled				char(1),
		@CSAFatigue_enabled			char(1),
		@CSAFitness_enabled			char(1),
		@CSAUnsafe_enabled			char(1),
		@CSAVehicle_enabled			char(1)
declare	@CSAOverall_expcode			varchar(12),
		@CSACargo_expcode			varchar(12),
		@CSACSA_expcode				varchar(12),
		@CSAFatigue_expcode			varchar(12),
		@CSAFitness_expcode			varchar(12),
		@CSAUnsafe_expcode			varchar(12),
		@CSAVehicle_expcode			varchar(12)
declare	@CSAOverall_threshhold1		int,
		@CSAOverall_threshhold2		int,
		@CSACargo_threshhold		int,
		@CSACSA_threshhold			int,
		@CSAFatigue_threshhold		int,
		@CSAFitness_threshhold		int,
		@CSAUnsafe_threshhold		int,
		@CSAVehicle_threshhold		int
declare	@CSACargo_priority			int,
		@CSACSA_priority			int,
		@CSAFatigue_priority		int,
		@CSAFitness_priority		int,
		@CSAUnsafe_priority			int,
		@CSAVehicle_priority		int
declare	@CSACargo_rollupfactor		int,
		@CSACSA_rollupfactor		int,
		@CSAFatigue_rollupfactor	int,
		@CSAFitness_rollupfactor	int,
		@CSAUnsafe_rollupfactor		int,
		@CSAVehicle_rollupfactor	int
declare	@CSAOverall_description		varchar(60),
		@CSACargo_description		varchar(60),
		@CSACSA_description			varchar(60),
		@CSAFatigue_description		varchar(60),
		@CSAFitness_description		varchar(60),
		@CSAUnsafe_description		varchar(60),
		@CSAVehicle_description		varchar(60)
declare	@CSACargo_percent			int,
		@CSACSA_percent				int,
		@CSAFatigue_percent			int,
		@CSAFitness_percent			int,
		@CSAUnsafe_percent			int,
		@CSAVehicle_percent			int
declare	@CSAOverall_return			int,
		@CSACargo_return			int,
		@CSACSA_return				int,
		@CSAFatigue_return			int,
		@CSAFitness_return			int,
		@CSAUnsafe_return			int,
		@CSAVehicle_return			int


declare @expcalcs table (
ec_abbr			varchar(12) null,
ec_enabled		char(1) null,
ec_expcode		varchar(12) null,
ec_threshhold1	int null,
ec_threshhold2	int null,
ec_priority		int null,
ec_rollupfactor	int null,
ec_description	varchar(60) null,
ec_score		int null
)

insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_threshhold2, ec_description)
values ('CSAOverall', '', 'N', 0, 0, '')
insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_priority, ec_rollupfactor, ec_description)
values ('CSACargo', '', 'N', 0, 0, 0, '')
insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_priority, ec_rollupfactor, ec_description)
values ('CSACSA', '', 'N', 0, 0, 0, '')
insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_priority, ec_rollupfactor, ec_description)
values ('CSAFatigue', '', 'N', 0, 0, 0, '')
insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_priority, ec_rollupfactor, ec_description)
values ('CSAFitness', '', 'N', 0, 0, 0, '')
insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_priority, ec_rollupfactor, ec_description)
values ('CSAUnsafe', '', 'N', 0, 0, 0, '')
insert @expcalcs (ec_abbr, ec_expcode, ec_enabled, ec_threshhold1, ec_priority, ec_rollupfactor, ec_description)
values ('CSAVehicle', '', 'N', 0, 0, 0, '')

select 	@CSAOverall_return	 = 0,
		@CSACargo_return	 = 0,
		@CSACSA_return		 = 0,
		@CSAFatigue_return	 = 0,
		@CSAFitness_return	 = 0,
		@CSAUnsafe_return	 = 0,
		@CSAVehicle_return	 = 0

update @expcalcs set ec_threshhold1 = gi_integer1
from generalinfo
where gi_name = ec_abbr and gi_integer1 is not null

update @expcalcs set ec_threshhold2 = gi_integer2
from generalinfo
where gi_name = ec_abbr and gi_integer2 is not null
and ec_abbr = 'CSAOverall'

update @expcalcs set ec_priority = gi_integer1
from generalinfo
where gi_name = ec_abbr + 'Expiration' and gi_integer1 is not null
and ec_abbr <> 'CSAOverall'

update @expcalcs set ec_rollupfactor = gi_integer2
from generalinfo
where gi_name = ec_abbr and gi_integer2 is not null
and ec_abbr <> 'CSAOverall'

update @expcalcs set ec_enabled = gi_string1
from generalinfo
where gi_name = ec_abbr + 'Expiration' and gi_string1 is not null

update @expcalcs set ec_description = gi_string4
from generalinfo
where gi_name = ec_abbr and gi_string4 is not null

update @expcalcs set ec_expcode = gi_string2
from generalinfo
where gi_name = ec_abbr + 'Expiration' and gi_string2 is not null

select @dt = GETDATE()
select	@CSAOverall_enabled		= ec_enabled,
		@CSAOverall_expcode		= ec_expcode,
		@CSAOverall_threshhold1	= ec_threshhold1,
		@CSAOverall_threshhold2	= ec_threshhold2,
		@CSAOverall_description	= 'Overall CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSAOverall'
select	@CSACargo_enabled		= ec_enabled,
		@CSACargo_expcode		= ec_expcode,
		@CSACargo_threshhold	= ec_threshhold1,
		@CSACargo_priority		= ec_priority,
		@CSACargo_rollupfactor	= ec_rollupfactor,
		@CSACargo_description	= ec_description + ' CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSACargo'
select	@CSACSA_enabled			= ec_enabled,
		@CSACSA_expcode			= ec_expcode,
		@CSACSA_threshhold		= ec_threshhold1,
		@CSACSA_priority		= ec_priority,
		@CSACSA_rollupfactor	= ec_rollupfactor,
		@CSACSA_description		= ec_description + ' CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSACSA'
select	@CSAFatigue_enabled		= ec_enabled,
		@CSAFatigue_expcode		= ec_expcode,
		@CSAFatigue_threshhold	= ec_threshhold1,
		@CSAFatigue_priority	= ec_priority,
		@CSAFatigue_rollupfactor = ec_rollupfactor,
		@CSAFatigue_description	= ec_description + ' CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSAFatigue'
select	@CSAFitness_enabled		= ec_enabled,
		@CSAFitness_expcode		= ec_expcode,
		@CSAFitness_threshhold	= ec_threshhold1,
		@CSAFitness_priority	= ec_priority,
		@CSAFitness_rollupfactor = ec_rollupfactor,
		@CSAFitness_description	= ec_description + ' CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSAFitness'
select	@CSAUnsafe_enabled		= ec_enabled,
		@CSAUnsafe_expcode		= ec_expcode,
		@CSAUnsafe_threshhold	= ec_threshhold1,
		@CSAUnsafe_priority		= ec_priority,
		@CSAUnsafe_rollupfactor	= ec_rollupfactor,
		@CSAUnsafe_description	= ec_description + ' CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSAUnsafe'
select	@CSAVehicle_enabled		= ec_enabled,
		@CSAVehicle_expcode		= ec_expcode,
		@CSAVehicle_threshhold	= ec_threshhold1,
		@CSAVehicle_priority	= ec_priority,
		@CSAVehicle_rollupfactor = ec_rollupfactor,
		@CSAVehicle_description	= ec_description + ' CSA auto generated expiration'
from	@expcalcs where ec_abbr = 'CSAVehicle'

select	@factoraccum = sum(ec_rollupfactor) from @expcalcs where ec_abbr <> 'CSAOverall'

--select * from @expcalcs

select @thisid = min(mpp_id) from csadata where Query_ID = @Query_ID and (@mpp_id = 'UNKNOWN' or @mpp_id = mpp_id)
while @thisid is not null begin

	select	@percentaccum=0
	select	@CSACargo_percent	= cargo_related_rank,
			@CSACSA_percent		= controlled_substances_rank,
			@CSAFatigue_percent	= driver_fitness_rank,
			@CSAFitness_percent	= fatigued_driving_rank,
			@CSAUnsafe_percent	= unsafe_driving_rank,
			@CSAVehicle_percent	= vehicle_maintenance_rank
	from 	csadata
	where	Query_ID = @Query_ID and mpp_id = @thisid

	if @CSACargo_percent > @CSACargo_threshhold begin
		select @CSACargo_return = 1 --set the return value to make alert flag visible
		if @CSACargo_enabled = 'Y' begin
			exec create_expiration_sp 3, 'DRV', @thisid, @CSACargo_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSACargo_description
		end
	else
		-- close any 
		if @CSACargo_enabled = 'Y'
			exec create_expiration_sp 0, 'DRV', @thisid, @CSACargo_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSACargo_description
	end
	select	@percentaccum = @percentaccum + @CSACargo_percent * @CSACargo_rollupfactor
	if @CSACSA_percent > @CSACSA_threshhold begin
		select @CSACSA_return = 1 --set the return value to make alert flag visible
		if @CSACSA_enabled = 'Y' begin
			exec create_expiration_sp 3, 'DRV', @thisid, @CSACSA_expcode, @dt, @dt, 'N', @CSACSA_priority, '2049-12-31 23:59:00.000', @CSACSA_description
		end
	else
		-- close any 
		if @CSACSA_enabled = 'Y'
			exec create_expiration_sp 0, 'DRV', @thisid, @CSACSA_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSACSA_description
	end
	select	@percentaccum = @percentaccum + @CSACSA_percent * @CSACSA_rollupfactor

	if @CSAFatigue_percent > @CSAFatigue_threshhold begin
		select @CSAFatigue_return = 1 --set the return value to make alert flag visible
		if @CSAFatigue_enabled = 'Y' begin
			exec create_expiration_sp 3, 'DRV', @thisid, @CSAFatigue_expcode, @dt, @dt, 'N', @CSAFatigue_priority, '2049-12-31 23:59:00.000', @CSAFatigue_description
		end
	else
		-- close any 
		if @CSAFatigue_enabled = 'Y'
			exec create_expiration_sp 0, 'DRV', @thisid, @CSAFatigue_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSAFatigue_description
	end
	select	@percentaccum = @percentaccum + @CSAFatigue_percent * @CSAFatigue_rollupfactor

	if @CSAFitness_percent > @CSAFitness_threshhold begin
		select @CSAFitness_return = 1 --set the return value to make alert flag visible
		if @CSAFitness_enabled = 'Y' begin
			exec create_expiration_sp 3, 'DRV', @thisid, @CSAFitness_expcode, @dt, @dt, 'N', @CSAFitness_priority, '2049-12-31 23:59:00.000', @CSAFitness_description
		end
	else
		-- close any 
		if @CSAFitness_enabled = 'Y'
			exec create_expiration_sp 0, 'DRV', @thisid, @CSAFitness_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSAFitness_description
	end
	select	@percentaccum = @percentaccum + @CSAFitness_percent * @CSAFitness_rollupfactor

	if @CSAUnsafe_percent > @CSAUnsafe_threshhold begin
		select @CSAUnsafe_return = 1 --set the return value to make alert flag visible
		if @CSAUnsafe_enabled = 'Y' begin
			exec create_expiration_sp 3, 'DRV', @thisid, @CSAUnsafe_expcode, @dt, @dt, 'N', @CSAUnsafe_priority, '2049-12-31 23:59:00.000', @CSAUnsafe_description
		end
	else
		-- close any
		if @CSAUnsafe_enabled = 'Y'
			exec create_expiration_sp 0, 'DRV', @thisid, @CSAUnsafe_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSAUnsafe_description
	end
	select	@percentaccum = @percentaccum + @CSAUnsafe_percent * @CSAUnsafe_rollupfactor

	if @CSAVehicle_percent > @CSAVehicle_threshhold begin
		select @CSAVehicle_return = 1 --set the return value to make alert flag visible
		if @CSAVehicle_enabled = 'Y' begin
			exec create_expiration_sp 3, 'DRV', @thisid, @CSAVehicle_expcode, @dt, @dt, 'N', @CSAVehicle_priority, '2049-12-31 23:59:00.000', @CSAVehicle_description
		end
	else
		-- close any 
		if @CSAVehicle_enabled = 'Y' 
			exec create_expiration_sp 0, 'DRV', @thisid, @CSAVehicle_expcode, @dt, @dt, 'N', @CSACargo_priority, '2049-12-31 23:59:00.000', @CSAVehicle_description
	end
	select	@percentaccum = @percentaccum + @CSAVehicle_percent * @CSAVehicle_rollupfactor
	--now do overall
	if @CSAOverall_enabled = 'Y'
		if @factoraccum > 0 and @percentaccum > 0 begin
			select @overalscore	= round(cast(@percentaccum as float)/cast(@factoraccum as float),0)
			if @overalscore > @CSAOverall_threshhold1 begin
				select @CSAOverall_return = 1
				exec create_expiration_sp 3, 'DRV', @thisid, @CSAOverall_expcode, @dt, @dt, 'N', 1, '2049-12-31 23:59:00.000', @CSAOverall_description
			end else if @overalscore > @CSAOverall_threshhold2 begin
				select @CSAOverall_return = 2
				exec create_expiration_sp 3, 'DRV', @thisid, @CSAOverall_expcode, @dt, @dt, 'N', 2, '2049-12-31 23:59:00.000', @CSAOverall_description
			end
			--vjh need to have this score placed on the manpowerprofle
			update manpowerprofile set mpp_csa_score = @overalscore where mpp_id = @thisid
		end else begin
			update manpowerprofile set mpp_csa_score = 0 where mpp_id = @thisid
		end
	
	select @thisid = min(mpp_id) from csadata where Query_ID = @Query_ID and (@mpp_id = 'UNKNOWN' or @mpp_id = mpp_id) and mpp_id > @thisid
end

select	@CSAOverall_return	'CSAOverall',
		@CSACargo_return	'CSACargo',
		@CSACSA_return		'CSACSA',
		@CSAFatigue_return	'CSAFatigue',
		@CSAFitness_return	'CSAFitness',
		@CSAUnsafe_return	'CSAUnsafe',
		@CSAVehicle_return	'CSAVehicle'

GO
GRANT EXECUTE ON  [dbo].[CSA_create_expirations_sp] TO [public]
GO
