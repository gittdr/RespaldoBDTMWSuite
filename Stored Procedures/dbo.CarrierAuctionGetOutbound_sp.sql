SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[CarrierAuctionGetOutbound_sp]
AS

	DECLARE @Resultset TABLE(
		cb_id					int			NULL,
		ca_id					int			NULL,
		ord_hdrnumber			int			NULL,
		lgh_number				int			NULL,
		ca_type					varchar(6)	NULL,
		cb_sent_email_template	int			NULL,
		MessageType				varchar(6)	NULL
	)

 --Get oubound solicitations take it now/sequential bid requests
 INSERT INTO @Resultset(
  cb_id,
  ca_id,
  ord_hdrnumber,
  lgh_number,
  ca_type,
  cb_sent_email_template,
  MessageType
 )
  SELECT cb.cb_id, cb.ca_id, ca.ord_hdrnumber, ca.lgh_number, ca.ca_type, cb_sent_email_template, 'SND' as MessageType
 FROM carrierbids cb inner join carrierauctions ca on (cb.ca_id = ca.ca_id)
 WHERE (cb.cb_sent_status = 'Send') 
   AND (ca.ca_end_date >= getdate())
   AND (ca.ca_send_via = 'EMAIL')
   AND ((ca.ca_send_sequentially = 'N' 
   AND ca.ca_status IN ('EXPORT')) 
    OR (ca_send_sequentially = 'Y' AND ca.ca_status <> ('CAN')
     AND cb_sent_sequence <= (SELECT min(cb_sent_sequence ) 
           FROM carrierbids cbinner
           WHERE cbinner.ca_id = ca.ca_id
             AND cbinner.cb_sent_status = 'Send'
             AND cbinner.cb_sent_expires > 
             (SELECT isnull(max(cb_sent_expires), '01-01-1950')
                     FROM carrierbids cbinner2
                     WHERE cbinner2.ca_id = ca.ca_id
                       AND cbinner2.cb_sent_status = 'Sent')
             AND cbinner.cb_sent_expires < getdate() )))


	--Get any bids that need cancel notices sent
	INSERT INTO @Resultset(
		cb_id,
		ca_id,
		ord_hdrnumber,
		lgh_number,
		ca_type,
		cb_sent_email_template,
		MessageType
	)
	SELECT	cb.cb_id, cb.ca_id, ca.ord_hdrnumber, ca.lgh_number, ca.ca_type, 0, 'CAN' as MessageType
	FROM	carrierbids cb inner join carrierauctions ca on (cb.ca_id = ca.ca_id)
	WHERE	(cb.cb_sent_status = 'Sent') 
			AND (ca_send_via = 'EMAIL')
			AND (ca.ca_status = 'CAN')
			AND (isnull(cb.cb_cancel_message_status, 'Send') = 'Send')
			

	--Get any bids that need award notices sent
	INSERT INTO @Resultset(
		cb_id,
		ca_id,
		ord_hdrnumber,
		lgh_number,
		ca_type,
		cb_sent_email_template,
		MessageType
	)
	SELECT	cb.cb_id, cb.ca_id, ca.ord_hdrnumber, ca.lgh_number, ca.ca_type, 0, 'AWD' as MessageType
	FROM	carrierbids cb inner join carrierauctions ca on (cb.ca_id = ca.ca_id)
	WHERE	(cb.cb_sent_status = 'Sent') 
			AND (ca_send_via = 'EMAIL')
			AND (ca.ca_status = 'AWARD')
			AND (cb.cb_award_status = 'ACCEPT')
			AND (isnull(cb.cb_award_message_status, 'Send') = 'Send')

	--Get any bids that need denial notices sent
	INSERT INTO @Resultset(
		cb_id,
		ca_id,
		ord_hdrnumber,
		lgh_number,
		ca_type,
		cb_sent_email_template,
		MessageType
	)
	SELECT	cb.cb_id, cb.ca_id, ca.ord_hdrnumber, ca.lgh_number, ca.ca_type, 0, 'DNY' as MessageType
	FROM	carrierbids cb inner join carrierauctions ca on (cb.ca_id = ca.ca_id)
	WHERE	(cb.cb_sent_status = 'Sent') 
			AND (ca_send_via = 'EMAIL')
			AND (ca.ca_status = 'AWARD')
			AND (cb.cb_award_status <> 'ACCEPT')
			AND (isnull(cb.cb_deny_message_status, 'Send') = 'Send')
			
	SELECT
		cb_id,
		ca_id,
		ord_hdrnumber,
		lgh_number,
		ca_type,
		cb_sent_email_template,
		MessageType
	FROM @Resultset

GO
GRANT EXECUTE ON  [dbo].[CarrierAuctionGetOutbound_sp] TO [public]
GO
