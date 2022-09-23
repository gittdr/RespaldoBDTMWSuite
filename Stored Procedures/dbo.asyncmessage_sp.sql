SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[asyncmessage_sp]
	@ord_hdrnumber 	int,
	@move_number	int,
	@lgh_number		int,
	@asset			varchar(12),
	@assettype		int,
	@formid			int,
	@filterdata		varchar(50),
	@subject		varchar(50),
	@msgtype		varchar(30),
	@msgkey			varchar(4000),
	@delay			int,
    @msg_id_return	int OUTPUT

AS
/**
 * 
 * NAME:
 * dbo.asyncmessage_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure inserts a header (and possibly details) for an async message to TotalMail
 * 
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber 	int,
 *       This paramater indicates the orderheader number in which the message is being assigned to
 * 002 - @move_number	int,
 *       This paramater indicates the move number in which the message is being assigned to
 * 003 - @lgh_number		int,
 *       This paramater indicates the leg number in which the message is being assigned to
 * 004 - @asset			varchar(12),
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
 * Calls001    ? asyncmessage_short_sp This sp is used to insert the text 254 characters at a time to generate the long msgkey
 * 
 * REVISION HISTORY:
 * 09/20/2005.01 ? PTS28341 - Jason Bauwin ? Allow long Text Messages upto 4000 characters
 *
 * 11/29/2005.02 - PTS #30741 - Ron Eyink - removed call to scope_identity since it is SQL 2000 only
 * 1/29/13 DPETE PTS 66458 message sequence is not incrmented when a log message is parsed
 **/


BEGIN
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255),
	@msg_254 varchar(254),
	@msg_id int,
	@msg_seq int

    exec gettmwuser @tmwuser output

	INSERT INTO TMSQLMessage 
		(msg_date, 
		msg_FormID, 
		msg_To, 
		msg_ToType, 
		msg_FilterData,
		msg_FilterDataDupWaitSeconds, 
		msg_From, 
		msg_FromType, 
		msg_Subject)
	values (getdate(), 
		@formid, 
		@asset, 
		@assettype,
		@filterdata,
		@delay, 
		@tmwuser,
		0, 
		@subject)
			
	-- RE - PTS #30741
	--select @msg_id = scope_identity(), @msg_seq = 1
	select @msg_id = @@IDENTITY, @msg_seq = 1
    select @msg_id_return = @msg_id

    if isnull(@msgkey,'') <> 'skip_data_insert'
    --this is passed in from powerbuilder if the text is > 254 so that the proc will skip the data inserts and powerbuilder will add them
    begin
   	  if len(@msgkey) <= 254
   	  begin
        exec asyncmessage_short_sp @msg_id, @msg_seq, @msgtype, @msgkey
   	  end
      else
        begin
          while( len(@msgkey)>0 )
          begin 
            select @msg_254 = left(@msgkey,254), @msg_seq = @msg_seq
      		select @msgkey = substring(@msgkey,255,8000)
            exec asyncmessage_short_sp @msg_id, @msg_seq, @msgtype, @msg_254
            select @msg_seq = @msg_seq + 1
          end 
        end   
      end
    end
 
GO
GRANT EXECUTE ON  [dbo].[asyncmessage_sp] TO [public]
GO
