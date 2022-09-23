SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[CarrierWatch_CarrierInsuranceLimits_sp] (
		@cai_id				integer,
		@cal_limit			money,
		@cal_description	varchar(50),
		@cal_source			varchar(10)
)
AS

/**
 * 
 * NAME:
 * CarrierWatch_Insert_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to populate the Carrier table carrierinsurance
 *
 * RETURNS:
 * NA
 * 
 * RESULT SETS: 
 * NA
 *
 * PARAMETERS:
 * See prototype above
 *
 * REVISION HISTORY:
 * 07/24/2012 PTS61827 - vjh - new proc to populate the Carrier table carrierinsurance
 */
 
 -- sample call
 --
 --		CarrierWatch_CarrierInsurance_sp 'BOYD', 'PRIMARY', '12/31/2010', '12/31/2011', '1000000', 'Comment', 'NO', 'P#123456', 'www.imagesofinsurance.com/p123456', 'CarrierWatch'
 


	INSERT INTO carrierinsurancelimits (
		cai_id,
		cal_limit,
		cal_description,
		cal_source
	) VALUES (
		@cai_id,
		@cal_limit,
		@cal_description,
		@cal_source
	)

GO
GRANT EXECUTE ON  [dbo].[CarrierWatch_CarrierInsuranceLimits_sp] TO [public]
GO
