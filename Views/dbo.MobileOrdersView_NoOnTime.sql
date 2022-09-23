SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This view provides an order summary which allows search capabilities

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  06/28/2017   Chase Plante     WE-208658   Split view into its own file and added minutes away calculations
  10/09/2017   Chase Plante     WE-211090   Modified view to trim any string data
  06/13/2018   Lisa Bohm					Performance Rewrite
*******************************************************************************************************************/

CREATE view [dbo].[MobileOrdersView_NoOnTime]
AS



/* rolled the CTEs that were here down below to combine with the aggregates done on the stops table for the mileage */	
 
		 SELECT 'TMWWF_MOBILE_ORDERS' AS                                  'TMWWF_MOBILE_ORDERS'
					, ord.ord_number
					, ord.ord_hdrnumber
					, LTRIM(ord.ord_billto)                                     'BillToID'
					, LTRIM(RTRIM(B.cmp_name))                                  'BillTo'
					, LTRIM(scompany.cmp_id)                                    'ShipperID'
					, LTRIM(RTRIM(scompany.cmp_name))                           'ShipperName'
					, LTRIM(scity.cty_name)                                     'ShipperCity'
					, LTRIM(RTRIM(scity.cty_state))                             'ShipperState'
					, LTRIM(ccompany.cmp_id)                                    'ConsigneeID'
					, LTRIM(RTRIM(ccompany.cmp_name))                           'ConsigneeName'
					, LTRIM(ccity.cty_name)                                     'ConsigneeCity'
					, LTRIM(RTRIM(ccity.cty_state))                             'ConsigneeState'
					, ord.ord_startdate                                         'StartDate'
					, ord.ord_completiondate                                    'EndDate'
					, LTRIM(RTRIM(ord.ord_status))                              'Status'
					, ord.ord_totalmiles                                        'Distance'			
					, 'N/A' 'OnTimeStatus'
					, COALESCE(A.CarrierId, 'UNKNOWN')                          'CarrierId'
					, RTRIM(LTRIM(COALESCE(car.car_name, 'UNKNOWN')))           'CarrierName'
					, COALESCE(A.DriverId, 'UNKNOWN')                           'DriverId'
					, RTRIM(LTRIM(COALESCE(M.mpp_firstname, 'UNKNOWN')))        'DriverFirstName'
					, RTRIM(LTRIM(COALESCE(M.mpp_lastname, 'UNKNOWN')))         'DriverLastName'
					, COALESCE(A.TractorId, 'UNKNOWN')                          'TractorId'
					, COALESCE(A.TrailerId, 'UNKNOWN')                          'TrailerId'
					, COALESCE(RTRIM(LTRIM(scompany.cmp_BookingTerminal)),'UNKNOWN') 'ShipperAcctMngr'
					, COALESCE(RTRIM(LTRIM(ccompany.cmp_BookingTerminal)),'UNKNOWN') 'ConsigneeAcctMngr'
					, COALESCE(m.mpp_teamleader, 'UNK')							'TeamLeader'
		 FROM	orderheader ord WITH (NOLOCK)
				INNER JOIN city AS scity WITH (NOLOCK) ON ord.ord_origincity = scity.cty_code
				INNER JOIN company AS scompany WITH (NOLOCK) ON ord.ord_originpoint = scompany.cmp_id
				INNER JOIN city AS ccity WITH (NOLOCK) ON ord.ord_destcity = ccity.cty_code
				INNER JOIN company AS ccompany WITH (NOLOCK) ON ord_destpoint = ccompany.cmp_id
				LEFT OUTER JOIN company B WITH (NOLOCK) ON ord.ord_billto = B.cmp_id
				LEFT OUTER JOIN
				(			SELECT O.ord_hdrnumber
						 , DriverId = MAX(CASE
																WHEN A.asgn_type = 'DRV'
																	THEN A.asgn_id
															ELSE NULL
															END)
						 , CarrierId = MAX(CASE
																 WHEN A.asgn_type = 'CAR'
																	 THEN A.asgn_id
															 ELSE NULL
															 END)
						 , TractorId = MAX(CASE
																 WHEN A.asgn_type = 'TRC'
																	 THEN A.asgn_id
															 ELSE NULL
															 END)
						 , TrailerId = MAX(CASE
																 WHEN A.asgn_type = 'TRL'
																	 THEN A.asgn_id
															 ELSE NULL
															 END)
				FROM assetassignment A WITH (NOLOCK)
					INNER JOIN legheader L WITH (NOLOCK) ON A.lgh_number = L.lgh_number
					INNER JOIN orderheader O WITH (NOLOCK) ON L.mov_number = O.mov_number
				GROUP BY O.ord_hdrnumber
			) A ON ord.ord_hdrnumber = A.ord_hdrnumber
			 LEFT OUTER JOIN manpowerprofile M WITH (NOLOCK) ON A.DriverId = M.mpp_id
			 LEFT OUTER JOIN carrier car WITH (NOLOCK) ON A.CarrierId = car.car_id
		 WHERE ord.ord_status NOT IN('CAN', 'PND', 'ICO', 'MST')
	 ;
GO
GRANT SELECT ON  [dbo].[MobileOrdersView_NoOnTime] TO [public]
GO
