SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[tm_ConfigMCUnit] @sNewName varchar(60),
				@sOldName varchar(60),
				@sUnitType varchar(20),
				@sCurrentDispatchGroup varchar(30),
				@sCurrentTruck varchar(15),
				@iCurrentMCUnitDefaultLevel int,
				@iRetired int,
				@iUseToResolve int,
				@bIgnoreAddressBy BIT = 0

AS
EXEC dbo.tm_ConfigMCUnit2 @sNewName,
	@sOldName,
	@sUnitType,
	@sCurrentDispatchGroup,
	@sCurrentTruck,
	@iCurrentMCUnitDefaultLevel,
	@iRetired,
	@iUseToResolve,
	0,
	@bIgnoreAddressBy

GO
GRANT EXECUTE ON  [dbo].[tm_ConfigMCUnit] TO [public]
GO
