SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_PurgeScratchPad] (@UpdateAge int)
AS
    --- Purges entries from tblScratch pad.  Set @UpdateAge to number of days to keep an entry that has no activity.
	DELETE tblScratchPad WHERE DATEDIFF(d, DateUpd, GETDATE()) > @UpdateAge
GO
