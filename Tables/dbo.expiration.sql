CREATE TABLE [dbo].[expiration]
(
[exp_idtype] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[exp_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_lastdate] [datetime] NULL,
[exp_expirationdate] [datetime] NULL,
[exp_routeto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_completed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_compldate] [datetime] NULL,
[timestamp] [timestamp] NULL,
[exp_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_creatdate] [datetime] NULL,
[exp_updateon] [datetime] NULL,
[exp_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_milestoexp] [int] NULL,
[exp_key] [int] NOT NULL IDENTITY(1, 1),
[exp_city] [int] NULL,
[mov_number] [int] NULL,
[exp_control_avl_date] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_control_avl_date] DEFAULT ('N'),
[skip_trigger] [tinyint] NULL,
[exp_auto_created] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__expiratio__exp_a__22F57144] DEFAULT ('N'),
[exp_source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_id] [int] NULL,
[carriercsalogdtl_id] [int] NULL,
[exp_duration] [int] NULL,
[exp_acceptable_start] [datetime] NULL,
[exp_acceptable_end] [datetime] NULL,
[exp_recurrence] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_expiration_exp_recurrence] DEFAULT ('ONCE'),
[trlStgID] [int] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__expiratio__INS_T__46331E9E] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE            trigger [dbo].[dt_expiration]
on [dbo].[expiration]
for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/*JLB PTS 32387 removed the creation of the delete trigger from the insert/update script no actual functionality changes*/


--PTS 26385 add the mov_number
declare @min int, @idtype varchar(6), @id varchar(13),
	@updatenote varchar(255), @keyvalue varchar(100),
	@mov_number int, @mov_deleted varchar(30),
	@skip_trigger int   -- PTS 41306 SGB 06/12/08 
	
	-- PTS 41306 SGB 06/12/08
		select @skip_trigger = count(*)
		from inserted where skip_trigger = 1
	-- PTS 41306 SGB 06/12/08

select @min = -1
SELECT @mov_deleted = 'No'

while (select count(*) 
	from deleted
	where exp_key > @min) > 0
begin
	select @min = min(exp_key) 
	from deleted
	where exp_key > @min

	--PTS 26385 add the mov_number
	select @idtype = exp_idtype, @id = exp_id, @mov_number = mov_number
	from deleted
	where exp_key = @min


	-- PTS 41306 SGB 06/12/08
		-- Only run Update Expiration when not skipping Trigger
		if @skip_trigger = 0 
			begin
				exec update_expiration @idtype, @id
			end
	-- PTS 41306 SGB 06/12/08

	--PTS 26385 delete corresponding move if one was attributed to this expiration
	IF @mov_number IS NOT NULL BEGIN
		IF NOT EXISTS(SELECT * FROM paydetail WHERE mov_number = @mov_number) BEGIN
			DELETE FROM stops
		 	WHERE mov_number = @mov_number
		
			SELECT @mov_deleted = 'Yes'

			EXECUTE update_move @mov_number
		END
		ELSE BEGIN
			SELECT @mov_deleted = 'No - Pay detail exists'
		END
	END
		
end

-----------------------------------------------
--	PCHIC	BEGIN CODE FOR PTS 14027
-----------------------------------------------
if exists (select * from generalinfo where gi_name = 'ExpirationAudit' and gi_string1 = 'Y')
begin

	--Insert expedite_audit row..
	--PTS 26385 add move auditing info
	--PTS 46566 JJF 20121009 - fix problem where null value could result, making note blank
	--select @updatenote = exp_idtype + '::' + exp_id + '::' + exp_code + '::Date::' + convert(varchar(20), exp_expirationdate, 120) + + '::End Date::' + convert(varchar(20), exp_compldate, 120) + '::Desc::' + IsNull(rtrim(exp_description), 'null') + '::Priority::' + exp_priority + '::Location::' + exp_routeto + '::Move Deleted::' + @mov_deleted + '::Move::' + convert(varchar(20), @mov_number) from deleted
	select @updatenote = isnull(exp_idtype, '') + '::' + isnull(exp_id, '') + '::' + isnull(exp_code, '(Null)') + '::Date::' + isnull(convert(varchar(20), exp_expirationdate, 120), '(Null)') + + '::End Date::' + isnull(convert(varchar(20), exp_compldate, 120), '(Null)') + '::Desc::' + IsNull(rtrim(exp_description), 'null') + '::Priority::' + isnull(exp_priority, '(Null)') + '::Location::' + isnull(exp_routeto, '(Null)') + '::Move Deleted::' + isnull(@mov_deleted, '(Null)') + '::Move::' + isnull(convert(varchar(20), @mov_number), '(Null)') from deleted
	select @keyvalue = convert(varchar(20), exp_key) from deleted
	--PTS 46566 JJF 20121009 - add exp_idtype/id
	select @idtype = exp_idtype, @id = exp_id from deleted
	exec insert_expedite_audit 'ExpirationDelete', @updatenote, @keyvalue, 'expiration', @idtype, @id
end
-----------------------------------------------
--	PCHIC	END CODE FOR PTS 14027
-----------------------------------------------
-- PTS 41306 SGB 06/12/08
if @skip_trigger > 0 
	begin
		UPDATE expiration  
	   	SET skip_trigger = 0
	     	FROM inserted
	    	WHERE (inserted.exp_key = expiration.exp_key)
	end
-- PTS 41306 SGB 06/12/08


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_ltl_expiration]
ON [dbo].[expiration]  
FOR INSERT
AS  

DECLARE @exp_idtype VARCHAR(3)
DECLARE @exp_code VARCHAR(6)
DECLARE @exp_id VARCHAR(13)
DECLARE @exp_routeto VARCHAR(12)
DECLARE @exp_completed CHAR(1)
DECLARE @exp_expirationdate DATETIME
DECLARE @count INT
DECLARE @trc_require_drvtrl CHAR(1)
DECLARE @unit_type VARCHAR(6)


  select @exp_idtype = exp_idtype, @exp_code = exp_code, @exp_id = exp_id, @exp_routeto = exp_routeto, @exp_completed = exp_completed,
  @exp_expirationdate = exp_expirationdate from inserted

  --// trailer position update
  IF (@exp_code = 'INS' AND @exp_completed = 'Y' AND @exp_idtype = 'TRL')
  BEGIN
    --// what if the exipment does not exist?
    SELECT @count = COUNT(*) from asset_ltl_info where unit_type = 'TRL' AND unit_id = @exp_id
    IF (@count = 1)
    BEGIN
      UPDATE asset_ltl_info SET cmp_id = @exp_routeto, status_ts = @exp_expirationdate WHERE unit_type = 'TRL' AND unit_id  = @exp_id
    END
    IF (@count = 0)
    BEGIN
      INSERT INTO asset_ltl_info (unit_type, unit_id, cmp_id, status_ts) VALUES ('TRL', @exp_id, @exp_routeto, @exp_expirationdate)
    END 
  END

  --// tractor or straight truck position update
  IF (@exp_code = 'INS' AND @exp_completed = 'Y' AND @exp_idtype = 'TRC')
  BEGIN
    SELECT @trc_require_drvtrl = trc_require_drvtrl FROM tractorprofile WHERE trc_number = @exp_id
    IF @trc_require_drvtrl=5
    BEGIN
      SET @unit_type = 'STR'
    END
    ELSE
    BEGIN
       SET @unit_type = 'TRC'
    END
    --// what if the exipment does not exist?
    SELECT @count = COUNT(*) from asset_ltl_info where unit_type = @unit_type AND unit_id = @exp_id
    IF (@count = 1)
    BEGIN
      UPDATE asset_ltl_info SET cmp_id = @exp_routeto, status_ts = @exp_expirationdate WHERE unit_type = @unit_type AND unit_id  = @exp_id
    END
    IF (@count = 0)
    BEGIN
      INSERT INTO asset_ltl_info (unit_type, unit_id, cmp_id, status_ts) VALUES (@unit_type, @exp_id, @exp_routeto, @exp_expirationdate)
    END 
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE              trigger [dbo].[iut_expiration]
on [dbo].[expiration]
for insert,update
as
/*
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 





declare @min int, @idtype varchar(6), @id varchar(13),
	@updatenote varchar(255),@keyvalue varchar(100),
	@delcount int,
	@skip_trigger int   -- PTS 41306 SGB 06/12/08 
	
	-- PTS 41306 SGB 06/12/08
	select @skip_trigger = count(*)
	from inserted where skip_trigger = 1
	-- PTS 41306 SGB 06/12/08
	
	

select @min = -1

while (select count(*) 
	from inserted
	where exp_key > @min) > 0
begin
	select @min = min(exp_key) 
	from inserted
	where exp_key > @min
	
	select @idtype = exp_idtype, @id = exp_id
	from inserted
	where exp_key = @min
	-- PTS 41306 SGB 06/12/08
	-- Only run Update Expiration when not skipping Trigger
	if @skip_trigger = 0 
		begin
			exec update_expiration @idtype, @id
		end
	-- PTS 41306 SGB 06/12/08
end

--PTS 55760 JJF 20110413
DECLARE	@WantsHomeExpirationSync char(1)
DECLARE	@drvexp_abbr varchar(6)
DECLARE	@trcexp_abbr varchar(6)

IF (UPDATE(exp_expirationdate) OR UPDATE(exp_compldate) OR UPDATE(exp_completed)) BEGIN

	SELECT	@WantsHomeExpirationSync = LEFT(gi_string1, 1),
			@drvexp_abbr = gi_string2,
			@trcexp_abbr = gi_string3
	FROM	generalinfo 
	WHERE	gi_name = 'WantsHomeExpirationSync' 

	IF	@WantsHomeExpirationSync = 'Y' BEGIN
		IF (UPDATE(exp_expirationdate) OR UPDATE(exp_compldate)) BEGIN			
		
			--update manpowerprofile with driver expiration changed dates
			IF EXISTS	(	SELECT	*
							FROM	manpowerprofile mpp 
									INNER JOIN inserted exp on (exp.exp_idtype = 'DRV' AND exp.exp_id = mpp.mpp_id)
							WHERE	exp.exp_id <> 'UNKNOWN'
									AND	(	isnull(mpp_want_home, '1900-01-01') <> exp.exp_expirationdate
											OR isnull(mpp_rtw_date, '1900-01-01') <> exp.exp_compldate
										)
									AND exp.exp_code = @drvexp_abbr
									AND exp.exp_completed = 'N'
									AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
															FROM	expiration expinner
															WHERE	expinner.exp_idtype = 'DRV'
																	AND expinner.exp_id = mpp.mpp_id
																	AND expinner.exp_code = @drvexp_abbr
																	AND expinner.exp_completed = 'N'
															ORDER BY expinner.exp_expirationdate
														) 
						) BEGIN

				UPDATE	manpowerprofile
				SET		mpp_want_home = exp.exp_expirationdate,
						mpp_rtw_date = exp.exp_compldate
				FROM	inserted exp
				WHERE	exp.exp_id <> 'UNKNOWN'
						AND exp.exp_idtype = 'DRV'
						AND exp.exp_id = manpowerprofile.mpp_id
						AND exp.exp_code = @drvexp_abbr
						AND exp.exp_completed = 'N'
						AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
												FROM	expiration expinner
												WHERE	expinner.exp_idtype = 'DRV'
														AND expinner.exp_id = manpowerprofile.mpp_id
														AND expinner.exp_code = @drvexp_abbr
														AND expinner.exp_completed = 'N'
												ORDER BY expinner.exp_expirationdate
											)
			END

			/*
			--update manpowerprofile with tractor expiration changed dates
			IF EXISTS	(	SELECT	*
							FROM	manpowerprofile mpp 
									INNER JOIN inserted exp on (exp.exp_idtype = 'TRC' AND exp.exp_id = mpp.mpp_tractornumber)
							WHERE	exp.exp_id <> 'UNKNOWN'
									AND	(	mpp_want_home <> exp.exp_expirationdate
											OR mpp_rtw_date <> exp.exp_compldate
										)
									AND exp.exp_code = @trcexp_abbr
									AND exp.exp_completed = 'N'
									AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
															FROM	expiration expinner
															WHERE	expinner.exp_idtype = 'TRC'
																	AND expinner.exp_id = mpp.mpp_tractornumber
																	AND expinner.exp_code = @trcexp_abbr
																	AND expinner.exp_completed = 'N'
															ORDER BY expinner.exp_expirationdate
														) 
						) BEGIN
				
				UPDATE	manpowerprofile
				SET		mpp_want_home = exp.exp_expirationdate,
						mpp_rtw_date = exp.exp_compldate
				FROM	inserted exp
				WHERE	exp.exp_id <> 'UNKNOWN'
						AND exp.exp_idtype = 'TRC'
						AND exp.exp_id = manpowerprofile.mpp_tractornumber
						AND exp.exp_code = @trcexp_abbr
						AND exp.exp_completed = 'N'
						AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
												FROM	expiration expinner
												WHERE	expinner.exp_idtype = 'TRC'
														AND expinner.exp_id = manpowerprofile.mpp_tractornumber
														AND expinner.exp_code = @trcexp_abbr
														AND expinner.exp_completed = 'N'
												ORDER BY expinner.exp_expirationdate
											)
			END
			*/
		END
	
		IF UPDATE(exp_completed) BEGIN
			--update manpowerprofile for next driver send home expiration, if any
			IF EXISTS	(	SELECT	*
							FROM	manpowerprofile mpp 
									INNER JOIN inserted exp_i on (exp_i.exp_idtype = 'DRV' AND exp_i.exp_id = mpp.mpp_id),
									expiration exp
							WHERE	exp_i.exp_id <> 'UNKNOWN'
									AND	(	isnull(mpp_want_home, '1900-01-01') <> exp.exp_expirationdate
											OR isnull(mpp_rtw_date, '1900-01-01') <> exp.exp_compldate
										)
									AND exp_i.exp_code = @drvexp_abbr
									AND exp_i.exp_completed = 'Y'
									AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
															FROM	expiration expinner
															WHERE	expinner.exp_idtype = 'DRV'
																	AND expinner.exp_id = exp_i.exp_id
																	AND expinner.exp_code = @drvexp_abbr
																	AND expinner.exp_completed = 'N'
															ORDER BY expinner.exp_expirationdate
														) 
						) BEGIN
			
				UPDATE	manpowerprofile
				SET		mpp_want_home = exp.exp_expirationdate,
						mpp_rtw_date = exp.exp_compldate
				FROM	inserted exp_i,
						expiration exp
				WHERE	exp_i.exp_id <> 'UNKNOWN'
						AND exp_i.exp_idtype = 'DRV'
						AND exp_i.exp_id = manpowerprofile.mpp_id
						AND exp_i.exp_code = @drvexp_abbr
						AND exp_i.exp_completed = 'Y'
						AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
														FROM	expiration expinner
														WHERE	expinner.exp_idtype = 'DRV'
																AND expinner.exp_id = exp_i.exp_id
																AND expinner.exp_code = @drvexp_abbr
																AND expinner.exp_completed = 'N'
														ORDER BY expinner.exp_expirationdate
											)
			END
			
			--update manpowerprofile for no expiration, if no more open driver expirations exist
			IF EXISTS	(	SELECT	*
							FROM	manpowerprofile mpp 
									INNER JOIN inserted exp_i on (exp_i.exp_idtype = 'DRV' AND exp_i.exp_id = mpp.mpp_id),
									expiration exp
							WHERE	exp_i.exp_id <> 'UNKNOWN'
									AND	(	isnull(mpp_want_home, '1900-01-01') IS NOT NULL
											OR isnull(mpp_rtw_date, '1900-01-01') IS NOT NULL
										)
									AND exp_i.exp_code = @drvexp_abbr
									AND exp_i.exp_completed = 'Y'
									AND NOT EXISTS (	SELECT	TOP 1 expinner.exp_key
														FROM	expiration expinner
														WHERE	expinner.exp_idtype = 'DRV'
																AND expinner.exp_id = exp_i.exp_id
																AND expinner.exp_code = @drvexp_abbr
																AND expinner.exp_completed = 'N'
													) 
						) BEGIN
			
				UPDATE	manpowerprofile
				SET		mpp_want_home = NULL,
						mpp_rtw_date = NULL
				FROM	inserted exp_i
				WHERE	exp_i.exp_id <> 'UNKNOWN'
						AND exp_i.exp_idtype = 'DRV'
						AND exp_i.exp_id = manpowerprofile.mpp_id
						AND exp_i.exp_code = @drvexp_abbr
						AND exp_i.exp_completed = 'Y'
						AND NOT EXISTS	(	SELECT	TOP 1 expinner.exp_key
													FROM	expiration expinner
													WHERE	expinner.exp_idtype = 'DRV'
															AND expinner.exp_id = exp_i.exp_id
															AND expinner.exp_code = @drvexp_abbr
															AND expinner.exp_completed = 'N'
										)
											
			END
			/*
			--update corresponding tractor expiration for next driver send home expiration, if any
			IF EXISTS	(	SELECT	*
							FROM	manpowerprofile mpp 
									INNER JOIN inserted exp_i on (exp_i.exp_idtype = 'DRV' AND exp_i.exp_id = mpp.mpp_id),
									expiration exp,
									expiration exp_trc
							WHERE	exp_i.exp_id <> 'UNKNOWN'
									AND	(	mpp.mpp_want_home <> exp.exp_expirationdate
											OR mpp.mpp_rtw_date <> exp.exp_compldate
										)
									AND exp_i.exp_code = @drvexp_abbr
									AND exp_i.exp_completed = 'Y'
									AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
															FROM	expiration expinner
															WHERE	expinner.exp_idtype = 'DRV'
																	AND expinner.exp_id = exp_i.exp_id
																	AND expinner.exp_code = @drvexp_abbr
																	AND expinner.exp_completed = 'N'
															ORDER BY expinner.exp_expirationdate
														) 
									AND exp_trc.exp_idtype = 'TRC'
									AND exp_trc.exp_id = mpp.mpp_tractornumber
									AND exp_trc.exp_completed = 'N'
									AND exp_trc.exp_key =	(	SELECT	TOP 1 expinner.exp_key
																FROM	expiration expinner
																WHERE	expinner.exp_idtype = 'TRC'
																		AND expinner.exp_id = exp_trc.exp_id
																		AND expinner.exp_code = @trcexp_abbr
																		AND expinner.exp_completed = 'N'
																ORDER BY expinner.exp_expirationdate
														) 

						) BEGIN
			
				UPDATE	expiration
				SET		exp_completed = 'Y'
				FROM	manpowerprofile mpp 
						INNER JOIN inserted exp_i on (exp_i.exp_idtype = 'DRV' AND exp_i.exp_id = mpp.mpp_id)
				WHERE	exp_i.exp_id <> 'UNKNOWN'
						AND	(	mpp.mpp_want_home <> expiration.exp_expirationdate
								OR mpp_rtw_date <> expiration.exp_compldate
							)
						AND exp_i.exp_code = @drvexp_abbr
						AND exp_i.exp_completed = 'Y'
						AND exp.exp_key =	(	SELECT	TOP 1 expinner.exp_key
												FROM	expiration expinner
												WHERE	expinner.exp_idtype = 'DRV'
														AND expinner.exp_id = exp_i.exp_id
														AND expinner.exp_code = @drvexp_abbr
														AND expinner.exp_completed = 'N'
												ORDER BY expinner.exp_expirationdate
											) 
						AND exp_trc.exp_idtype = 'TRC'
						AND exp_trc.exp_id = mpp.mpp_tractornumber
						AND exp_trc.exp_completed = 'N'
						AND exp_trc.exp_key =	(	SELECT	TOP 1 expinner.exp_key
													FROM	expiration expinner
													WHERE	expinner.exp_idtype = 'TRC'
															AND expinner.exp_id = exp_trc.exp_id
															AND expinner.exp_code = @trcexp_abbr
															AND expinner.exp_completed = 'N'
													ORDER BY expinner.exp_expirationdate
											) 
			END
			*/

		END
	END
END
--END PTS 55760 JJF 20110413

-----------------------------------------------
--	PCHIC	BEGIN CODE FOR PTS 14027
-----------------------------------------------
--
--	Check to see if this is an insert
--
if exists (select * from generalinfo where gi_name = 'ExpirationAudit' and gi_string1 = 'Y')
begin
	select @delcount = count(*) from deleted
	if @delcount = 0
	begin
		--Insert expedite_audit row..
		select @updatenote = exp_idtype + '::' + exp_id + '::' + exp_code + '::Exp Date::' + convert(varchar(20), exp_expirationdate, 120) + + '::End Date::' + convert(varchar(20), exp_compldate, 120) + '::Desc::' + IsNull(rtrim(exp_description), 'null') + '::Priority::' + exp_priority + '::Location::' + exp_routeto from inserted
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationInsert', @updatenote, @keyvalue, 'expiration', @idtype, @id
		return
	end
end

--
--	It's not an insert so it must be an update
--
if exists (select * from generalinfo where gi_name = 'ExpirationAudit' and gi_string1 = 'Y')
begin
     DECLARE @olddt datetime, @newdt datetime, @exptype varchar(3), @expid varchar(13),
	     @expcode varchar(6), @oldstring varchar(100), @newstring varchar(100),
	     @oldnumber integer, @newnumber integer
	select @exptype = exp_idtype from deleted
	select @expid = exp_id from deleted
	select @expcode = exp_code from deleted

	--
	-- code
	--
	if UPDATE(exp_code)
	begin
	   select @newstring = IsNull(rtrim(exp_code), 'null') from inserted
	   select @oldstring = IsNull(rtrim(exp_code), 'null') from deleted
           IF @newstring <> @oldstring
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Code::' + isnull(@oldstring, 'null') + ' -> ' + isnull(@newstring, 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	--  Expiration date
	--
	if UPDATE(exp_expirationdate)
	begin
	   select @newdt = exp_expirationdate from inserted
	   select @olddt = exp_expirationdate from deleted
           IF @olddt <> @newdt
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Expiration Date::' + isnull(convert(varchar(20), @olddt, 120), 'null') + ' -> ' + isnull(convert(varchar(20), @newdt, 120), 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	--  Completed date
	--
	if UPDATE(exp_compldate)
	begin
	   select @newdt = exp_compldate from inserted
	   select @olddt = exp_compldate from deleted
           IF @olddt <> @newdt
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'End Date::' + isnull(convert(varchar(20), @olddt, 120), 'null') + ' -> ' + isnull(convert(varchar(20), @newdt, 120), 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	--  Expiration last date
	--
	if UPDATE(exp_lastdate)
	begin
	   select @newdt = exp_lastdate from inserted
	   select @olddt = exp_lastdate from deleted
           IF @olddt <> @newdt
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Exp Last Date::' + isnull(convert(varchar(20), @olddt, 120), 'null') + ' -> ' + isnull(convert(varchar(20), @newdt, 120), 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	-- Description
	--
	if UPDATE(exp_description)
	begin
	   select @newstring = IsNull(rtrim(exp_description), 'null') from inserted
	   select @oldstring = IsNull(rtrim(exp_description), 'null') from deleted
           IF @newstring <> @oldstring
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Description::' + isnull(@oldstring, 'null') + ' -> ' + isnull(@newstring, 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	-- Location
	--
	if UPDATE(exp_routeto)
	begin
	   select @newstring = IsNull(rtrim(exp_routeto), 'null') from inserted
	   select @oldstring = IsNull(rtrim(exp_routeto), 'null') from deleted
           IF @newstring <> @oldstring
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Location::' + isnull(@oldstring, 'null') + ' -> ' + isnull(@newstring, 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	-- priority
	--
	if UPDATE(exp_priority)
	begin
	   select @newstring = IsNull(rtrim(exp_priority), 'null') from inserted
	   select @oldstring = IsNull(rtrim(exp_priority), 'null') from deleted
           IF @newstring <> @oldstring
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Priority::' + isnull(@oldstring, 'null') + ' -> ' + isnull(@newstring, 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	-- City
	--
	if UPDATE(exp_city)
	begin
	   select @newnumber = IsNull(exp_city, 0) from inserted
	   select @oldnumber = IsNull(exp_city, 0) from deleted
	   select @newstring = cty_name + ', ' + cty_state from city where cty_code = @newnumber
	   select @oldstring = cty_name + ', ' + cty_state from city where cty_code = @oldnumber
           IF @newnumber <> @oldnumber
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'City::' + @oldstring + ' -> ' + @newstring + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationUpdate', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end

	--
	--  Completed
	--
	if UPDATE(exp_completed)
	begin
	   select @newstring = IsNull(rtrim(exp_completed), 'null') from inserted
	   select @oldstring = IsNull(rtrim(exp_completed), 'null') from deleted
           IF @oldstring <> @newstring
	   begin
		select @updatenote = @exptype + '::' + @expid + '::' + @expcode + '::' +  'Completed::' + isnull(@oldstring, 'null') + ' -> ' + isnull(@newstring, 'null') + '::'
		select @keyvalue = convert(varchar(20), exp_key) from inserted
		select @updatenote = exp_idtype + '::' + exp_id + '::' + exp_code + '::Exp Date::' + convert(varchar(20), exp_expirationdate, 120) + + '::End Date::' + convert(varchar(20), exp_compldate, 120) + '::Desc::' + IsNull(rtrim(exp_description), 'null') + '::Priority::' + exp_priority + '::Location::' + exp_routeto from inserted
		--PTS 46566 JJF 20121009 - add exp_idtype/id
		select @idtype = exp_idtype, @id = exp_id from inserted
		exec insert_expedite_audit 'ExpirationComplete', @updatenote, @keyvalue, 'expiration', @idtype, @id
	   end
	end


end
-----------------------------------------------
--	PCHIC	END CODE FOR PTS 14027
-----------------------------------------------


--JLB PTS 32387
if update (exp_control_avl_date) and
   exists (select * 
             from deleted, expiration 
            where expiration.exp_control_avl_date = 'Y' 
              and deleted.exp_control_avl_date = 'N' 
              and deleted.exp_key = expiration.exp_key) and
   exists (select * from expiration where exp_control_avl_date = 'Y')
begin
	update expiration
       set expiration.exp_control_avl_date = 'N'
      from inserted
     where isnull(expiration.exp_control_avl_date,'N') <> 'N'
       and expiration.exp_key not in (select exp_key 
                                        from inserted 
                                       where exp_control_avl_date = 'Y')
       and expiration.exp_id in (select exp_id 
                                   from inserted)
       and expiration.exp_idtype in (select exp_idtype 
                                       from inserted)
end

--JLB PTS 39317
if update(exp_completed)
begin
	update expiration
	   set exp_control_avl_date = 'N'
	  from inserted
	 where inserted.exp_key = expiration.exp_key
	   and inserted.exp_control_avl_date = 'Y'
	   and inserted.exp_completed = 'Y'
	   and expiration.exp_completed = 'N'
	
	
	--PTS 64936 JJF 20130717
	INSERT INTO [expiration]	(
           [exp_idtype]
           ,[exp_id]
           ,[exp_code]
           ,[exp_lastdate]
           ,[exp_expirationdate]
           ,[exp_routeto]
           ,[exp_completed]
           ,[exp_priority]
           ,[exp_compldate]
           ,[exp_updateby]
           ,[exp_creatdate]
           ,[exp_updateon]
           ,[exp_description]
           ,[exp_milestoexp]
           ,[exp_city]
           ,[mov_number]
           ,[exp_control_avl_date]
           ,[skip_trigger]
           ,[exp_auto_created]
           ,[exp_source]
           ,[cai_id]
           ,[exp_recurrence]
	)
	
	SELECT exp.[exp_idtype]
		  ,exp.[exp_id]
		  ,exp.[exp_code]
		  ,'2049-12-31 23:59:59' as [exp_lastdate]
		  ,	CASE (	SELECT	TOP 1 lbl.label_extrastring1
					FROM	labelfile lbl
					WHERE	lbl.labeldefinition = 'ExpRecurInterval'
							AND lbl.abbr = exp.exp_recurrence
				)
				WHEN 'year' THEN DATEADD	(	year, 
												(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
													FROM	labelfile lbl
													WHERE	lbl.labeldefinition = 'ExpRecurInterval'
															AND lbl.abbr = exp.exp_recurrence
												)
												, exp.exp_expirationdate
											)
				WHEN 'quarter' THEN DATEADD	(	quarter, 
												(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
													FROM	labelfile lbl
													WHERE	lbl.labeldefinition = 'ExpRecurInterval'
															AND lbl.abbr = exp.exp_recurrence
												)
												, exp.exp_expirationdate
											)
				WHEN 'month' THEN DATEADD	(	month, 
												(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
													FROM	labelfile lbl
													WHERE	lbl.labeldefinition = 'ExpRecurInterval'
															AND lbl.abbr = exp.exp_recurrence
												)
												, exp.exp_expirationdate
											)
				WHEN 'day' THEN DATEADD		(	day, 
												(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
													FROM	labelfile lbl
													WHERE	lbl.labeldefinition = 'ExpRecurInterval'
															AND lbl.abbr = exp.exp_recurrence
												)
												, exp.exp_expirationdate
											)
				WHEN 'week' THEN DATEADD	(	week, 
												(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
													FROM	labelfile lbl
													WHERE	lbl.labeldefinition = 'ExpRecurInterval'
															AND lbl.abbr = exp.exp_recurrence
												)
												, exp.exp_expirationdate
											)
			END as [exp_expirationdate]
		  ,exp.[exp_routeto]
		  ,'N' as [exp_completed]
		  ,exp.[exp_priority]
		  ,	'2049-12-31 23:59:59' as [exp_compldate]
		  ,exp.[exp_updateby]
		  ,GETDATE() as [exp_creatdate]
		  ,GETDATE() as [exp_updateon]
		  ,exp.[exp_description]
		  ,exp.[exp_milestoexp]
		  ,exp.[exp_city]
		  ,NULL as [mov_number]
		  ,exp.[exp_control_avl_date]
		  ,0 as skip_trigger
		  ,exp.[exp_auto_created]
		  ,exp.[exp_source]
		  ,exp.[cai_id]
		  ,exp.[exp_recurrence]
	FROM	inserted exp
			left join deleted on exp.exp_key = deleted.exp_key
	WHERE	exp.exp_completed = 'Y' and ISNULL(deleted.exp_completed, 'N') = 'N'
			AND exp.exp_recurrence not in ('UNK', 'ONCE')
			AND NOT EXISTS	(	SELECT	*
								FROM	expiration expdup
								WHERE	expdup.exp_idtype = exp.exp_idtype
										AND	ISNULL(expdup.exp_id, '') = ISNULL(exp.exp_id, '')
										AND	ISNULL(expdup.exp_code, '') = ISNULL(exp.exp_code, '')
										AND	ISNULL(expdup.exp_expirationdate, '2049-12-31') = CASE (	SELECT	TOP 1 lbl.label_extrastring1
																										FROM	labelfile lbl
																										WHERE	lbl.labeldefinition = 'ExpRecurInterval'
																												AND lbl.abbr = exp.exp_recurrence	)
																									WHEN 'year' THEN DATEADD	(	year, 
																																	(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
																																		FROM	labelfile lbl
																																		WHERE	lbl.labeldefinition = 'ExpRecurInterval'
																																				AND lbl.abbr = exp.exp_recurrence
																																	)
																																	, exp.exp_expirationdate
																																)
																									WHEN 'quarter' THEN DATEADD	(	quarter, 
																																	(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
																																		FROM	labelfile lbl
																																		WHERE	lbl.labeldefinition = 'ExpRecurInterval'
																																				AND lbl.abbr = exp.exp_recurrence
																																	)
																																	, exp.exp_expirationdate
																																)
																									WHEN 'month' THEN DATEADD	(	month, 
																																	(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
																																		FROM	labelfile lbl
																																		WHERE	lbl.labeldefinition = 'ExpRecurInterval'
																																				AND lbl.abbr = exp.exp_recurrence
																																	)
																																	, exp.exp_expirationdate
																																)
																									WHEN 'day' THEN DATEADD		(	day, 
																																	(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
																																		FROM	labelfile lbl
																																		WHERE	lbl.labeldefinition = 'ExpRecurInterval'
																																				AND lbl.abbr = exp.exp_recurrence
																																	)
																																	, exp.exp_expirationdate
																																)
																									WHEN 'week' THEN DATEADD	(	week, 
																																	(	SELECT	TOP 1 CAST(lbl.label_extrastring2 as int)
																																		FROM	labelfile lbl
																																		WHERE	lbl.labeldefinition = 'ExpRecurInterval'
																																				AND lbl.abbr = exp.exp_recurrence
																																	)
																																	, exp.exp_expirationdate
																																)
																								END 
										AND ISNULL(expdup.exp_description, '') = ISNULL(exp.exp_description, '')
							
							)
	
	
end



-- PTS 41306 SGB 06/12/08
if @skip_trigger > 0 
	begin
		UPDATE expiration  
	   	SET skip_trigger = 0
	     	FROM inserted
	    	WHERE (inserted.exp_key = expiration.exp_key)
	end
-- PTS 41306 SGB 06/12/08


GO
ALTER TABLE [dbo].[expiration] ADD CONSTRAINT [uk_key] PRIMARY KEY CLUSTERED ([exp_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_expiration_cai_id] ON [dbo].[expiration] ([cai_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_expiration_carriercsalogdtl_id] ON [dbo].[expiration] ([carriercsalogdtl_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_exp_cavldt] ON [dbo].[expiration] ([exp_control_avl_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_expiration_gettariffkeys] ON [dbo].[expiration] ([exp_id], [exp_idtype], [exp_completed], [exp_priority], [exp_expirationdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_idtype] ON [dbo].[expiration] ([exp_idtype], [exp_id], [exp_code], [exp_expirationdate], [exp_description]) INCLUDE ([exp_completed], [exp_compldate]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [expiration_INS_TIMESTAMP] ON [dbo].[expiration] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Expiration_timestamp] ON [dbo].[expiration] ([timestamp]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[expiration] ADD CONSTRAINT [fk_expiration_carriercsalogdtl_id] FOREIGN KEY ([carriercsalogdtl_id]) REFERENCES [dbo].[CarrierCSALogDtl] ([id])
GO
ALTER TABLE [dbo].[expiration] ADD CONSTRAINT [FK_expiration_TrlStorage] FOREIGN KEY ([trlStgID]) REFERENCES [dbo].[TrlStorage] ([tstg_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[expiration] TO [public]
GO
GRANT INSERT ON  [dbo].[expiration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[expiration] TO [public]
GO
GRANT SELECT ON  [dbo].[expiration] TO [public]
GO
GRANT UPDATE ON  [dbo].[expiration] TO [public]
GO
