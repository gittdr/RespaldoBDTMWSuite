SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.post_mmessage_sp    Script Date: 6/1/99 11:54:38 AM ******/
/* ----------------------------------------------------------------------- M.R.H. ---
 Post_MMessage_sp - Save a mail message.
	Called from nvo_MailMessage@@PostMailMessage
//---------------------------------------------------------------------------------- */

CREATE PROC [dbo].[post_mmessage_sp] (	@v_Id int, @v_Sequence smallint, @v_RequestType varchar(6),	@v_Status char(1),
				@v_OriginatorType varchar(6), @v_OriginatorId varchar(20), @v_RecipientType varchar(6),
				@v_recipientid varchar(20), @v_RecipService varchar(6), @v_RecipAddress varchar(40), 
				@v_CreateDate_d datetime, @v_CreateTime_d datetime, @v_Priority varchar(6),
				@v_ReturnReceipt char(1), @v_Subject varchar(8), @v_PacketText varchar(254),
				@v_MacroNumber smallint, @v_Direction char(1), @v_OrigService varchar(6), @v_OrigAddress varchar(40))
AS

INSERT INTO MCMESSAGE (	MCM_ID, MCM_SEQUENCE, MCM_REQUESTTYPE, MCM_STATUS,
			MCM_ORIGINATORIDTYPE, MCM_ORIGINATORID, MCM_RECIPIENTIDTYPE,
			MCM_RECIPIENTID, MCM_RECIPSERVICE, MCM_RECIPADDRESS, 
			MCM_CREATEDATE, MCM_CREATETIME, MCM_PRIORITY, 
			MCM_RETURNRECEIPT, MCM_SUBJECT, MCM_MESSAGETEXT,
			MCM_MACRONUM, MCM_DIRECTION, MCM_ORISERVICE, MCM_ORIADDRESS)

	Values	      (	@v_Id, @v_Sequence, @v_RequestType,	@v_Status,
			@v_OriginatorType, @v_OriginatorId, @v_RecipientType,
			@v_recipientid, @v_RecipService, @v_RecipAddress, 
			@v_CreateDate_d, @v_CreateTime_d, @v_Priority, 
			@v_ReturnReceipt, @v_Subject, @v_PacketText,
			@v_MacroNumber, @v_Direction, @v_OrigService, @v_OrigAddress)


GO
GRANT EXECUTE ON  [dbo].[post_mmessage_sp] TO [public]
GO
