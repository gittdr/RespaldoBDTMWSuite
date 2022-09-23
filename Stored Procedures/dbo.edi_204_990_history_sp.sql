SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[edi_204_990_history_sp]  
	@search_value integer  
as  

Declare @BrokerageEdiBasis varchar(10)

Select @BrokerageEdiBasis = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'BrokerageEdiBasis'  

if @BrokerageEdiBasis = 'ORDER'
	BEGIN
		SELECT '204' type, a.ord_number, a.edi_code, a.process_status, a.created_dt, a.car_id,
			   carrier.car_name, ' ' counter, '' rejection_error_reason
			FROM edi_outbound204_order a JOIN carrier ON a.car_id = carrier.car_id
			WHERE ord_hdrnumber = @search_value
		UNION
		SELECT '990' type, a.ord_number, a.action edi_code, a.processed_flag,
				   a.created_dt, carrier.car_id, carrier.car_name, a.car_trip_id counter,
				   a.rejection_error_reason
			FROM edi_inbound990_records a LEFT OUTER JOIN carrier ON a.scac = carrier.car_id
			WHERE a.ord_hdrnumber = @search_value
	END
ELSE
	BEGIN
		SELECT '204' type, a.lgh_number, a.edi_code, a.process_status, a.created_dt, a.car_id,
			   carrier.car_name, ' ' counter, '' rejection_error_reason
		  FROM edi_outbound204_order a JOIN carrier ON a.car_id = carrier.car_id
		WHERE lgh_number = @search_value
		UNION
		SELECT '990' type, a.lgh_number, a.action edi_code, a.processed_flag,
			   a.created_dt, carrier.car_id, carrier.car_name, a.car_trip_id counter,
			   a.rejection_error_reason
		  FROM edi_inbound990_records a LEFT OUTER JOIN carrier ON a.scac = carrier.car_id
		WHERE a.lgh_number = @search_value
	END
GO
GRANT EXECUTE ON  [dbo].[edi_204_990_history_sp] TO [public]
GO
