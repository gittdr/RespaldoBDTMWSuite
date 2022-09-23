SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[maintaincurrentdrivers_sp] 
	@p_mpp_id varchar(8),
	@p_lastname varchar(40) = null, 
	@p_firstname varchar(40) = null,
	@p_middlename char(1) = null,
	@p_hiredate datetime = null,
	@p_terminationdate datetime = null
AS
/***************************************************


exec maintaincurrentdrivers_sp '92' , 'Adkins', 'Thomase', 'W', '2/14/2008',  '2/15/2006'


****************************************************/
set nocount on

declare @v_mpp_status varchar(6),
	@v_now datetime

set @v_now = getdate()

if len(@p_lastname) = 0 or @p_lastname is null set @p_lastname = ''
if len(@p_firstname) = 0 or @p_firstname is null set @p_firstname = ''
if len(@p_middlename) = 0 or @p_middlename is null set @p_middlename = ''
--if len(@p_hiredate) = 0 set @p_hiredate = ''
--if len(@p_terminationdate) = 0 or @p_terminationdate is null set @p_terminationdate = ''

select @v_mpp_status = mpp_status
from manpowerprofile
where mpp_id = @p_mpp_id

if exists(select 1 from manpowerprofile where mpp_id = @p_mpp_id)
-- existing record
begin
	-- see if we have a termination date from the .csv file
	if len(@p_terminationdate) > 0 
	begin
		-- see if we have a terminated record in mpp
		if @v_mpp_status = 'OUT'
		begin
			-- update mpp
			update manpowerprofile
			set mpp_firstname = @p_firstname,
				mpp_middlename = @p_middlename,
				mpp_lastname = @p_lastname,
				mpp_terminationdt = @p_terminationdate
				-- status remains 'OUT'
			where mpp_id = @p_mpp_id
	
		end
		else  --not terminated in mpp 
		begin
			-- update mpp
			update manpowerprofile
			set mpp_firstname = @p_firstname,
				mpp_middlename = @p_middlename,
				mpp_lastname = @p_lastname,
				mpp_terminationdt = @p_terminationdate,
				mpp_status = 'OUT'
			where mpp_id = @p_mpp_id

			-- insert or update expiration
			if not exists(select 1 from expiration
			where exp_idtype = 'DRV'
			and exp_id = @p_mpp_id
			and exp_code = 'OUT'
			and exp_expirationdate = @p_terminationdate)
			begin
				INSERT INTO expiration ( 
				exp_code, 
				exp_lastdate, 
				exp_expirationdate, 
				exp_routeto, 
				exp_idtype, 
				exp_id, 
				exp_completed, 
				exp_priority, 
				exp_compldate, 
				exp_creatdate, 
				exp_updateby, 
				exp_updateon, 
				exp_city ) 
				
				VALUES ( 
				'OUT', 
				@v_now, 
				@p_terminationdate,
				'UNKNOWN', 
				'DRV', 
				@p_mpp_id, 
				'N', 
				'1', 
				'12-31-2049 23:59:0.000',
				@v_now,
				'AutoImport',
				@v_now,
				0 )
			end
			else
			begin
				update expiration
				set exp_completed = 'N',
					exp_compldate = '12-31-2049 23:59:0.000'
				where exp_idtype = 'DRV'
					and exp_id = @p_mpp_id
					and exp_code = 'OUT'
					and exp_expirationdate = @p_terminationdate			
			end

			-- set Dispatch expirations
			exec drv_expstatus @p_mpp_id

		end			
		
	end
	else -- no termination date in .csv.
	begin
		-- see if we have a terminated record in mpp
		if @v_mpp_status = 'OUT'
		begin
			-- updat mpp = avl
			update manpowerprofile
			set mpp_firstname = @p_firstname,
				mpp_middlename = @p_middlename,
				mpp_lastname = @p_lastname,
				mpp_terminationdt = '12-31-2049 23:59:0.000',
				mpp_status = 'AVL'
			where mpp_id = @p_mpp_id

			-- complete expiration
			update expiration
			set exp_completed = 'Y',
				exp_compldate = @v_now
			where exp_idtype = 'DRV'
				and exp_id = @p_mpp_id
				and exp_code = 'OUT'
		
			-- set Dispatch expirations
			exec drv_expstatus @p_mpp_id

		end
		else --no termination in mpp
		begin
			-- upd mpp
			update manpowerprofile
			set mpp_firstname = @p_firstname,
				mpp_middlename = @p_middlename,
				mpp_lastname = @p_lastname,
				mpp_terminationdt = '12-31-2049 23:59:0.000',
				mpp_status = 'AVL'
			where mpp_id = @p_mpp_id
		end	
	end
end
else -- new mpp_id
begin
	-- They may send future hires in the file.  
	-- Only import the driver if hire date is not in the future.
	if @p_hiredate <= @v_now
		-- see if we have a termination date from the .csv file
		if len(@p_terminationdate) > 0 
		begin
			-- insert mpp
			insert manpowerprofile(
			mpp_id, 
			mpp_firstname, 
			mpp_middlename, 
			mpp_lastname, 
			mpp_hiredate, 
			mpp_status)
	
			values(
			@p_mpp_id, 
			@p_firstname, 
			@p_middlename, 
			@p_lastname, 
			@p_hiredate, 
			'AVL')
	
			-- insert expiration
			INSERT INTO expiration ( 
			exp_code, 
			exp_lastdate, 
			exp_expirationdate, 
			exp_routeto, 
			exp_idtype, 
			exp_id, 
			exp_completed, 
			exp_priority, 
			exp_compldate, 
			exp_creatdate, 
			exp_updateby, 
			exp_updateon, 
			exp_city ) 
			
			VALUES ( 
			'OUT', 
			@v_now, 
			@p_terminationdate,
			'UNKNOWN', 
			'DRV', 
			@p_mpp_id, 
			'N', 
			'1', 
			'12-31-2049 23:59:0.000',
			@v_now,
			'AutoImport',
			@v_now,
			0 )
	
			-- set Dispatch expirations
			exec drv_expstatus @p_mpp_id
		end
		else  --  no term dt in .csv
		begin		
			begin
				-- insert mpp
				insert manpowerprofile(
				mpp_id, 
				mpp_firstname, 
				mpp_middlename, 
				mpp_lastname, 
				mpp_hiredate, 
				mpp_status)
		
				values(
				@p_mpp_id, 
				@p_firstname, 
				@p_middlename, 
				@p_lastname, 
				@p_hiredate, 
				'AVL')
		end
	end
end


set nocount off
GO
GRANT EXECUTE ON  [dbo].[maintaincurrentdrivers_sp] TO [public]
GO
