SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[d_carrierlanecommitmentbycarrier] (@Car_ID varchar(8))

AS
	SET NOCOUNT ON

	CREATE TABLE #resultset(
		carrierlanecommitmentid int				NULL,
		laneid					int				NULL,
		lanecode				varchar(15)		NULL,
		car_id					varchar(8)		NULL,
		origin_type				int				NULL,
		origin_countrycode		varchar(6)		NULL,
		origin_stateabbr		varchar(6)		NULL,
		origin_county			varchar(50)		NULL,
		origin_cityname			varchar(50)		NULL,
		origin_citycode			int				NULL,
		origin_zippart			varchar(10)		NULL,
		origin_companyid		varchar(8)		NULL,
		dest_type				int				NULL,
		dest_countrycode		varchar(6)		NULL,
		dest_stateabbr			varchar(6)		NULL,
		dest_county				varchar(50)		NULL,
		dest_cityname			varchar(50)		NULL,
		dest_citycode			int				NULL,
		dest_zippart			varchar(10)		NULL,
		dest_companyid			varchar(8)		NULL,
		effectivedate			datetime		NULL,
		expiresdate				datetime		NULL,
		commitmentnumber		int				NULL,
		commitmentperiod		varchar(50)		NULL,
		clc_email_address		varchar(255)	NULL,
		car_rating				varchar(12)		NULL,
)

INSERT INTO #resultset(carrierlanecommitmentid, 
						laneid, 
						lanecode, 
						car_id, 
						effectivedate, 
						expiresdate, 
						commitmentnumber, 
						commitmentperiod,
						clc_email_address,
						car_rating
				)
SELECT	clc.carrierlanecommitmentid, 
		clc.laneid, 
		cl.lanecode, 
		clc.car_id, 
		clc.effectivedate, 
		clc.expiresdate, 
		clc.commitmentnumber, 
		clc.commitmentperiod, 
		clc_email_address,
		clc.car_rating
  FROM core_carrierlanecommitment clc INNER JOIN core_lane cl on clc.laneid = cl.laneid
 WHERE clc.car_id = @car_id

UPDATE #resultset
SET origin_type = type,
	origin_countrycode = countrycode,
	origin_stateabbr = stateabbr,
	origin_county = county,
	origin_cityname = cityname,
	origin_citycode = citycode,
	origin_zippart = zippart,
	origin_companyid = companyid
FROM #resultset r INNER JOIN core_lanelocation cll on (r.laneid = cll.laneid AND isOrigin = 1)
WHERE cll.lanelocationid = (SELECT TOP 1 lanelocationid
							FROM core_lanelocation cllinner 
							WHERE cllinner.laneid = cll.laneid and IsOrigin = 1
							ORDER BY cllinner.specificitycode)

UPDATE #resultset
SET dest_type = type,
	dest_countrycode = countrycode,
	dest_stateabbr = stateabbr,
	dest_county = county,
	dest_cityname = cityname,
	dest_citycode = citycode,
	dest_zippart = zippart,
	dest_companyid = companyid
FROM #resultset r INNER JOIN core_lanelocation cll on (r.laneid = cll.laneid AND isOrigin = 2)
WHERE cll.lanelocationid = (SELECT TOP 1 lanelocationid
							FROM core_lanelocation cllinner 
							WHERE cllinner.laneid = cll.laneid and IsOrigin = 2
							ORDER BY cllinner.specificitycode)

/*
	, clc.effectivedate, 
       clc.expiresdate, clc.commitmentnumber, clc.commitmentperiod, 
		 ISNULL(clc.car_preferred, 'N') car_preferred, 
       ISNULL(clc.car_commitment_cap, 0) car_commitment_cap, 
       ISNULL(clc.car_factor, 1) car_factor, clc.iseligible,
       ISNULL(clc.commitment_cap_period, 'M') commitment_cap_period,
       ISNULL(clc.isfrontloadedcommitment, 'N') isfrontloadedcommitment,
       ISNULL(clc.exclusivepriority, 0) exclusivepriority,
       ISNULL(clc.roundrobin_percent, 0) roundrobin_percent,
		 ISNULL(clc.car_rating, 'UNKNOWN') car_rating
*/
SELECT 
	carrierlanecommitmentid,
	laneid,
	lanecode,
	car_id,
	origin_type,
	origin_countrycode,
	origin_stateabbr,
	origin_county,
	origin_cityname,
	origin_citycode,
	origin_zippart,
	origin_companyid,
	dest_type,
	dest_countrycode,
	dest_stateabbr,
	dest_county,
	dest_cityname,
	dest_citycode,
	dest_zippart,
	dest_companyid,
	effectivedate, 
	expiresdate, 
	commitmentnumber, 
	commitmentperiod,
	clc_email_address,
	car_rating
FROM #resultset
GO
GRANT EXECUTE ON  [dbo].[d_carrierlanecommitmentbycarrier] TO [public]
GO
