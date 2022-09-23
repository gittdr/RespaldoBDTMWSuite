SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_checkcall_subsistence_calculation]
		(	@Driver_ckc_asgnid varchar(13),			-- mpp_id is varchar (8), ckc_asgnid is varchar(13)
			@ckc_number int,
			@ckc_latitude float,								-- checkcall latitude
			@ckc_longitude float,								-- checkcall longitude
			@ckc_Date datetime,									-- checkcall date
			@ckc_asgntype varchar(6)
		)

AS

/* REVISION HISTORY:
 * 10/01/2012	 - PTS64388 - APC - created - to calculate subsistence qualification and set flags in dbo.checkcall and dbo.DriverSubsistence
 * 10/16/2013	 - PTS72807 - APC - call dbo.SubsistenceQualificationFilteredByAirmilesAndALKCLR
*/

DECLARE
	@mpp_subsistence_pay_radius float,
	@mpp_subsistence_eligible char(1),
	@subsistence_airmiles float,
	@subsistence_home_latitude float,
	@subsistence_home_longitude float,
	@subsistence_home_cmp_id varchar(8),
	@SubsistenceQualified CHAR(1)

IF NOT ISNULL((SELECT ckc_subsistence_qualified FROM dbo.checkcall WHERE ckc_number = @ckc_number), '') = '' BEGIN
	RETURN
END

IF (@Driver_ckc_asgnid <> '' AND @Driver_ckc_asgnid <> 'UNKNOWN' AND @ckc_asgntype = 'DRV')
	BEGIN 
		-- checkcall has a driver, get subsistence pay info From dbo.manpowerprofile

		SELECT  @mpp_subsistence_pay_radius = ISNULL(mpp_subsistence_pay_radius, -1),
				@mpp_subsistence_eligible = ISNULL(mpp_subsistence_eligible, 'N'),
				@subsistence_home_cmp_id = CASE WHEN ISNULL(mpp_subsistence_use_at_home, 'N') = 'N' 
					THEN mpp_subsistence_cmp_id 
					ELSE mpp_athome_terminal 
				END
			FROM dbo.manpowerprofile (NOLOCK) 
			WHERE mpp_id = cast(@Driver_ckc_asgnid as varchar(8));

		SELECT @subsistence_home_latitude = convert(decimal(12,6),cmp_latseconds)/3600, @subsistence_home_longitude = convert(decimal(12,6),cmp_longseconds)/3600
			FROM company (NOLOCK)
			WHERE cmp_id = @subsistence_home_cmp_id;

		IF UPPER(@mpp_subsistence_eligible) = 'Y'				--is eligible
		AND @mpp_subsistence_pay_radius <> -1					--values are not null ...
		AND @subsistence_home_latitude <> -1 
		AND @subsistence_home_longitude <> -1
			BEGIN

				--calc airdistance, if greater than mpp_subsistence_pay_radius, then update flag (dbo.checkcall.ckc_subsistence_qualified = 'Y')
				EXEC dbo.tmail_AirDistance
						@ckc_latitude, 
						@ckc_longitude, 
						@subsistence_home_latitude, 
						@subsistence_home_longitude, 
						@subsistence_airmiles OUT;
				
				EXEC dbo.SubsistenceQualificationFilteredByAirmilesAndALKCLR @mpp_subsistence_pay_radius, @subsistence_airmiles, @subsistence_home_latitude, @subsistence_home_longitude, @ckc_latitude, @ckc_longitude, @SubsistenceQualified OUT
				
				IF @SubsistenceQualified = 'Y'
					BEGIN						

						UPDATE checkcall 
							SET ckc_subsistence_qualified = 'Y' 
						WHERE ckc_number = @ckc_number;
						--if record exists in driversubsistence by drvr and date, update record, else insert new
						IF EXISTS (
							SELECT TOP 1 * 
							FROM dbo.DriverSubsistence (NOLOCK)
							WHERE dss_asgn_id = @Driver_ckc_asgnid AND DATEDIFF(D,dss_date,@ckc_date) = 0
						)
							UPDATE dbo.DriverSubsistence SET dss_eligible = 'Y', dss_status = 'Y', dss_comment = 'Driver Subsistence Eligible', dss_last_checkcall_Lookup_date = GETDATE() 
							WHERE dss_asgn_id = @Driver_ckc_asgnid AND DATEDIFF(D,dss_date,@ckc_date) = 0
						ELSE
							INSERT INTO dbo.DriverSubsistence 
							(
							dss_asgn_type, dss_asgn_id, dss_eligible, dss_status, dss_comment, dss_date, dss_last_checkcall_Lookup_date
							) 
							VALUES 
							(
							@ckc_asgntype, @Driver_ckc_asgnid, 'Y', 'Y', 'Driver Subsistence Eligible', @ckc_date, GETDATE()
							);
					END
				ELSE	-- keep record when driver subsistence not eligible
					BEGIN

						UPDATE checkcall 
							SET ckc_subsistence_qualified = 'N' 
						WHERE ckc_number = @ckc_number;
						--if record exists in driversubsistence by drvr and date, update record, else insert new
						IF NOT EXISTS (
							SELECT TOP 1 * 
							FROM dbo.DriverSubsistence (NOLOCK)
							WHERE dss_asgn_id = @Driver_ckc_asgnid AND DATEDIFF(D,dss_date,@ckc_date) = 0
						)
							INSERT INTO dbo.DriverSubsistence 
							(
							dss_asgn_type, dss_asgn_id, dss_eligible, dss_status, dss_comment, dss_date, dss_last_checkcall_Lookup_date
							) 
							VALUES 
							(
							@ckc_asgntype, @Driver_ckc_asgnid, 'N', 'N', 'Driver Not Subsistence Eligible', @ckc_date, GETDATE()
							);					
					END
			END
	END	
GO
GRANT EXECUTE ON  [dbo].[sp_checkcall_subsistence_calculation] TO [public]
GO
