SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[tm_ConfigTruck] @sNewName varchar(50),
				@sOldName varchar(50),
				@sNewDispatchSystemID varchar(50),
				@sCurrentDispatchGroup varchar(50),
				@sDefaultCabUnit varchar(50),
				@sDefaultDriver varchar(50),
				@iRetired int,
				@iUseToResolve int,
				@bIgnoreAddressBy BIT = 0

AS
EXEC dbo.tm_ConfigTruck2 @sNewName,
	@sOldName,
	@sNewDispatchSystemID,
	@sCurrentDispatchGroup,
	@sDefaultCabUnit,
	@sDefaultDriver,
	@iRetired,
	@iUseToResolve,
	0,
	@bIgnoreAddressBy


   --- agregado por EMOLVERA PARA HACER EL SYNC A TOTAL MAIL al agregar un tractor desde TMWSUITE
	exec tm_sync
GO
GRANT EXECUTE ON  [dbo].[tm_ConfigTruck] TO [public]
GO
