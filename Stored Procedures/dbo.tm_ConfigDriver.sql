SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[tm_ConfigDriver] @sNewName varchar(50),
				@sOldName varchar(50),
				@sEmailAltID varchar(50),
				@sPOP3Login varchar(60),				--pts 84270
				@sNewDispatchSystemID varchar(50),
				@sCurrentDispatchGroup varchar(50),
				@sCurrentTruck varchar(50),
				@iCurrentDriverDefaultLevel int,
				@iRetired int,
				@iUseToResolve INT,
				@bIgnoreAddressBy BIT = 0

AS
 EXEC dbo.tm_ConfigDriver2 @sNewName,
	@sOldName,
	@sEmailAltID,
	@sPOP3Login,
	@sNewDispatchSystemID,
	@sCurrentDispatchGroup,
	@sCurrentTruck,
	@iCurrentDriverDefaultLevel,
	@iRetired,
	@iUseToResolve,
	@bIgnoreAddressBy


   --- agregado por EMOLVERA PARA HACER EL SYNC A TOTAL MAIL al agregar un driver desde TMWSUITE
	exec tm_sync
GO
GRANT EXECUTE ON  [dbo].[tm_ConfigDriver] TO [public]
GO
