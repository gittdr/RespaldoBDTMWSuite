SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[CarrierWatch_CarrierInsurance_sp] (
	@car_id				varchar(8),
	@cai_insurance_type	varchar(6),
	@cai_effective_dt	datetime,
	@cai_expiration_dt	datetime,
	@cai_liability_limit	money,
	@cai_comment		varchar(50),
	@cai_cmpissued		varchar(2),
	@cai_policynumber	varchar(50),
	@cai_imageURL		varchar(300),
	@cai_Source			varchar(60),
	@cai_AgentName		varchar(50),
	@cai_AgentPhone		varchar(25),
	@cai_AgentFax		varchar(25)
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
 


	INSERT INTO carrierinsurance (
		car_id,
		cai_insurance_type,
		cai_effective_dt,
		cai_expiration_dt,
		cai_liability_limit,
		cai_comment,
		cai_cmpissued,
		cai_policynumber,
		cai_imageURL,
		cai_Source,
		cai_AgentName,
		cai_AgentPhone,
		cai_AgentFax
	) VALUES (
		@car_id,
		@cai_insurance_type,
		@cai_effective_dt,
		@cai_expiration_dt,
		@cai_liability_limit,
		@cai_comment,
		@cai_cmpissued,
		@cai_policynumber,
		@cai_imageURL,
		@cai_Source,
		@cai_AgentName,
		@cai_AgentPhone,
		@cai_AgentFax
	)

GO
GRANT EXECUTE ON  [dbo].[CarrierWatch_CarrierInsurance_sp] TO [public]
GO
