SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--this stored procedure does not allow the new expiration date is ealier than today.
--	it activates the expired trailer
CREATE PROCEDURE [dbo].[edi_inbound_activateTrailer_sp] 
(	
	@trl_id varchar(13),
	@exp_expirationdate datetime,
	@exp_expirationdate_new datetime,
	@trl_status_new varchar(6) output
)
AS

declare 
	@user varchar(255),
	@dt datetime,
	@dtNew datetime,
	@i int

set nocount on
	
	--this stored procedure does not allow the new expiration date is ealier than today
	set @dt=getdate()
	if @dt < @exp_expirationdate
		set @dt = @exp_expirationdate

	--the new expiration should >= @exp_expirationdate
	if @exp_expirationdate_new < @dt
		set @exp_expirationdate_new =@dt


	exec gettmwuser @user
	
	-- update all expirations that expired to new dates
	set @i = 0
	--this stored procedure does not allow the new expiration date is ealier than today
	while @dt is not null
	begin
		select @dt = max(exp_expirationdate)
			from expiration
			WHERE exp_code = 'OUT' 
				AND exp_expirationdate <= @dt
				AND exp_idtype = 'TRL' 
				AND exp_id = @trl_id
				AND exp_completed = 'N'
		
		--check if the new date exsits
		set @dtNew = dateadd(day, @i, @exp_expirationdate_new)
		--if the expiration exists, set the new date to the lastest expiration date + 5
		if exists
			(select * from expiration
				WHERE exp_code = 'OUT' 
					AND exp_expirationdate = @dtNew 
					AND exp_idtype = 'TRL' 
					AND exp_id = @trl_id
					AND exp_completed = 'N')
		begin
			select @dtNew = dateadd(day, 1, max(exp_expirationdate))
				from expiration
				WHERE exp_code = 'OUT' 
					AND exp_idtype = 'TRL' 
					AND exp_id = @trl_id
					AND exp_completed = 'N'
		end

		--update
		update expiration 
			set exp_expirationdate = @dtNew
			, exp_updateby = @user, exp_updateon = getdate() 
		WHERE exp_code = 'OUT' 
			AND exp_expirationdate = @dt
			AND exp_idtype = 'TRL' 
			AND exp_id = @trl_id
			AND exp_completed = 'N'
		--increase i
		set @i = @i + 1
	end


	--update trailer status
	exec trl_expstatus @trl_id
	
	--get new trailer status
	select @trl_status_new = trl_status
	from trailerprofile
	where trl_id = @trl_id

GO
GRANT EXECUTE ON  [dbo].[edi_inbound_activateTrailer_sp] TO [public]
GO
