SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DriverWantsHomeExpirationSync_sp] @mpp_id VARCHAR(8), @trc_number VARCHAR(8), @mpp_want_home datetime, @mpp_rtw_date datetime
AS BEGIN
	
	--PTS 55760 JJF 20110413
	DECLARE	@mpp_want_homeExpirationSync char(1)
	DECLARE	@drvexp_abbr varchar(6)
	DECLARE	@trcexp_abbr varchar(6)
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output


	SELECT	@mpp_want_homeExpirationSync = LEFT(gi_string1, 1),
			@drvexp_abbr = gi_string2,
			@trcexp_abbr = gi_string3
	FROM	generalinfo 
	WHERE	gi_name = 'WantsHomeExpirationSync' 
			
	IF	@mpp_want_homeExpirationSync = 'Y' AND ISNULL(@mpp_id, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		IF ISNULL(@trc_number, 'UNKNOWN') = 'UNKNOWN' BEGIN
			--Default to tractor as specified in driver's associated tractor
			SELECT @trc_number = mpp.mpp_tractornumber
			FROM manpowerprofile mpp
			WHERE mpp_id = @mpp_id
		END
		
		--Find earliest wants home expiration for driver that's not marked done.  Update it.  If not found, insert it.
		IF NOT ISNULL(@drvexp_abbr, '') = '' BEGIN
			UPDATE	expiration
			SET		exp_expirationdate = @mpp_want_home,
					exp_compldate = @mpp_rtw_date,
					exp_source = 'WantsHomeExpirationSync-update'
			FROM	manpowerprofile mpp
			WHERE	mpp.mpp_id = @mpp_id
					AND exp_idtype = 'DRV'
					AND exp_id = mpp.mpp_id
					AND exp_code = @drvexp_abbr
					AND exp_completed = 'N'
					AND exp_key =	(	SELECT	TOP 1 expinner.exp_key
										FROM	expiration expinner
										WHERE	expinner.exp_idtype = 'DRV'
												AND expinner.exp_id = mpp.mpp_id
												AND expinner.exp_code = @drvexp_abbr
												AND expinner.exp_completed = 'N'
										ORDER BY expinner.exp_expirationdate
									)


			INSERT INTO expiration
				(	exp_idtype,
					exp_id,
					exp_code,
					exp_expirationdate,
					exp_completed,
					exp_priority,
					exp_compldate,
					exp_description,
					exp_city,
					exp_auto_created,
					exp_source,
					exp_lastdate,
					exp_routeto,
					exp_creatdate,
					exp_updateby,
					exp_updateon
				)
			SELECT	'DRV',
					mpp.mpp_id,
					@drvexp_abbr,
					@mpp_want_home,
					'N',
					9,
					@mpp_rtw_date,
					'Domicile is: ' + (	SELECT	ISNULL(lbl.name, '')
										FROM	labelfile lbl
										WHERE	lbl.labeldefinition = 'Domicile'
												AND lbl.abbr = mpp.mpp_domicile)
									+ ', Terminal is: ' 
									+ (	SELECT	ISNULL(lbl.name, '')
										FROM	labelfile lbl
										WHERE	lbl.labeldefinition = 'Terminal'
												AND lbl.abbr = mpp.mpp_terminal),
					mpp.mpp_city,
					'Y',
					'WantsHomeExpirationSync-insert',
					getdate(),
					'UNKNOWN',
					getdate(),
					@tmwuser,
					getdate()
			FROM	manpowerprofile mpp
			WHERE	mpp.mpp_id = @mpp_id
					AND NOT EXISTS	(	SELECT	*
										FROM	expiration expinner
										WHERE	exp_idtype = 'DRV'
												AND exp_id = mpp.mpp_id
												AND exp_code = @drvexp_abbr
												AND exp_completed = 'N'
									)



		END				
		--Find earliest wants home expiration for tractor that's not marked done.  Update it.  If not found, insert it.
		IF NOT ISNULL(@trcexp_abbr, '') = '' AND ISNULL(@trc_number, 'UNKNOWN') <> 'UNKNOWN' BEGIN
			UPDATE	expiration
			SET		exp_expirationdate = @mpp_want_home,
					exp_compldate = @mpp_rtw_date,
					exp_source = 'WantsHomeExpirationSync-update'
			FROM	manpowerprofile mpp
			WHERE	mpp.mpp_id = @mpp_id
					AND exp_idtype = 'TRC'
					AND exp_id = @trc_number
					AND exp_code = @trcexp_abbr
					AND exp_completed = 'N'
					AND exp_key =	(	SELECT	TOP 1 expinner.exp_key
										FROM	expiration expinner
										WHERE	expinner.exp_idtype = 'TRC'
												AND expinner.exp_id = @trc_number
												AND expinner.exp_code = @trcexp_abbr
												AND expinner.exp_completed = 'N'
									)


			INSERT INTO expiration
				(	exp_idtype,
					exp_id,
					exp_code,
					exp_expirationdate,
					exp_completed,
					exp_priority,
					exp_compldate,
					exp_description,
					exp_city,
					exp_auto_created,
					exp_source,
					exp_lastdate,
					exp_routeto,
					exp_creatdate,
					exp_updateby,
					exp_updateon
				)
			SELECT	'TRC',
					@trc_number,
					@trcexp_abbr,
					@mpp_want_home,
					'N',
					9,
					@mpp_rtw_date,
					'Domicile is: ' + (	SELECT	ISNULL(lbl.name, '')
										FROM	labelfile lbl
										WHERE	lbl.labeldefinition = 'Domicile'
												AND lbl.abbr = mpp.mpp_domicile)
									+ ', Terminal is: ' 
									+ (	SELECT	ISNULL(lbl.name, '')
										FROM	labelfile lbl
										WHERE	lbl.labeldefinition = 'Terminal'
												AND lbl.abbr = mpp.mpp_terminal),
					mpp.mpp_city,
					'Y',
					'WantsHomeExpirationSync-insert',
					getdate(),
					'UNKNOWN',
					getdate(),
					@tmwuser,
					getdate()
			FROM	manpowerprofile mpp
			WHERE	mpp.mpp_id = @mpp_id
					AND NOT EXISTS	(	SELECT	*
										FROM	expiration expinner
										WHERE	exp_idtype = 'TRC'
												--PTS 58788 JJF 20110902
												--AND exp_id = mpp.mpp_tractornumber
												AND exp_id = @trc_number
												--END PTS 58788 JJF 20110902
												AND exp_code = @trcexp_abbr
												AND exp_completed = 'N'
									)
		END				
	END
END


GO
GRANT EXECUTE ON  [dbo].[DriverWantsHomeExpirationSync_sp] TO [public]
GO
