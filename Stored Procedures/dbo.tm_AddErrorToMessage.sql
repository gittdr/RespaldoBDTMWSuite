SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_AddErrorToMessage]	@MessageSN int,
						@VBErrNumber int = 0,
						@FailureMessage varchar(8000),
						@FailureSource varchar(254),
						@Flags int=0
AS
-- This routine attaches the specified error to the specified message (and any others that share its Error List).  Note that if the target
--	message does not already have an error list, then one will be created.  Currently flags is not used.
SET NOCOUNT ON

Declare @OriginalErrListID int, @ErrListID int, @ErrDate as datetime

SELECT @OriginalErrListID = convert(int, value) from tblmsgproperties (NOLOCK) where msgsn = @MessageSN and propsn = 6

SELECT @ErrListID = @OriginalErrListID, @ErrDate = GETDATE()

if @ErrListID is null EXEC tm_GetRSIdentity 'NxtErrLst', 1, 0, @ErrListID out

insert into tblErrorData (VBError, Description, Source, Timestamp, ErrListID)
VALUES (@VBErrNumber, @FailureMessage, @FailureSource, @ErrDate, @ErrListID)

if @ErrListID <> ISNULL(@OriginalErrListID, -1)
	insert into tblMsgProperties (MsgSN, PropSN, Value)
	VALUES (@MessageSN, 6, @ErrListID)
GO
GRANT EXECUTE ON  [dbo].[tm_AddErrorToMessage] TO [public]
GO
