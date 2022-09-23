SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/* 
	Adds a settings_item record, if it does not already exist.  Adds a settings_section record, if needed.
	Returns the ID of the new or existing settings item.
*/

CREATE PROCEDURE [dbo].[core_settingItemCreate]
	@setting_sourceName varchar(255), /* required; must be TTS50, LOCAL, GENERALINFO or EVOLUTION */
	@setting_sectionName varchar(255),
	@setting_itemName varchar(255),
	@setting_description text
AS


/* Prep and check args. */

SET @setting_sourceName = isnull(@setting_sourceName, '')
SET @setting_sectionName = isnull(@setting_sectionName, '')
SET @setting_itemName = isnull(@setting_itemName, '')

IF @setting_sourceName = ''
	BEGIN
	RAISERROR('Setting source name not supplied.', 16, 1)
	RETURN
	END

IF @setting_sectionName = ''
	BEGIN
	RAISERROR('Setting section name not supplied.', 16, 1)
	RETURN
	END
	
IF @setting_itemName = ''
	BEGIN
	RAISERROR('Setting item name not supplied.', 16, 1)
	RETURN
	END

DECLARE @sourceID int
SET @sourceID = 0
DECLARE @sectionID int
SET @sectionID = 0
DECLARE @itemID int
SET @itemID = 0


/* Get source record. */

SELECT @sourceID = ID from settings_source WHERE [Name] = @setting_sourceName

IF @sourceID = 0
	BEGIN
	RAISERROR('Setting source name (%s) not found.', 16, 1, @setting_sourceName)
	RETURN
	END


/* Get section record. */

SELECT @sectionID = ID FROM settings_section
	WHERE [Name] = @setting_sectionName AND [SourceID] = @sourceID


/* If item exists, return. */

IF @sectionID <> 0
	IF EXISTS (
		SELECT ID from settings_item
			WHERE [Name] = @setting_itemName AND SectionID = @sectionID
		)
		RETURN

		
/* Set vars for inserting records. */

DECLARE @now AS datetime
SET @now = getdate()


/* Insert section record if not found. */

IF @sectionID = 0
	BEGIN
	INSERT settings_section ([SourceID], [Name], CreatedOn, UpdatedOn)
		VALUES (@sourceID, @setting_sectionName, @now, @now)
	SET @sectionID = SCOPE_IDENTITY()
	END


/* Insert item record. */

INSERT settings_item ([SectionID], [Name], [CreatedOn], [UpdatedOn], [Description], [AliasOfItemID])
	VALUES (@sectionID, @setting_itemName, @now, @now, @setting_description, 0)

SET @itemID = SCOPE_IDENTITY()

update settings_item SET [AliasOfItemID] = @itemID
	WHERE ID = @itemID
	

/* Return ID and update info of settings item. */
	
SELECT
	ID as setting_ID,
	CreatedBy AS setting_createdBy, /* set by trigger */
	CreatedOn AS setting_createdOn,
	UpdatedBy AS setting_UpdatedBy, /* set by trigger */
	UpdatedOn AS setting_UpdatedOn
	FROM [settings_item]
	WHERE ID = @itemID

GO
GRANT EXECUTE ON  [dbo].[core_settingItemCreate] TO [public]
GO
