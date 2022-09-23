SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[d_carrierauction_list_bids_sp]

	(
		@ca_id int
	)


AS

SELECT  cb.cb_id, cb.car_id, cb.carrierlanecommitmentid, cb.cb_award_status, cb.cb_award_datetime, cb.cb_award_user, cb.cb_award_application, cb.created_date, cb.created_user, 
               cb.modified_date, cb.modified_user, cb.car_rating, car.car_name, car.car_contact, car.car_phone1, cb.cb_reply_amount, cb.cb_reply_message, cb.cb_reply_expires, 
               cb.cb_reply_date
FROM     carrierbids AS cb INNER JOIN
               carrier AS car ON cb.car_id = car.car_id
WHERE  (cb.ca_id = @ca_id)
GO
GRANT EXECUTE ON  [dbo].[d_carrierauction_list_bids_sp] TO [public]
GO
