SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ops_asyncmessage_sp] @ord_hdrnumber int,
									 @move_number	int,
									 @lgh_number	int,
									 @asset			varchar(100),
									 @assettype		int,
									 @formid		int,
									 @filterdata	varchar(50),
									 @subject		varchar(50),
									 @msgtype		varchar(30),
									 @msgkey		varchar(4000),
									 @delay			int,
									 @msg_id_return	int OUTPUT

AS
/**
 * 
 * NAME:
 * dbo.ops_asyncmessage_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure inserts a header (and possibly details) for an async message to TotalMail
 * 
 * NOTE: This proc was a copy of TMWSuite's asyncmessage_sp proc that was made because Operations
 *		  needed to widen the @asset parameter to the database column width (varchar (100)) so
 *		  that we can pass a semi-colon delimited string of addresses to send a message to.
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber 	int,
 *       This paramater indicates the orderheader number in which the message is being assigned to
 * 002 - @move_number	int,
 *       This paramater indicates the move number in which the message is being assigned to
 * 003 - @lgh_number		int,
 *       This paramater indicates the leg number in which the message is being assigned to
 * 004 - @asset			varchar(100),
 *       This paramater indicates the asset id in which the message is being assigned to
 * 005 - @assettype		int,
 *       This paramater indicates the assignment type (value list controled by TotalMail Group)
 * 006 - @formid			int,
 *       This paramater indicates the TotalMail Form to generate (if applicable)
 * 007 - @filterdata		varchar(50),
 * 008 - @subject		varchar(50),
 *       This paramater indicates the subject of the message
 * 009 - @msgtype		varchar(30),
 * 010 - @msgkey		varchar(4000),
 *       This paramater indicates the text of the message (from SQL it can be 4000 chars from powerbuilder it will be 254 max)
 * 011 - @delay			int,
 * 012 - @msg_id_return	int OUTPUT
 *       This RETURN paramater indicates the identity of the header so that it can be used to insert the details
 *
 * REFERENCES: 
 * 001 � asyncmessage_short_sp (this is the standard TMWSuite proc) This sp is used to insert the text 254 characters at a time to generate the long msgkey
 * 
 * REVISION HISTORY:
 * 09/20/2005.01 � PTS28341 - Jason Bauwin � Allow long Text Messages upto 4000 characters
 * 11/29/2005.02 - PTS #30741 - Ron Eyink - removed call to scope_identity since it is SQL 2000 only
 * 01/29/2013.01 - DPETE PTS 66458 message sequence is not incrmented when a log message is parsed
 * 03/03/2014.01 - PTS75251 - MIZ - Make copy of TMWSuite proc for Operations so that we can widen the @asset parameter from varchar (12) to varchar(100).
 **/

DECLARE @tmwuser varchar (255),
		@msg_254 varchar(254),
		@msg_id int,
		@msg_seq int

EXEC dbo.gettmwuser @tmwuser output

INSERT INTO TMSQLMessage (msg_date, 
						  msg_FormID, 
						  msg_To, 
						  msg_ToType, 
						  msg_FilterData,
						  msg_FilterDataDupWaitSeconds, 
						  msg_From, 
						  msg_FromType, 
						  msg_Subject)
VALUES (getdate(), 
		@formid, 
		@asset, 
		@assettype,
		@filterdata,
		@delay, 
		@tmwuser,
		0, 
		@subject)
			
SELECT @msg_id = @@IDENTITY, @msg_seq = 1
SELECT @msg_id_return = @msg_id

IF ISNULL(@msgkey,'') <> 'skip_data_insert'
--this is passed in from powerbuilder if the text is > 254 so that the proc will skip the data inserts and powerbuilder will add them
  BEGIN
	IF LEN(@msgkey) <= 254
	  BEGIN
		EXEC dbo.asyncmessage_short_sp @msg_id, @msg_seq, @msgtype, @msgkey
	  END
	ELSE
	  BEGIN
		WHILE(LEN(@msgkey) > 0)
		  BEGIN 
			SELECT @msg_254 = left(@msgkey,254), @msg_seq = @msg_seq
  			SELECT @msgkey = SUBSTRING(@msgkey, 255, 8000)
			EXEC dbo.asyncmessage_short_sp @msg_id, @msg_seq, @msgtype, @msg_254

			SET @msg_seq = @msg_seq + 1
		  END 
	  END   
  END
GO
GRANT EXECUTE ON  [dbo].[ops_asyncmessage_sp] TO [public]
GO
