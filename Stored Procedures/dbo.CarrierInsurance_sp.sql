SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[CarrierInsurance_sp] (@car_id				varchar (8))
as

/**
 * 
 * NAME:
 * CarrierInsurance_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to retrieve carrier insurance and limit data
 *
 * RETURNS:
 * NA
 * 
 * RESULT SETS: 
 * see select
 *
 * PARAMETERS:
 * @car_id				varchar (8)
 *
 * REVISION HISTORY:
 * 07/24/2012 PTS61827 - vjh - new proc for datawindow
 */
-- sample call
-- CarrierInsurance_sp 'boyd'
SELECT	a.cai_id,
		a.car_id,
		a.cai_cmpissued,
		--a.cai_insurance_type,
		isnull( caix.ciax_determination, a.cai_insurance_type) AS cai_insurance_type,
		'CarInsuranceType' cai_insurance_type_t,
		cai_effective_dt,
		a.cai_expiration_dt,
		a.cai_liability_limit,
		a.cai_comment,
		a.cai_updatedby,
		a.cai_updatedt,
		a.cai_policynumber,
		a.cai_imageURL,
		a.cai_Source,
		null AS limitamount,
		null AS limitdesc,
		a.cai_AgentName,
		a.cai_AgentPhone,
		a.cai_AgentFax,
		caix.ciax_determination
FROM	carrierinsurance a
LEFT OUTER JOIN carrierinsurance_xref caix ON
		a.car_id=caix.car_id AND
		a.cai_policynumber = caix.cai_policynumber AND
		a.cai_insurance_type = caix.cai_insurance_type
WHERE	a.car_id = @car_id AND
		(
			isnull(cai_Source,'') <> 'TransCore'
			OR
			not exists (select 1 from carrierinsurance b where b.cai_insurance_type = a.cai_insurance_type and b.car_id= a.car_id and isnull(b.cai_Source,'') <> 'TransCore')
		)
 
UNION 
 
SELECT	c.cai_id,
		c.car_id,
		c.cai_cmpissued,
		--c.cai_insurance_type,
		isnull( caix.ciax_determination, c.cai_insurance_type) AS cai_insurance_type,
		'CarInsuranceType' cai_insurance_type_t,
		c.cai_effective_dt,
		c.cai_expiration_dt,
		c.cai_liability_limit,
		c.cai_comment,
		c.cai_updatedby,
		c.cai_updatedt,
		c.cai_policynumber,
		c.cai_imageURL,
		c.cai_Source,
		l.cal_limit AS limitamount,
		l.cal_description AS limitdesc,
		c.cai_AgentName, 
		c.cai_AgentPhone, 
		c.cai_AgentFax,
		caix.ciax_determination
FROM	carrierinsurance c
join	carrierinsurancelimits l ON l.cai_id = c.cai_id
LEFT OUTER JOIN carrierinsurance_xref caix ON
		c.car_id=caix.car_id AND
		c.cai_policynumber = caix.cai_policynumber AND
		c.cai_insurance_type = caix.cai_insurance_type
WHERE	c.car_id = @car_id AND
		(
			 isnull(cai_Source,'') <> 'TransCore'
			 OR
			 not exists (select 1 from carrierinsurance b where b.cai_insurance_type = c.cai_insurance_type and b.car_id= c.car_id and isnull(b.cai_Source,'') <> 'TransCore')
		 ) 

ORDER BY cai_id, limitdesc
 
GO
GRANT EXECUTE ON  [dbo].[CarrierInsurance_sp] TO [public]
GO
