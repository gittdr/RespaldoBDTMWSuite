SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_AdminMessage](@FromName varchar(50), @FromType int, @Subject varchar(255), @MsgText varchar(4000), @lStatus int = NULL)

AS
INSERT INTO tblMessages
    (Type, Status, Priority, FromType, DTSent, DTReceived, Folder,
         Contents, FromName, Subject, DeliverTo)
    SELECT 1, ISNULL(@lStatus, tblMsgStatus.SN), 1, @FromType, GETDATE(), GETDATE(), InBox, @MsgText, @FromName, @Subject, 'Admin'
	FROM tblMsgStatus (NOLOCK), tblServer (NOLOCK)
	WHERE Code = 'ACK' AND ServerCode = 'A'
GO
GRANT EXECUTE ON  [dbo].[tm_AdminMessage] TO [public]
GO
