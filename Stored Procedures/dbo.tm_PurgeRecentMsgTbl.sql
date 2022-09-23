SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tm_PurgeRecentMsgTbl    Script Date: 2/15/01 10:30:13 PM ******/
CREATE PROCEDURE [dbo].[tm_PurgeRecentMsgTbl]
as

SET NOCOUNT ON 

DECLARE @temp varchar (10), @Days int

SELECT @temp = KeyCode 
FROM tblRS (NOLOCK)
WHERE KeyCode = 'RecentDays'
IF NOT ISNULL(@temp,'') > ''
	INSERT INTO tblRS (KeyCode, Text, Description, Static) VALUES ('RecentDays', '0', 'Recent Days Messages to be keep in the tblfullmsg table', 1)

SELECT @Days = Text 
from tblRS (nolock) WHERE KeyCode = 'RecentDays'

if @Days > 0 
DELETE FROM tblfullmsg WHERE MsgDate < DateAdd(d, -@Days, GetDate())
GO
