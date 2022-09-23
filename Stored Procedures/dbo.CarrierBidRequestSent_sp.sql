SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CarrierBidRequestSent_sp]
(
	@cb_id int
)
AS

SET NOCOUNT OFF;

--Set sending message to sent
UPDATE	carrierbids
SET		cb_sent_status = 'Sent',
		cb_sent_date = getdate()
FROM	carrierbids inner join carrierauctions ca on (carrierbids.ca_id = ca.ca_id)
WHERE  (cb_id = @cb_id)
		and (cb_sent_status = 'Send')
		and (ca.ca_status in ('EXPORT', 'XPRTED'))

--Set cancel sent
UPDATE	carrierbids
SET		cb_cancel_message_status = 'Sent'
FROM	carrierbids inner join carrierauctions ca on (carrierbids.ca_id = ca.ca_id)
WHERE  (cb_id = @cb_id)
		and (isnull(cb_cancel_message_status, 'Send') = 'Send')
		and (cb_sent_status = 'Sent')
		and ca.ca_status = 'CAN'

--Set award sent
UPDATE	carrierbids
SET		cb_award_message_status = 'Sent'
FROM	carrierbids inner join carrierauctions ca on (carrierbids.ca_id = ca.ca_id)
WHERE  (cb_id = @cb_id)
		and (isnull(cb_award_message_status, 'Send') = 'Send')
		and (cb_sent_status = 'Sent')
		and ca.ca_status = 'AWARD'
		and cb_award_status = 'ACCEPT'


--Set Deny sent
UPDATE	carrierbids
SET		cb_deny_message_status = 'Sent'
FROM	carrierbids inner join carrierauctions ca on (carrierbids.ca_id = ca.ca_id)
WHERE  (cb_id = @cb_id)
		and (isnull(cb_deny_message_status, 'Send') = 'Send')
		and (cb_sent_status = 'Sent')
		and ca.ca_status = 'AWARD'
		and cb_award_status <> 'ACCEPT'

UPDATE carrierauctions
SET ca_status = 'XPRTED'
FROM carrierauctions ca inner join carrierbids cb on ca.ca_id = cb.ca_id
WHERE  (cb_id = @cb_id)
		AND (ca_status = 'EXPORT')

GO
GRANT EXECUTE ON  [dbo].[CarrierBidRequestSent_sp] TO [public]
GO
