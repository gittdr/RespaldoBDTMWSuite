SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[CarrierAuctionGetSendToList_sp]
(
	@cb_id int
)
AS

DECLARE @CarrierAuctionEmailSource varchar(60)

DECLARE @Resultset TABLE (
	emailaddress varchar(255) NULL
)

SELECT @CarrierAuctionEmailSource = UPPER(ISNULL(gi_string1, 'DEFAULT'))
FROM generalinfo
WHERE gi_name = 'CarrierAuctionEmailSource'

IF @CarrierAuctionEmailSource <> 'CARHUB' BEGIN
	IF @CarrierAuctionEmailSource = 'DEFAULT' BEGIN
		INSERT INTO @Resultset(emailaddress)
		SELECT	isnull(cb_sent_email, isnull(clc_email_address, car_email)) as emailaddress
		FROM	carrierbids AS cb INNER JOIN
						  carrier AS car ON cb.car_id = car.car_id LEFT OUTER JOIN
						  core_carrierlanecommitment AS clc ON cb.carrierlanecommitmentid = clc.carrierlanecommitmentid
		WHERE cb.cb_id = @cb_id                      
	END
	ELSE IF @CarrierAuctionEmailSource = 'BIDONLY' BEGIN
		INSERT INTO @Resultset(emailaddress)
		SELECT	cb_sent_email as emailaddress
		FROM	carrierbids AS cb 
		WHERE	cb.cb_id = @cb_id   
				AND cb_sent_email IS NOT NULL                   
	END	

END

SELECT emailaddress
FROM @Resultset

GO
GRANT EXECUTE ON  [dbo].[CarrierAuctionGetSendToList_sp] TO [public]
GO
