SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
	

CREATE   PROCEDURE [dbo].[d_cities_for_archival_sp] 
as

/*
*
* NAME:d_cities_for_archival_sp
* dbo.d_cities_for_archival_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Provide a set of candidates cities for archival, those not used on trips or in the database. 
*
* RETURNS:  
*
* RESULT SETS: 
* 001 - cty_code	int				City code
* 002 - cty_name 	varchar(18)		Name of city
* 003 - cty_state 	varchhr(6)		State or Province
* 004 - cty_zip 	varchar(10)		Zip code
* 005 - cty_county	char(3)			County
* 006 - alk_city	varchar (50)	ALK City name
* 007 - rand_city	varchar(25)		Rand City Name
* 008 - cty_region1 varchar(6)	    Region 1
* 009 - cty_region2 varchar(6)	    Region 2
* 010 - cty_region3 varchar(6)	    Region 3
* 011 - cty_region4 varchar(6)	    Region 4
* PARAMETERS:
*
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* city
* 
* REVISION HISTORY:
* 06/15/07 PTS 32403 - EMK - Created
* 08/23/07 PTS 32403 - EMK - Modified to account for cities on mileagetable that are strings, not city code
*/

CREATE TABLE #ctywithmiles (cwm_code int)

-- EMK  08/23/07
-- Need to create temporary table for cities on the mileagetable. 
-- Non cty_codes in origin/destination do not play nice with subqueries in union statements

--Destinations containing city codes
INSERT INTO #ctywithmiles (cwm_code) SELECT DISTINCT mt_destination FROM mileagetable WHERE mt_destinationtype = 'C' and isnumeric(mt_destination)=1

--Origins containing city codes
INSERT INTO #ctywithmiles (cwm_code) SELECT DISTINCT mt_origin FROM mileagetable WHERE mt_origintype = 'C' and isnumeric(mt_origin)=1

--Destinations containing city,state,county strings
INSERT INTO #ctywithmiles SELECT DISTINCT cty_code FROM city 
join mileagetable m ON m.mt_destination = (cty_name + ',' + cty_state + ',' + IsNull(cty_county,''))

--Origins containing city,state,county strings
INSERT INTO #ctywithmiles SELECT DISTINCT cty_code FROM city 
join mileagetable m ON m.mt_origin = (cty_name + ',' + cty_state + ',' + IsNull(cty_county,''))


SELECT distinct city.cty_code,
	city.cty_name,
	city.cty_state,
	city.cty_zip,
	city.cty_county,
	city.alk_city,
	city.rand_city,
	city.cty_region1,
	city.cty_region2,
	city.cty_region3,
	city.cty_region4,
	city.cty_nmstct	
FROM city
WHERE  city.cty_code NOT IN
(SELECT stops.stp_city cty_code FROM stops
UNION ALL  SELECT  company.cmp_city FROM company WHERE company.cmp_city IS NOT NULL
--PTS 32403 EMK 08/22/07 - Use new temporary table
--UNION ALL  SELECT  mt_destination FROM mileagetable WHERE mt_destinationtype = 'C'
--UNION ALL  SELECT  mt_origin FROM mileagetable WHERE mt_destinationtype = 'C'
UNION ALL  SELECT  cwm_code FROM #ctywithmiles
--PTS 32403
UNION ALL  SELECT  mpp_city FROM manpowerprofile WHERE mpp_city > 0
UNION ALL  SELECT  trc_avl_city FROM tractorprofile WHERE trc_avl_city > 0
UNION ALL  SELECT  trc_pln_city FROM tractorprofile WHERE trc_pln_city > 0
UNION ALL  SELECT  trc_prior_city FROM tractorprofile WHERE trc_prior_city > 0
UNION ALL  SELECT  trc_next_city FROM tractorprofile WHERE trc_next_city > 0
UNION ALL  SELECT  cty_code FROM trailerprofile WHERE cty_code > 0
UNION ALL  SELECT  trl_sch_city FROM trailerprofile WHERE trl_sch_city > 0
UNION ALL  SELECT  trl_avail_city FROM trailerprofile WHERE trl_avail_city > 0
UNION ALL  SELECT  trl_next_city FROM trailerprofile WHERE trl_next_city > 0
UNION ALL  SELECT  trl_prior_city FROM trailerprofile WHERE trl_prior_city > 0
UNION ALL  SELECT  ts_cty FROM truckstops WHERE ts_cty > 0
UNION ALL  SELECT  ttrd_intvalue FROM ttrdetail WHERE ttrd_level='CITY' and ttrd_intvalue >0
UNION ALL  SELECT  acd_TowDestCity FROM accident WHERE acd_TowDestCity > 0
UNION ALL  SELECT  cty_code FROM carrier WHERE cty_code > 0 
UNION ALL  SELECT  dv_city FROM dispatchview WHERE dv_city > 0
UNION ALL  SELECT  dv_dest_city FROM dispatchview WHERE dv_dest_city > 0
UNION ALL  SELECT  dv_next_city FROM dispatchview WHERE dv_next_city > 0 
UNION ALL  SELECT  drc_city FROM drivercomplaint WHERE drc_city > 0 
UNION ALL  SELECT  dro_city FROM driverobservation WHERE dro_city > 0 
UNION ALL  SELECT  ee_city FROM employeeprofile WHERE ee_city > 0 
UNION ALL  SELECT  exp_city FROM expiration WHERE exp_city > 0 
UNION ALL  SELECT  inc_ComplCity FROM incident WHERE inc_ComplCity > 0 
UNION ALL  SELECT  inj_City FROM injury WHERE inj_City > 0
UNION ALL SELECT cty_code from city where cty_fuelcreate = 1)
ORDER BY cty_code

DROP TABLE #ctywithmiles

GO
GRANT EXECUTE ON  [dbo].[d_cities_for_archival_sp] TO [public]
GO
