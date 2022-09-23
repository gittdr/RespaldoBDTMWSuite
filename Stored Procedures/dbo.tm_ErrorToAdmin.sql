SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ErrorToAdmin]
(
	@Source varchar(254),
	@MessagePart varchar(8000),
	@Subject varchar(254) = null,
	@ErrorTxt1 varchar(8000) = null,
	@ErrNumber1 int = -2147221504,
	@ErrorTxt2 varchar(8000) = null,
	@ErrNumber2 int = -2147221504,
	@ErrorTxt3 varchar(8000) = null,
	@ErrNumber3 int = -2147221504,
	@ErrorTxt4 varchar(8000) = null,
	@ErrNumber4 int = -2147221504,
	@ErrorTxt5 varchar(8000) = null,
	@ErrNumber5 int = -2147221504,	
	@MsgCreated int = -1 OUTPUT
)
/**
 * 
 * NAME:
 * dbo.tm_ErrorToAdmin
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Sends errors to totalmail Admin inbox
 * 
 *
 *
 * Change Log: 
 * rwolfe init 2014/04/02
 * rwolfe 2015/10/20 reworked to give more info, and rename for general purpose use
 *
 **/
 AS 
	SET NOCOUNT ON
	-- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION IS UNACCEPTABLE BECAUSE OF tm_AddErrorToMessage

	if @Subject is Null
		set @Subject = 'An Error Occured in ' + @Source

	INSERT INTO tblMessages
		(Type, Status, Priority, FromType, DTSent, DTReceived, Folder,
				Contents, FromName, Subject, DeliverTo)
		SELECT 1, ISNULL(5, tblMsgStatus.SN), 1, 1 , GETDATE(), GETDATE(), InBox, @MessagePart, @Source, @Subject, 'Admin'
		FROM tblMsgStatus (NOLOCK), tblServer (NOLOCK)
		WHERE Code = 'ACK' AND ServerCode = 'A'
	
	SET @MsgCreated = SCOPE_IDENTITY();
	
	if(Not @ErrorTxt1 is null)
		EXEC tm_AddErrorToMessage
			@MessageSN = @MsgCreated, -- int
			@VBErrNumber = @ErrNumber1, -- int
			@FailureMessage = @ErrorTxt1, -- varchar(8000)
			@FailureSource = @Source, -- varchar(254)
			@Flags = 0; -- int

	if(Not @ErrorTxt2 is null)    
		EXEC tm_AddErrorToMessage
			@MessageSN = @MsgCreated, -- int
			@VBErrNumber = @ErrNumber2, -- int
			@FailureMessage = @ErrorTxt2, -- varchar(8000)
			@FailureSource = @Source, -- varchar(254)
			@Flags = 0; -- int

	if(Not @ErrorTxt3 is null)
		EXEC tm_AddErrorToMessage
			@MessageSN = @MsgCreated, -- int
			@VBErrNumber = @ErrNumber3, -- int
			@FailureMessage = @ErrorTxt3, -- varchar(8000)
			@FailureSource = @Source, -- varchar(254)
			@Flags = 0; -- int

	if(Not @ErrorTxt4 is null)
		EXEC tm_AddErrorToMessage
			@MessageSN = @MsgCreated, -- int
			@VBErrNumber = @ErrNumber4, -- int
			@FailureMessage = @ErrorTxt4, -- varchar(8000)
			@FailureSource = @Source, -- varchar(254)
			@Flags = 0; -- int

	if(Not @ErrorTxt5 is null)
		EXEC tm_AddErrorToMessage
			@MessageSN = @MsgCreated, -- int
			@VBErrNumber = @ErrNumber5, -- int
			@FailureMessage = @ErrorTxt5, -- varchar(8000)
			@FailureSource = @Source, -- varchar(254)
			@Flags = 0; -- int
GO
GRANT EXECUTE ON  [dbo].[tm_ErrorToAdmin] TO [public]
GO
