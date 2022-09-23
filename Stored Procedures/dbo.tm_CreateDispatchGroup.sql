SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CreateDispatchGroup] @sDispatchGroupName varchar(30), @sOldDispatchGroupName varchar(30), @iRetired int, @flags int 

As

/**
 * 
 * NAME:
 
 * dbo.CreateDispatchGroup
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Create new and updates Dispatch groups in TotalMail from information entered into TMWSuite. 
 
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * @sDispatchGroupName varchar(30)-  passed in with one name at a time from suite with udpated name or create a new group
 * @sOldDispatchGroupName varchar (30)  - variable of current group name used to update all old dispatch groups with changes
 * @sRetired varchar(1)- update for for active or retired groups
 * @flags int - not used, place holder for future use
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 2011		- Orginal Created by DG
 * 02/01/2012 - PTS59916- JC - enhanced
 *
 **/



DECLARE @iOldSN Int,
    @iNewDispatchGroupSN int,
	@sParentFolderName varchar(50),
	@iInBoxSN int,
	@iDispatchGroupAddressType int,
	@sT_1 Varchar(200),
	@debug int,
	@iOldDisName varchar(30)
	
Set @debug = 0 --0 = OFF / 1 = On,  Used to work out issues for future use


-------------Data Valadation-------------------------------------------------------
	IF EXISTS (SELECT NAME FROM tblDispatchGroup WHERE Name = @sDispatchGroupName )
	BEGIN
		--JJF 20120907 - this is ok, just return
		--RAISERROR('Dispatch Group %s already exists.', 16, 1, @sDispatchGroupName)
		RETURN
	END

IF @sOldDispatchGroupName <> ''
	BEGIN	
		IF NOT EXISTS (SELECT NULL FROM tblDispatchGroup WHERE Name = @sOldDispatchGroupName)
		BEGIN
			--JJF 20120907 - this is ok, just add the group
			SELECT @sOldDispatchGroupName = ''
			--RAISERROR('Old Dispatch Group %s does not match any current group name.', 16, 1, @sOldDispatchGroupName)
			RETURN
		END
	END
--End Valadation

---------Update Old Groups-------------------------------------------------------
-- uPDATE OLD GROUP NAMES WHEN A NEW GROUP NAME IS NULL
IF @sOldDispatchGroupName = '' 
	BEGIN
--A NEW GROUP WILL BE CREATED WHEN NO OLD NAME IS PASSED IN
--------------------------------------------------------------------------------------------------------	
	--DEBUG, CHECKING VARIABLES 
	IF @debug > 0 
		SELECT 'Creating Dispatch Group', @sDispatchGroupName DISPATCHNEW, @sOldDispatchGroupName OLDNAME, @iRetired RETIRED
-------------------------------------------------------------------------------------------------------		
		SELECT @sParentFolderName = 'Group: ~1''s Inbox'
		SELECT @sT_1 = @sParentFolderName
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		EXEC dbo.tm_sprint @sT_1 out, @sDispatchGroupName, '', '', '', '', '', '', '', '', ''
		SELECT  @sParentFolderName = @sT_1
		
		--Insert the new folders for the Dispatch Group Inbox
		INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (NULL, @sParentFolderName, NULL, 0)
		Select @iInBoxSN = @@IDENTITY
		
		--Insert Dispatch Group Profile record
		INSERT INTO tblDispatchGroup 
			(Name, Inbox, DispSysDispatcherID, Retired) 
			VALUES (RTRIM(@sDispatchGroupName), @iInBoxSN, NULL, 0)
		
		Select @iNewDispatchGroupSN = @@IDENTITY

		--find the tblAddresses SN for Dispatch Group type 
		SELECT @iDispatchGroupAddressType = SN FROM tblAddressTypes WHERE AddressType = 'G'
		
		--Insert the Address record
		INSERT INTO tblAddresses 
			(AddressBookSN, AddressType, Inbox, Outbox, AddressName, UseInResolve) 
			VALUES (NULL, @iDispatchGroupAddressType, @iInBoxSN, 0, RTRIM(@sDispatchGroupName), 0)
----------------------------------------------------------------------------------------------------------	
	--DEBUG, CHECKING VARIABLES 
	IF @debug > 0 
		SELECT 'GROUP CREATED', * FROM tblDispatchGroup WHERE Name = @sDispatchGroupName
-------------------------------------------------------------------------------------------------------	
	END
	else
--Make changes to current group
	BEGIN
----------------------------------------------------------------------------------------------------------	
	--DEBUG, CHECKING VARIABLES 
	IF @debug > 0 
		SELECT 'Updating Dispatch Group', @sDispatchGroupName DISPATCHNEW, @sOldDispatchGroupName OLDNAME, @iRetired RETIRED
-------------------------------------------------------------------------------------------------------			 		
		IF ISNULL(@sDispatchGroupName, '') = ''
		Begin
			UPDATE TBLDISPATCHGROUP  --update current distpatch group with new name or retire/unretire group
			SET Retired = @iRetired
			WHERE Name = @sOldDispatchGroupName
		End
		Else
		Begin
			UPDATE TBLDISPATCHGROUP  --update current distpatch group with new name or retire/unretire group
			SET Name = @sDispatchGroupName, Retired = @iRetired
			WHERE Name = @sOldDispatchGroupName
		End
----------------------------------------------------------------------------------------------------------	
	--DEBUG, CHECKING VARIABLES 
	IF @debug > 0 
		SELECT 'GROUP UPDATED', * FROM tblDispatchGroup WHERE Name = @sDispatchGroupName
-------------------------------------------------------------------------------------------------------					
			
	END 
GO
GRANT EXECUTE ON  [dbo].[tm_CreateDispatchGroup] TO [public]
GO
