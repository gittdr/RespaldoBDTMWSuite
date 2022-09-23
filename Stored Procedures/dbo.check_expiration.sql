SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create proc [dbo].[check_expiration] 
@maxdate datetime , @drv varchar(8) , @trc varchar(8) , @trl varchar(8) 
as
/**
 * REVISION HISTORY:
 * 
 * 07/18/2012.01 - PTS63481 - vjh - 2012 no longer supports the raiserror statement, change to the raiserror function
 *
 **/
declare @cnt int , @priority char(1) , @errnum int , @errtext varchar(255)

select @errnum = 0
select @cnt = 0 

if exists ( 
	select * 
	from expiration 
	where ( exp_expirationdate <= @maxdate ) and 
	( exp_completed = 'N') 
) begin 
	select @cnt = count(*) , @priority = min ( exp_priority ) 
	from expiration 
	where ( exp_expirationdate <= @maxdate ) and 
	( exp_completed = 'N') and 
	( exp_idtype = 'DRV' ) and 
	( exp_id = @drv ) 

	if @cnt > 0 
	begin
		if @priority = '1' 
			select @errnum = 50002
		else if @errnum = 0 
			select @errnum = 50001
	end

	if @errnum = 50002 
	begin
		select @errtext = 'Priority expiration due.'
		--vjh PTS63481 use function supported by sql 2012
		--raiserror @errnum @errtext 
		RAISERROR ('Error %d, message is: %s',16, 1, @errnum, @errtext)
		return 
	end

	select @cnt = count(*) , @priority = min ( exp_priority ) 
	from expiration 
	where ( exp_expirationdate <= @maxdate ) and 
	( exp_completed = 'N') and 
	( exp_idtype = 'TRC' ) and 
	( exp_id = @trc ) 

	if @cnt > 0 
	begin
		if @priority = '1' 
			select @errnum = 50002
		else if @errnum = 0 
			select @errnum = 50001
	end

	if @errnum = 50002 begin
		select @errtext = 'Priority expiration due.'
		--vjh PTS63481 use function supported by sql 2012
		--raiserror @errnum @errtext 
		RAISERROR ('Error %d, message is: %s',16, 1, @errnum, @errtext)
		return 
	end

	select @cnt = count(*) , @priority = min ( exp_priority ) 
	from expiration 
	where ( exp_expirationdate <= @maxdate ) and 
	( exp_completed = 'N') and 
	( exp_idtype = 'TRL' ) and 
	( exp_id = @trl ) 

	if @cnt > 0 
	begin
		if @priority = '1' 
			select @errnum = 50002
		else if @errnum = 0 
			select @errnum = 50001
		end

	if @errnum = 50002 
	begin
		select @errtext = 'Priority expiration due.'
		--vjh PTS63481 use function supported by sql 2012
		--raiserror @errnum @errtext 
		RAISERROR ('Error %d, message is: %s',16, 1, @errnum, @errtext)
		return 
	end

	if @errnum = 50001 begin
		select @errtext = 'Non-priority expiration due.'
		--vjh PTS63481 use function supported by sql 2012
		--raiserror @errnum @errtext 
		RAISERROR ('Error %d, message is: %s',16, 1, @errnum, @errtext)
		return 
	end
end            
GO
GRANT EXECUTE ON  [dbo].[check_expiration] TO [public]
GO
