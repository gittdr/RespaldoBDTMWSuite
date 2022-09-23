SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_sk_SyncDispatchRelationship] 
							@sDispatchGroupName varchar (30), 
							@sResourceType varchar(30), 
							@sResourceID varchar(30), 
							@sFlags int 

As

/**
 * 
 * NAME: 
 * dbo.tm_sk_SyncDispatchRelationship
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Assignes or updates resources to correct dispatch group in TM confuguariton based based on FileMaintence Profile.
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 *  @sDispatchGroupName - Name of current group in configuration which is to be linked to a resource 
 *  @sResourceType - 'DRV', TRC', 'TRL'
 *  @sResourceID  - Id of the specific resource
 *  @sFlags int - not used
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 02/20/2012 - PTS59916 - JC - enhanced
 * 08/20/2013 - PTS64925 - APC - set default values so validation hits on null
 * 08/23/2013 - PTS64925 - APC - dont exit proc if dispatch group is null, to support earlier versions of tmwsuite
 **/



DECLARE @debug int,
		@spDrvSN int,
		@spTrcSN int,
		@spDisSN int
		
Set @debug = 0 --0 = OFF / 1 = On,  Used to work out issues for future use
set @spDrvSN = 0
Set @spTrcSN = 0
Set	@spDisSN = 0


-------------Data Valadation-------------------------------------------------------

--Return if no dispatch group specified.  No work to do
IF ISNULL(@sDispatchGroupName, '') = '' BEGIN
	RETURN
END

--Does dispatch exist 	
SELECT @spDisSN = ISNULL(SN, 0)
	FROM tblDispatchGroup (nolock) 
	WHERE Name = @sDispatchGroupName
IF @spDisSN = 0
BEGIN
	RAISERROR('tm_sk_SyncDispatchRelationship, Dispatch group: %s not found.', 16, 1, @sDispatchGroupName)
	RETURN
END	

	--Does drv exist in configuration
IF ISNULL(@sResourceType, '') = 'DRV'
BEGIN
	SELECT @spDrvSN = ISNULL(SN , 0)
		FROM tblDrivers (nolock) 
		WHERE DispSysDriverID = @sResourceID
	IF @spDrvSN = 0
	BEGIN
		RAISERROR('tm_sk_SyncDispatchRelationship, Driver: %s not found.', 16, 1, @sResourceID)
		RETURN
	END
END	
	--Does trc exist in configuration
IF ISNULL(@sResourceType, '') = 'TRC' 
BEGIN	
	SELECT @spTrcSN = ISNULL(SN, 0) 
		FROM tblTrucks (nolock) 
		WHERE DispSysTruckID = @sResourceID
	IF @spTrcSN = 0
	BEGIN
		RAISERROR('tm_sk_SyncDispatchRelationship, Truck: %s not found.', 16, 1, @sResourceID)
		RETURN
	END
END	
	--Does trc exist in configuration
IF ISNULL(@sResourceType, '') = 'TRL' 
BEGIN	
	SELECT @spTrcSN = ISNULL(SN, 0) 
		FROM tblTrucks (nolock) 
		WHERE DispSysTruckID = @sResourceID
	IF @spTrcSN = 0
	BEGIN
		RAISERROR('tm_sk_SyncDispatchRelationship, Trailer: %s not found.', 16, 1, @sResourceID)
		RETURN
	END
END	


---------------Set the Relationship of the 
IF @spTrcSN > 0
	begin
		UPDATE tblTrucks
			SET CurrentDispatcher = @spDisSN
			WHERE SN = @spTrcSN
	end
ELSE IF @spDrvSN > 0
	begin

		UPDATE tblDrivers
			SET CurrentDispatcher = @spDisSN
			WHERE SN = @spDrvSN
	end
	
	
----------------------------------------------------------------------------------------------------------	
	--DEBUG, CHECKING VARIABLES 
	IF @debug > 0 
		Begin
			IF  ISNULL(@sResourceType, '') = 'DRV'
				SELECT * from tblDrivers where Name  = @sResourceID 
			IF  ISNULL(@sResourceType, '') = 'TRC'
				SELECT * from tblTrucks where TruckName = @sResourceID 
		End	
-------------------------------------------------------------------------------------------------------	

--End Dispatch Update
	




GO
GRANT EXECUTE ON  [dbo].[tm_sk_SyncDispatchRelationship] TO [public]
GO
