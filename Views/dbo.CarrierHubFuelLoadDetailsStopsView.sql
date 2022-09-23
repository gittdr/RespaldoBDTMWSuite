SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[CarrierHubFuelLoadDetailsStopsView]
AS
/*******************************************************************************************************************  
  Object Description:
  This view provides the stop details needed for the Fuel Load Details page

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  10/11/2016   Chip Ciminero    WE-202583   Created
*******************************************************************************************************************/

SELECT  S.mov_number [Move Number],
		L.lgh_carrier [Carrier],
		O.ord_number [Order Number],
		L.ord_hdrnumber [Order Header Number],
		S.stp_number [Stop Number],
		L.lgh_number [Leg Number],
		S.stp_mfh_sequence [Stop Sequence],
		RTRIM(LTRIM(S.cmp_id)) [Company Id],
		RTRIM(LTRIM(COALESCE(C.cmp_altid,''))) [Company AltId],
		RTRIM(LTRIM(C.cmp_name)) [Name],
		RTRIM(LTRIM(CTY.cty_nmstct)) [City],
		RTRIM(LTRIM(CTY.cty_state)) [State],
		S.stp_event [Event],
		E.evt_earlydate [Earliest Date],
		E.evt_latedate [Latest Date],
		E.evt_startdate [Arrival Date],
		CASE WHEN S.stp_status = 'DNE' THEN 'Y' ELSE 'N' END [Arrived],
		E.evt_enddate [Departure Date],
		CASE WHEN S.stp_departure_status = 'DNE' THEN 'Y' ELSE 'N' END [Departed],
		E.evt_hubmiles [Hub Miles],
		S.stp_type [Stop Type], 		
		O.ord_billto [BillTo],
		S.trl_id [Trailer],
		'' [Trailer2],
		S.stp_address [Address1],
		S.stp_address2 [Address2],
		COALESCE(S.stp_comment,'') [Comment],
		COALESCE(S.stp_phonenumber,'') [Phone],
		COALESCE(S.stp_phonenumber2,'') [Phone2],
		COALESCE(S.stp_contact,'') [Contact],
		S.stp_zipcode [ZipCode],
		S.cmp_id [ConsigneeId]
FROM	stops S
		INNER JOIN event as E ON E.stp_number = S.stp_number and E.evt_sequence = 1
		INNER JOIN company as C ON C.cmp_id = S.cmp_id                     
		INNER JOIN city as CTY ON CTY.cty_code = S.stp_city 
		INNER JOIN legheader as L ON L.lgh_number = S.lgh_number
		INNER JOIN orderheader as O ON O.ord_hdrnumber = L.ord_hdrnumber
GO
GRANT DELETE ON  [dbo].[CarrierHubFuelLoadDetailsStopsView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubFuelLoadDetailsStopsView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierHubFuelLoadDetailsStopsView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubFuelLoadDetailsStopsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubFuelLoadDetailsStopsView] TO [public]
GO
