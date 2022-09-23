SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[AssignmentPermissionCheck_sp](
    @userid char(20),
    @assettype char(3),
    @assetid varchar(13)
)

AS BEGIN

	--Determines is permission has been granted for passed in user to utilize passed in asset.
	--Either the asset is associated with the user, or the user has a permission entry in the assignment permissions table
	
	DECLARE @return int
	DECLARE @user_can_set int
	--DECLARE @usr_booking_terminal varchar(12)
	--DECLARE @asset_brn_id varchar(12)
	DECLARE @asset_agency_id varchar(8)
	DECLARE @asset_agency_name varchar(40)
	DECLARE @asset_agency_phone varchar(20)
	DECLARE @asset_agency_email varchar(128)
	DECLARE @usr_revtype2 varchar(6)
	DECLARE @asset_revtype2 varchar(6)
	DECLARE @asset_idtype_name varchar(10)
	DECLARE	@permission_contact_return varchar(300)
	
	SELECT	@return = 1
	SELECT	@user_can_set = 1

	IF NOT EXISTS	(	SELECT	*
						FROM	generalinfo
						WHERE	gi_name = 'AssignmentPermissions'
								AND gi_string1 = 'Y'
					)  BEGIN
		GOTO RETURNRESULT
	END

	--Retrieve user's branch
	SELECT	--@usr_booking_terminal = tu.usr_booking_terminal,
			@usr_revtype2 = tu.usr_type2
	FROM	ttsusers tu
	WHERE	tu.usr_userid = @userid
	
	--PTS 65059 JJF 20120926
	IF (ISNULL(@usr_revtype2, 'UNK') = 'UNK') OR (@usr_revtype2 = '') BEGIN
		GOTO RETURNRESULT
	END
	--END PTS 65059 JJF 20120926
	--First check branch associated assets
	IF @assettype = 'TRC' BEGIN
		SELECT	--@asset_brn_id = trc.trc_branch,
				@asset_revtype2 = trc.trc_type2
		FROM	tractorprofile trc 
		WHERE	trc.trc_number = @assetid
	END
	ELSE IF @assettype = 'DRV' BEGIN
		SELECT	--@asset_brn_id = mpp.mpp_branch,
				@asset_revtype2 = mpp.mpp_type2
		FROM	manpowerprofile mpp 
		WHERE	mpp.mpp_id = @assetid
	END
	ELSE IF @assettype = 'TRL' BEGIN
		SELECT	--@asset_brn_id = trl.trl_branch,
				@asset_revtype2 = trl.trl_type2
		FROM	trailerprofile trl 
		WHERE	trl.trl_id = @assetid
	END
	ELSE IF @assettype = 'ORD' BEGIN
		SELECT	--@asset_brn_id = oh.ord_booked_revtype1,
				@asset_revtype2 = oh.ord_revtype2
		FROM	orderheader oh
		WHERE	oh.ord_number = @assetid
	END
	ELSE IF @assettype = 'MOV' BEGIN
		--any order associated with mov that matched branch for user passes test
		SELECT	TOP 1 --@asset_brn_id = oh.ord_booked_revtype1,
				@asset_revtype2 = oh.ord_revtype2
		FROM	orderheader oh
		WHERE	oh.mov_number = CONVERT(int, @assetid)
				AND oh.ord_revtype2 = @usr_revtype2
				--AND oh.ord_booked_revtype1 = @usr_booking_terminal

		--None match user's branch, report the branch for one of the orders on the movement
		--IF	@asset_brn_id IS NULL BEGIN
		IF	@asset_revtype2 IS NULL BEGIN
			SELECT	TOP 1 --@asset_brn_id = oh.ord_booked_revtype1,
					@asset_revtype2 = oh.ord_revtype2
			FROM	orderheader oh
			WHERE	oh.mov_number = CONVERT(int, @assetid)
		END
	END

	ELSE BEGIN
		--Do not track permission of other types, so return ok
		GOTO RETURNRESULT
	END

	
	--IF	(@usr_booking_terminal <> @asset_brn_id AND @asset_brn_id <> 'UNKNOWN' AND @assetid <> 'UNKNOWN' AND ISNULL(@assetid, '') <> '') BEGIN
	IF	(@usr_revtype2 <> @asset_revtype2 AND @asset_revtype2 <> 'UNK' AND @assetid <> 'UNKNOWN' AND ISNULL(@assetid, '') <> '') BEGIN
		SELECT	@return = 0
		SELECT	@user_can_set = 0
		
		--Get assets branch info
		--SELECT	@asset_brn_name = ISNULL(brn.brn_name, ''),
		--		@asset_brn_phone = ISNULL(brn.brn_phone, ''),
		--		@asset_brn_email = ISNULL(brn.brn_email, '')
		--FROM	branch brn
		--WHERE	brn.brn_id = @asset_brn_id
		
		SELECT TOP 1	@asset_agency_id = ISNULL(tpr.tpr_id, ''),
				@asset_agency_name = ISNULL(tpr.tpr_name, ''),
				@asset_agency_phone = ISNULL('(' + LEFT(tpr.tpr_primaryphone, 3) + ') ' + SUBSTRING(tpr.tpr_primaryphone, 4, 3) + '-' + SUBSTRING(tpr.tpr_primaryphone, 7, 4), ''),
				@asset_agency_email = ISNULL(tpr.tpr_email, '')
		FROM	thirdpartyprofile tpr
		WHERE	tpr.tpr_revtype2 = @asset_revtype2
				AND tpr.tpr_type = 'TPR1'
				AND ISNULL(tpr.tpr_active, 'N') = 'Y'
				
		
		SELECT @asset_idtype_name =	CASE	@assettype
										WHEN 'DRV' THEN 'Driver'
										WHEN 'TRC' THEN 'Tractor'
										WHEN 'TRL' THEN 'Trailer'
										WHEN 'ORD' THEN 'Order'
										WHEN 'MOV' THEN 'Movement'
										ELSE '(Unexpected Asset Type)'
									END
		SELECT @permission_contact_return = 'You do not have permission to work with ' + @asset_idtype_name + ': ' + @assetid + char(13) + char(13) 
		IF LEN(@asset_agency_id) > 0 BEGIN
			 SELECT @permission_contact_return = @permission_contact_return + 'Contact: ' +  @asset_agency_id + ' - ' + @asset_agency_name
		END
		ELSE BEGIN
			SELECT @permission_contact_return = @permission_contact_return + 'No agency contact found in Third Party corresponding to RevType2 = ' + @asset_revtype2
		END
		IF LEN(@asset_agency_phone) > 0 BEGIN
			SELECT @permission_contact_return = @permission_contact_return + char(13) + 'Phone: ' + @asset_agency_phone
		END
		IF LEN(@asset_agency_email) > 0 BEGIN
			SELECT @permission_contact_return = @permission_contact_return + char(13) + 'Email: ' + @asset_agency_email
		END
	END
	
	--IF @asset_brn_id = 'UNKNOWN' BEGIN
	IF @asset_revtype2 = 'UNKNOWN' BEGIN
		SELECT	@user_can_set = 0
	END
	
	--If association not found, check for a permission entry.
	IF ISNULL(@return, 0) = 0 BEGIN
		IF @assettype <> 'MOV' BEGIN
			SELECT	@return = COUNT(*)
			FROM	AssignmentPermissons ap
			WHERE	ap.ap_userid = @userid
					AND ap.ap_assettype = @assettype
					AND ap.ap_assetid = @assetid
					AND ap.ap_active = 'Y'
					AND ap.ap_expiration >= GETDATE()
		END
		ELSE IF @assettype = 'MOV' BEGIN
			SELECT	@return = COUNT(*)
			FROM	AssignmentPermissons ap
			WHERE	ap.ap_userid = @userid
					AND ap.ap_assettype = 'ORD'
					AND ap.ap_assetid IN	(	SELECT	CONVERT(varchar(13), oh.ord_number)
												FROM	orderheader oh 
												WHERE	oh.mov_number = CONVERT(int, @assetid)
											)
					AND ap.ap_active = 'Y'
					AND ap.ap_expiration >= GETDATE()
		END
	
	END
	
	
	RETURNRESULT:
	
	SELECT	@return AS return_value, 
			@user_can_set AS user_can_set,
			--ISNULL(@asset_brn_id, '') AS asset_brn_id, 
			ISNULL(@asset_agency_id, '') AS asset_contact_id, 
			ISNULL(@asset_agency_name, '') AS asset_contact_name, 
			ISNULL(@asset_agency_phone, '') AS asset_contact_phone, 
			ISNULL(@asset_agency_email, '') AS asset_contact_email,
			ISNULL(@permission_contact_return, '') AS asset_contact_message
END
GO
GRANT EXECUTE ON  [dbo].[AssignmentPermissionCheck_sp] TO [public]
GO
