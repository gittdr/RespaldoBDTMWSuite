SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[sp_SMTPMail]

	@SenderName varchar(100),
	@SenderAddress varchar(100),
	@RecipientName varchar(100),
	@RecipientAddress varchar(100),
	@Subject varchar(200),
	@Body varchar(8000)
	
	AS	
	
	SET nocount on

declare @oMail int --Object reference
	declare @resultcode int
	
	EXEC @resultcode = sp_OACreate 'SMTPsvg.Mailer', @oMail OUT
	
if @resultcode = 0
	BEGIN
		EXEC @resultcode = sp_OASetProperty @oMail, 'RemoteHost', 'smtp.tdr.com.mx'
		EXEC @resultcode = sp_OASetProperty @oMail, 'FromName', @SenderName
		EXEC @resultcode = sp_OASetProperty @oMail, 'FromAddress',  @SenderAddress
                EXEC @resultcode = sp_OASetProperty @oMail, 'SmtpUsername', 'emolvera@tdr.com.mx'
                EXEC @resultcode = sp_OASetProperty @oMail, 'SmtpPassword', 'eotdr'
                EXEC @resultcode = sp_OASetProperty @oMail, 'SmtpPort', 25



EXEC @resultcode = sp_OAMethod @oMail, 'AddRecipient', NULL, @RecipientName,  @RecipientAddress

		EXEC @resultcode = sp_OASetProperty @oMail, 'Subject', @Subject
		EXEC @resultcode = sp_OASetProperty @oMail, 'BodyText', @Body


		EXEC @resultcode = sp_OAMethod @oMail, 'SendMail', NULL
	EXEC sp_OADestroy @oMail
	END	
	

	SET nocount off


GO
