SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_sk_SyncNonMemberRelationship] 
		@sOldMemberGroupName VARCHAR(30),
		@sMemberGroupName VARCHAR(30), 
		@sDispatchGroupName varchar (30), 
		@sResourceType varchar(30), 
		@sResourceID varchar(30), 
		@iFlags int -- 1 = Ignore missing mobilecomm unit

As

/**
 * 
 * NAME:
 * dbo.tm_sk_SyncNonMemberRelationship
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Assigns or updates resources to correct Member group in TM configuration based on File Maintenance Profile.
 *
 * RETURNS:
 * none
 *
 * PARAMETERS:
 *  @sMemberGroupName - Name of current group in configuration which is to be linked to a resource 
 *  @sResourceType 		- 'DRV', TRC', 'TRL'
 *  @sResourceID  		- Id of the specific resource
 *  @iFlags int 		- 1 = Ignore missing mobilecomm unit
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 08/12/2013 - PTS64925 - APC - Added
 * 08/27/2013 - PTS64925 - APC - Exit proc if (defaultcabunit FROM tbltrucks) is null; Change error/validation message so it is more informational to the user.  
 * 09/03/2013 - PTS71916 - APC - Exit proc instead of displaying validation msg that truck doesn't have mobilecomm unit assigned to it in totalmail.
 **/


DECLARE @debug int,
		@MemberGroup_DefaultCabUnit int,
		@OldMemberGroup_DefaultCabUnit int,
		@spTrcSN int,
		@spDisSN INT,
		@DefaultCabUnit INT

DECLARE @msg varchar(255)

Set @debug = 0 --0 = OFF / 1 = On,  Used to work out issues for future use


-------------Data Validation-------------------------------------------------------
	--Does dispatch exist 	
	--SELECT @spDisSN = SN
	--	FROM tblDispatchGroup (nolock) 
	--	WHERE Name = @sDispatchGroupName
	--IF @spDisSN = 0 BEGIN
	--	RAISERROR('tm_sk_SyncNonMemberRelationship, Dispatch group: %s not found.', 16, 1, @sDispatchGroupName)
	--	RETURN
	--END	 

	--Does trc exist in configuration
	IF ISNULL(@sResourceType, '') = 'TRC' BEGIN	
		SELECT @spTrcSN = ISNULL(SN, 0), @DefaultCabUnit = ISNULL(DefaultCabUnit, 0)
			FROM tblTrucks (nolock) 
			WHERE DispSysTruckID = @sResourceID
		IF @spTrcSN = 0 BEGIN
			RAISERROR('tm_sk_SyncNonMemberRelationship, Truck: %s not found.', 16, 1, @sResourceID)
			RETURN
		END		
		IF @DefaultCabUnit = 0 BEGIN
			IF (@iFlags & 1 = 0) BEGIN
				RETURN		-- exit instead of throwing error, per QA. Re:Validation message crashes VDispatch if you assign a truck that does not have a mobilecomm unit set up in TotalMail				
				--SELECT @msg = REPLICATE(CHAR(13) + CHAR(10), 4) + 'TRUCK: %s NEEDS A MOBILE COMM UNIT ADDED TO IT IN TOTALMAIL CONFIGURATION.' + REPLICATE(CHAR(13) + CHAR(10), 2) + 'Press OK to continue.' + REPLICATE(CHAR(13) + CHAR(10), 4)
				--RAISERROR(@msg, 15, 1, @sResourceID)
			END
			RETURN		
		END	
	END	
		--Does trc exist in configuration
	IF ISNULL(@sResourceType, '') = 'TRL' BEGIN	
		SELECT @spTrcSN = ISNULL(SN, 0), @DefaultCabUnit = ISNULL(DefaultCabUnit, 0) 
			FROM tblTrucks (nolock) 
			WHERE TruckName = @sResourceID --DispSysTruckID = @sResourceID
		IF @spTrcSN = 0 BEGIN
			RAISERROR('tm_sk_SyncNonMemberRelationship, Trailer: %s not found.', 16, 1, @sResourceID)
			RETURN
		END
		IF @DefaultCabUnit = 0 BEGIN
			IF (@iFlags & 1 = 1) BEGIN
				RAISERROR('tm_sk_SyncNonMemberRelationship, Trailer: %s does not have a mobilecomm unit associated with it.', 15, 1, @sResourceID)
			END
			RETURN		
		END		
	END	

	--Is this a valid member group?
	IF ISNULL(@sMemberGroupName, '') = ''
	BEGIN
		--RAISERROR('tm_sk_SyncNonMemberRelationship, invalid NonMobileComm MemberGroup Name.', 16, 1, @sResourceID)
		RETURN
	END

	-- fetch var values
	SELECT @MemberGroup_DefaultCabUnit = defaultcabunit FROM tbltrucks WHERE TruckName = @sMemberGroupName AND GroupFlag = 2
	
	IF ISNULL(@MemberGroup_DefaultCabUnit, -1) = -1 BEGIN	
		RETURN
	END		
	
	-- if this truck doesn't already exist in this membergroup, insert it.
	IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblCabUnitGroups WHERE MemberCabSN = @DefaultCabUnit AND GroupCabSN = @MemberGroup_DefaultCabUnit)
	BEGIN				
		INSERT INTO dbo.tblCabUnitGroups
				( GroupCabSN ,
				  MemberCabSN ,
				  Changed ,
				  Deleted
				)
		VALUES  ( @MemberGroup_DefaultCabUnit , -- GroupCabSN - int
				  @DefaultCabUnit , -- MemberCabSN - int
				  0 , -- Changed - int
				  0  -- Deleted - int
				)
		IF ISNULL(@sOldMemberGroupName,'') = '' BEGIN
			SELECT  @OldMemberGroup_DefaultCabUnit = defaultcabunit FROM tbltrucks WHERE TruckName = @sOldMemberGroupName AND GroupFlag = 2
			DELETE FROM dbo.tblCabUnitGroups WHERE MemberCabSN = @DefaultCabUnit AND GroupCabSN = @OldMemberGroup_DefaultCabUnit				
		END						
	END
	
----------------------------------------------------------------------------------------------------------	
	--DEBUG, CHECKING VARIABLES 
	IF @debug > 0 
		Begin
			--IF  ISNULL(@sResourceType, '') = 'DRV'
			--	SELECT * from tblDrivers where Name  = @sResourceID 
			IF  ISNULL(@sResourceType, '') = 'TRC'
				SELECT * from tblTrucks where TruckName = @sResourceID 
		End	
-------------------------------------------------------------------------------------------------------	

--End Dispatch Update
	




GO
GRANT EXECUTE ON  [dbo].[tm_sk_SyncNonMemberRelationship] TO [public]
GO
