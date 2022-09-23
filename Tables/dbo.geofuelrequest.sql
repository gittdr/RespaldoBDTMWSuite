CREATE TABLE [dbo].[geofuelrequest]
(
[gf_lgh_number] [int] NOT NULL,
[gf_trans_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_start_date] [datetime] NULL,
[gf_mov_number] [int] NULL,
[gf_req_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_tractor] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_tank_gals] [smallint] NULL,
[gf_mpg] [float] NULL,
[gf_min_purchase] [smallint] NULL,
[gf_tank_cap] [smallint] NULL,
[gf_tank_min] [smallint] NULL,
[gf_strategy] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_facilities] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_reserved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_load_number] [int] NULL,
[gf_networks] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_network_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_heavy] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_avoid_toll] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_first_leg] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_over_length] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_send_message] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_flags] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_cities] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_response] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_summary] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_route] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_status] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazmat_route] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazmat_class] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[display] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[route_network] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[generate_route] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[return_optimum] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[return_route_solution] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[load_id] [int] NULL,
[driver_mgr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_city_cmp] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_trltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_requestid] [int] NOT NULL IDENTITY(1, 1),
[gf_request_date] [datetime] NULL,
[gf_completion_date] [datetime] NULL,
[gf_tank_gal_override] [int] NULL,
[gf_request_source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_process_override] [int] NOT NULL CONSTRAINT [DF__geofuelre__gf_pr__65AE9C1D] DEFAULT (0),
[gf_network_transtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_createdate] [datetime] NULL,
[gf_last_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_last_updatedate] [datetime] NULL,
[ef_companytype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ef_RtnStpSequence] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ef_sendsolution] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__geofuelre__ef_se__4AE69469] DEFAULT ('Y'),
[gf_deflevel] [int] NULL,
[ef_planid] [int] NULL,
[gf_rs_generate_message] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_rs_managed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_rs_compliance] [int] NULL,
[gf_rs_oor] [decimal] (4, 1) NULL,
[gf_cashcard1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_account1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_customer1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_security1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_cashcard2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_account2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_customer2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_security2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gf_highvalue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[iut_geofuelrequest_consolidated] ON [dbo].[geofuelrequest] FOR UPDATE,INSERT AS 
/*
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

Declare	@TimeTracking	char(1),
	@TrackTrlType	char(1),
	@lgh_number	int,
	@requestid	int,
	@ProcessFuelReqOnStart	char(1),
	@EFEnableHazMat	char(1),
	@EFHazMatInterface	char(1),
	@nettranstypeproc	varchar(50),
	@nettranstype	char(1),
	@mintanklevel	int,
	@mintankvalue	int,
	@hazmat_load		char(1),
	@hazmat_count		int,
	@tmwuser varchar (255),
	@insertcount int,
	@deletecount int,
	@CompanyTypeProc	varchar(100),
	@CompanyTypeValue	varchar(10),
	@Fingerprintaudit	CHAR(1),
	@UseTripAudit		CHAR(1),
	@SendCardInfo	char (1), 
	@CardVendor		varchar (8),
	@SendSecurityCard char (1),
	@CardUserId varchar (20), 
	@cardnumber varchar (20),
	@accountid varchar (10),
	@customerid varchar (10), 
	@security varchar (10), 
	@trc varchar (13), @drv1 varchar(13), @drv2 varchar (13),
	@last_card varchar (20)
BEGIN
	select @insertcount = count(*) from inserted
	select @deletecount = count(*) from deleted

	SELECT @Fingerprintaudit = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
          FROM generalinfo
         WHERE gi_name = 'Fingerprintaudit'

	SELECT @UseTripAudit = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
          FROM generalinfo
         WHERE gi_name = 'UseTripAudit'
	SELECT @SendSecurityCard = LEFT(ISNull(gi_string1, 'N'), 1), @CardUserID = gi_string2
		FROM generalinfo
		WHERE gi_name = 'fa_getsecuritycard'
	SELECT @SendCardInfo = LEFT(ISNull(gi_string1, 'N'), 1), @CardVendor = gi_string2
		FROM generalinfo
		WHERE gi_name = 'fa_getcashcard'

	/* Update the Tractor on the Request record		*/
--There are 2 update triggers on geofuelrequest, so try to only do 1 update if any at all....do it in one statement.
--79330 add with (nolock) on legheader to prevent deadlocks at CRE
	UPDATE geofuelrequest
	SET 
		gf_tractor = lgh_tractor,
		driver1 = legheader.lgh_driver1,
		driver2 = legheader.lgh_driver2
 	FROM inserted inner join legheader with (nolock) on inserted.gf_lgh_number = legheader.lgh_number
		inner join geofuelrequest g on g.gf_lgh_number=inserted.gf_lgh_number
		and g.gf_requestid = inserted.gf_requestid
		where (g.gf_status<>'CMP') 
		and (
			(legheader.lgh_tractor <> g.gf_tractor) or
			(legheader.lgh_driver1 <> g.driver1) or
			(legheader.lgh_driver2 <> g.driver2)
			)
		
	/* 
		PTS 52921 - DJM - 8/18/2010 - Since we now allow for multiple records with the same lgh_number, we should
		look for any prior records for the leg that are in 'RUN' status and set them to HOLD so they're not processed.
	*/
	update geofuelrequest
	set gf_status = 'HOLD'
	from inserted join geofuelrequest gf on inserted.gf_lgh_number = gf.gf_lgh_number
	where gf.gf_requestid < inserted.gf_requestid 
		and gf.gf_status = 'RUN'
	
	

	/* PTS 27636 - DJM - Check for GI setting to set the date/time the row was set the the Run and
		Complete status to allow outside processes to track the ExpertFuel processing.
	*/
	--Select @TimeTracking = Left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'GeoFuelRequestTimeTrack'

	--If @TimeTracking = 'Y'
	--	Begin
		Update geofuelrequest
			set gf_request_date = GetDate()
			from inserted Inner Join geofuelrequest gf on inserted.gf_lgh_number = gf.gf_lgh_number
				and inserted.gf_requestid = gf.gf_requestid
			Where inserted.gf_status = 'RUN'

		Update geofuelrequest
			set gf_completion_date = getdate()
			from inserted inner join geofuelrequest gf on inserted.gf_lgh_number = gf.gf_lgh_number
				and inserted.gf_requestid = gf.gf_requestid
			where inserted.gf_status = 'CMP'

		-- 07/22/2014 MDH PTS 79594: Update card information for legs in RUN status
		if @SendCardInfo = 'Y' 
		BEGIN
			select @requestid =  isNull(min(gf_requestid),0) 
				from inserted
				Where inserted.gf_status = 'RUN'
			while @requestid > 0
			BEGIN
				SELECT @last_card = null, @cardnumber = null
				SELECT @trc = gf_tractor, @drv1 = driver1, @drv2 = driver2 
					FROM geofuelrequest
					WHERE gf_requestid = @requestid
				exec dbo.fa_get_driver1_card @driver=@drv1, @tractor=@trc, @cardnumber=@cardnumber OUTPUT, @accountid=@accountid OUTPUT, @customerid=@customerid OUTPUT, @security=@security OUTPUT
				IF @cardnumber is not null
				BEGIN 
					UPDATE geofuelrequest 
						SET gf_cashcard1 = @cardnumber, 
							  gf_account1 = @accountid, 
							  gf_customer1 = @customerid, 
							  gf_security1 = @security
						WHERE gf_requestid = @requestid
					SELECT @last_card = @cardnumber 
				END
				SELECT @cardnumber = NULL
				exec dbo.fa_get_driver2_card @driver=@drv2, @tractor=@trc, @cardnumber=@cardnumber OUTPUT, @accountid=@accountid OUTPUT, @customerid=@customerid OUTPUT, @security=@security OUTPUT
				IF @cardnumber is not null and @last_card is not null and @cardnumber <> @last_card 
					UPDATE geofuelrequest 
						SET gf_cashcard2 = @cardnumber, 
							  gf_account2 = @accountid, 
							  gf_customer2 = @customerid, 
							  gf_security2 = @security
						WHERE gf_requestid = @requestid
				SELECT @requestid =  isNull(min(gf_requestid),0) 
					from inserted
					Where inserted.gf_status = 'RUN'
					and isNull (gf_requestid, 0) > @requestid
			END
		END
		--End


	/* PTS 27857 - DJM - Check for GI setting to pass the Type of trailer to ExpertFuel. If it's on
		call the proc to update the column on the Geofuelrequest table
	*/
	Select @TrackTrlType = Left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'SetExpFuelTrlType'
	
	if @TrackTrlType = 'Y'
		Begin
			-- Get the First lgh_number
			select @requestid =  isNull(min(gf_requestid),0) 
			from inserted
			Where inserted.gf_status = 'RUN'

			select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid


			While @requestid > 0
				Begin
					exec update_gf_trltype_sp @lgh_number, @requestid
	
					-- Get the next updated lgh_number
					select @requestid = isNull(min(gf_requestid),0) 
					from inserted
					where gf_requestid > @requestid
						and inserted.gf_status = 'RUN'
				end
		End

	/* PTS 31864 - DJM - Create option to prevent a Fuel Solution Request from getting processed 
		until the Trip Segment is started. This allows the Driver time to update the 
		Tractor's actual fuel level on the Consignee-End totalmail macro.  When the trip
		is started, the Request record will be updated with the current fuel level from the
		Tractorprofile and set to a status ('RUN') that will be processed by the Fuel Agent
		application										*/
	Select @ProcessFuelReqOnStart = Left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'ProcessFuelReqOnStart'
	if @ProcessFuelReqOnStart = 'Y'
		Begin	

		if Update(gf_status) 
			Update geofuelrequest
			set gf_status = 'HOLD'
			from geofuelrequest inner join inserted on geofuelrequest.gf_lgh_number = inserted.gf_lgh_number
				and geofuelrequest.gf_requestid = inserted.gf_requestid
				inner join legheader l with (nolock) on geofuelrequest.gf_lgh_number = l.lgh_number
			where (l.lgh_outstatus <> 'STD' and l.lgh_outstatus <> 'CMP') 
				and geofuelrequest.gf_process_override = 0

		End

	Declare @deleted int,
		@inserted	int

	select @deleted = count(*) from deleted
	select @inserted = count(*) from inserted

	/* PTS 31689 - DJM - Create trigger to Mark Fuel Requests as COMPLETE when the tractor on the 
		request exists in the new table expfuel_ignore_tractorlist						*/
	If @inserted > 0
		IF exists (select 1 from generalinfo where gi_name = 'ExpFuelIgnoreTractor' and gi_string1 = 'Y')
			IF Update(gf_tractor) AND (@deleted = 0 OR exists (select 1 from expfuel_ignore_tractorlist inner join inserted on expfuel_ignore_tractorlist.trc_number = inserted.gf_tractor))
			Begin
		
				UPDATE geofuelrequest
				set geofuelrequest.gf_status = 'CMP'
				from geofuelrequest g inner join inserted i on (i.gf_lgh_number = g.gf_lgh_number
					and g.gf_requestid = i.gf_requestid
					and g.gf_status <> 'CMP')
					inner join expfuel_ignore_tractorlist eit on rtrim(eit.trc_number) = g.gf_tractor
			End

	/* 
		PTS 45570 - DJM - Enable HazMat support in the ExpertFuel Request.  Add option to call stored procedure to look at the commodities
			on the leg and set the appropriate HazMat flag and codes on the Request record.

		PTS 47944 - DJM - Modify the trigger to only modify request records created by the Stored Proc. Requests created by the app should
				allow users to control the Hazmat values.
				
		PTS 47795 - DJM - Modified to verify that there is a Hazardous commodity on the load prior to calling the proc to Set the hazardous type.
	*/
		
	Select @EFEnableHazMat = Left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'EFEnableHazMat'
	Select @EFHazMatInterface = Left(isnull(gi_string1,''),1) from generalinfo where gi_name = 'EFHazMatInterface'

	If @inserted > 0 AND @EFEnableHazMat = 'Y'
		Begin
			
			-- Get the First lgh_number
			select @requestid =  isNull(min(gf_requestid),0) 
			from inserted
			Where inserted.gf_status = 'RUN'
				and inserted.gf_request_source like '%create_fueloptrequest_sp%'

			While @requestid > 0
				Begin
					select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid
					select @hazmat_load = hazmat_route from inserted where inserted.gf_requestid = @requestid

					-- count the hazardous commodities on the trip
					select @hazmat_count = count(*)
					from freightdetail f join stops s on f.stp_number = s.stp_number
						join commodity c on f.cmd_code = c.cmd_code
					where s.lgh_number = @lgh_number
						and f.cmd_code is not null
						and f.cmd_code <> 'UNKNOWN'
						and cmd_active = 'Y'
						and cmd_hazardous > 0

					-- if any hazardous commodities are on the load OR the load is already marked as hazardous, find the class.	
					if @hazmat_load = 'Y' OR @hazmat_count > 0
						exec expertfuel_hazmat_settings_sp @lgh_number, @requestid

					-- Get the next updated lgh_number
					select @requestid = isNull(min(gf_requestid),0)
					from inserted
					where gf_requestid > @requestid
						and inserted.gf_status = 'RUN'
						and inserted.gf_request_source like '%create_fueloptrequest_sp%'
				end
		end

	/* 
		PTS 46324 - DJM - Enable Customers to set the Network Transaction Type field .
	*/
	If @inserted > 0 and exists (select 1 from generalinfo where gi_name = 'EFNetworkTransTypeLogic' and Left(gi_string1,1) = 'Y')
		Begin
			select @nettranstypeproc = isnull(ltrim(rtrim(gi_string2)),'') from generalinfo where gi_name = 'EFNetworkTransTypeLogic'
			
			if @nettranstypeproc = ''
				Begin
					-- Get the First lgh_number
					select @requestid =  isNull(min(gf_requestid),0) 
					from inserted
					Where inserted.gf_status = 'RUN'

					select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid


					While @requestid > 0
						Begin
							-- This logic was originally added for QDI. Should be the default.
							Select @nettranstype = Case trc_actg_type
								when 'A' then '2'
								when 'N' then '1'
								else ' '
								end
							from tractorprofile trc join inserted on trc_number = gf_tractor
							where inserted.gf_lgh_number = @lgh_number

							-- Set the value on the Geofuelrequest record
							Update geofuelrequest
							set gf_network_transtype = @nettranstype
							from inserted
							where geofuelrequest.gf_lgh_number = inserted.gf_lgh_number
								and geofuelrequest.gf_requestid	= inserted.gf_requestid
								and geofuelrequest.gf_lgh_number = @lgh_number
								and geofuelrequest.gf_requestid = @requestid

							-- Get the next updated lgh_number
							select @requestid = isNull(min(gf_requestid),0) 
							from inserted
							where gf_requestid > @requestid
								and inserted.gf_status = 'RUN'
						End 
				End
			else
				-- If a proc is specified in the gi_string2 value in the GI setting, then use it to set the Hazmat values. This proc
				--		is designed to be 'soft' coded based on the customer's requirements. The 'standard' proc written and supplied uses
				--		the ALK and RAND Hazmat settings from TMWSuite.
				Begin

					if exists (SELECT 1 FROM INFORMATION_SCHEMA.routines WHERE routine_name = @nettranstypeproc and routine_type = 'procedure')
					  begin  
						-- Get the First lgh_number
						select @requestid =  isNull(min(gf_requestid),0) 
						from inserted
						Where inserted.gf_status = 'RUN'

						select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid


						While @requestid > 0
							Begin
								exec @nettranstypeproc @lgh_number, @requestid, @nettranstype OUT
				
								-- Set the value on the Geofuelrequest record
								Update geofuelrequest
								set gf_network_transtype = @nettranstype
								from inserted
								where geofuelrequest.gf_lgh_number = inserted.gf_lgh_number
									and geofuelrequest.gf_requestid	= inserted.gf_requestid
									and geofuelrequest.gf_lgh_number = @lgh_number
									and geofuelrequest.gf_requestid = @requestid
	
								-- Get the next updated lgh_number
								select @requestid = isNull(min(gf_requestid),0) 
								from inserted
								where gf_requestid > @requestid
									and inserted.gf_status = 'RUN'

								select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid
							end

						 -- RAISERROR ('@nettranstype.  %s', 16, 1, @nettranstype)  
					   end 
					else
					  BEGIN  
						 RAISERROR ('Stored Procedure does not Exist. Value for generalinfo setting EFNetworkTransTypeLogic is set this proc, but it does not exist in the database: %s', 16, 1, @nettranstypeproc)  
						 RETURN  
					  END  

				 
				End		

		end -- end 46324

	/* 
		PTS 46703 - DJM - Enforce the minimum tank level
	*/
	If @inserted > 0 
		Begin
			select @mintanklevel = gi_integer1,
				@mintankvalue = gi_integer2 
			from generalinfo where gi_name = 'EFTankLevelDefaultThreshold' 
			
			if @mintanklevel > 0 and @mintankvalue > 0 
				Begin
					-- Get the First lgh_number
					select @requestid =  isNull(min(gf_requestid),0) 
					from inserted
					Where inserted.gf_status = 'RUN'

					select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid

					While @requestid > 0
						Begin
							if exists (select 1 from inserted where inserted.gf_lgh_number = @lgh_number and gf_tank_gals < @mintanklevel) 

								Update geofuelrequest
								set gf_tank_gals = @mintankvalue
								from inserted
								where geofuelrequest.gf_lgh_number = inserted.gf_lgh_number
									and geofuelrequest.gf_requestid	= inserted.gf_requestid
									and geofuelrequest.gf_lgh_number = @lgh_number
									and geofuelrequest.gf_requestid = @requestid
									and geofuelrequest.gf_status = 'RUN'
									and geofuelrequest.gf_tank_gals < @mintanklevel
									and geofuelrequest.gf_tank_gals <> @mintankvalue

							-- Get the next updated lgh_number
							select @requestid = isNull(min(gf_requestid),0) 
							from inserted
							where gf_requestid > @requestid
								and inserted.gf_status = 'RUN'

							select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid
						end
				End
		end -- end 46703
	 
	--	PTS 56676 - DJM - Track who created the record and last updated it.
	exec gettmwuser @tmwuser output
	
	if @insertcount > 0 and @deletecount = 0
	BEGIN
		update geofuelrequest
		set gf_createdby = @tmwuser,
			gf_createdate = getdate(),
			gf_last_updatedby = @tmwuser,
			gf_last_updatedate = getdate()
		from geofuelrequest inner join inserted on geofuelrequest.gf_requestid = inserted.gf_requestid

		IF @fingerprintaudit = 'Y' AND @UseTripAudit = 'Y'
                BEGIN
			INSERT INTO expedite_audit (ord_hdrnumber, mov_number, lgh_number, activity, update_note,
		                               join_to_table_name, key_value, updated_by, updated_dt)
                      SELECT l.ord_hdrnumber,
                             l.mov_number,
                             l.lgh_number,
                             'Fuel Solution Rqst',
                             '',
                             'geofuelrequest',
                             i.gf_requestid,
                             @tmwuser,
                             GETDATE()
                        FROM inserted i JOIN legheader l ON i.gf_lgh_number = l.lgh_number
 		END
	END
			
			
	if @insertcount > 0 and @deletecount > 0 
		update geofuelrequest
		set gf_last_updatedby = @tmwuser,
			gf_last_updatedate = getdate()
		from geofuelrequest inner join inserted on geofuelrequest.gf_requestid = inserted.gf_requestid
		
		
	-- PTS 58941 - DJM - Update the new ef_companytype field based on Stored Proc. The Proc is to be called by the Trigger.
	if exists (select 1 from generalinfo where gi_name = 'EFSetCompanyTypeField' and gi_string1 = 'Y')
		Begin
			select @CompanyTypeProc = isnull(ltrim(rtrim(gi_string2)),'') from generalinfo where gi_name = 'EFSetCompanyTypeField'

			Declare @proccount as integer
			
			SELECT @proccount = count(*) FROM INFORMATION_SCHEMA.routines WHERE routine_name = @CompanyTypeProc and routine_type = 'procedure'
			if exists(SELECT * FROM INFORMATION_SCHEMA.routines WHERE routine_name = @CompanyTypeProc and routine_type = 'procedure')
			   begin  
			   
				-- Get the First lgh_number
				select @requestid =  isNull(min(gf_requestid),0) 
				from inserted
				Where inserted.gf_status = 'RUN'

				select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid

				While @requestid > 0
					Begin
						exec @CompanyTypeProc @lgh_number, @requestid, @CompanyTypeValue OUT
		
						-- Set the value on the Geofuelrequest record
						Update geofuelrequest
						set ef_companytype = @CompanyTypeValue
						from inserted
						where geofuelrequest.gf_lgh_number = inserted.gf_lgh_number
							and geofuelrequest.gf_requestid	= inserted.gf_requestid
							and geofuelrequest.gf_lgh_number = @lgh_number
							and geofuelrequest.gf_requestid = @requestid

						-- Get the next updated lgh_number
						select @requestid = isNull(min(gf_requestid),0) 
						from inserted
						where gf_requestid > @requestid
							and inserted.gf_status = 'RUN'

						select @lgh_number = gf_lgh_number from inserted where inserted.gf_requestid = @requestid
					end
			   end 							
		End
		
End


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_ignore_tractor] ON [dbo].[geofuelrequest] FOR UPDATE,INSERT AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* PTS 31689 - DJM - Create trigger to Mark Fuel Requests as COMPLETE when the tractor on the 
	request exists in the new table expfuel_ignore_tractorlist						*/
If (select count(*) from inserted) > 0
	IF exists (select 1 from generalinfo where gi_name = 'ExpFuelIgnoreTractor' and gi_string1 = 'Y')
		IF Update(gf_tractor) AND exists (select 1 from expfuel_ignore_tractorlist inner join inserted on expfuel_ignore_tractorlist.trc_number = inserted.gf_tractor)
		Begin
	
			UPDATE geofuelrequest
			set geofuelrequest.gf_status = 'CMP'
			from geofuelrequest g inner join inserted i on (i.gf_lgh_number = g.gf_lgh_number
				and g.gf_tractor = i.gf_tractor
				and g.gf_status <> 'CMP')
				inner join expfuel_ignore_tractorlist eit on eit.trc_number = g.gf_tractor
		End

	
GO
ALTER TABLE [dbo].[geofuelrequest] ADD CONSTRAINT [dk_gf_requestid] PRIMARY KEY CLUSTERED ([gf_requestid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_num] ON [dbo].[geofuelrequest] ([gf_lgh_number], [gf_status], [gf_tractor]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[geofuelrequest] TO [public]
GO
GRANT INSERT ON  [dbo].[geofuelrequest] TO [public]
GO
GRANT REFERENCES ON  [dbo].[geofuelrequest] TO [public]
GO
GRANT SELECT ON  [dbo].[geofuelrequest] TO [public]
GO
GRANT UPDATE ON  [dbo].[geofuelrequest] TO [public]
GO
