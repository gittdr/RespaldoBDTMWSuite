SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeMsgs] ( @SentAge int, @HistAge int)
AS
execute dbo.tm_PurgeMsgs2 @SentAge, @HistAge, -1
GO
