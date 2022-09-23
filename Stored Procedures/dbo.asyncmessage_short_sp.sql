SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[asyncmessage_short_sp] (@msg_id int, 
                            @msg_seq int, 
                            @msg_type varchar(30),       
                            @msg_254 varchar(254))
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
 * This procedure inserts a detail record for a given header for an async message to TotalMail
 * 
 *
 * PARAMETERS:
 * 001 - @msg_id	int,
 *       This paramater indicates header number of the message the detail record belongs to
 * 002 - @msg_seq	int,
 *       This is the sequence number used to gather the details back into a single string
 * 003 - @msg_type		varchar(30),
 * 004 - @msg_254		varchar(254),
 *       This paramater is a 254 block of characters that is some portion of the main string
 *
 * REFERENCES: 
 * Calledby001    ? asyncmessage_sp
 * 
 * REVISION HISTORY:
 * 09/20/2005.01 ? PTS28341 - Jason Bauwin ? Inital Release
 *
 **/
		INSERT INTO TMSQLMessageData (msg_ID,  msd_Seq, msd_FieldName, msd_FieldValue)
           VALUES (@msg_id, @msg_seq , @msg_type, @msg_254)
GO
GRANT EXECUTE ON  [dbo].[asyncmessage_short_sp] TO [public]
GO
