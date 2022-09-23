SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_asset_branch_sp]		
		@ai_lgh_number int,
		@as_asgn_type	varchar(6),
		@as_asgn_id	varchar(13),
		@as_resourceTypeOnLeg char(1),
		@asgn_branch	varchar(12)	OUTPUT		-- vjh pts63018
		
AS
set nocount on 
		
/**
 *
 * NAME:
 * dbo.get_lgh_mpp2_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *		patterned after get_lgh_mpp2_sp, this proc gets the branch for an asset.
 *		It conditionally uses the branch from the asset assignment table
 * 
 * RETURNS:
 *	Output variables to nvo_autotrippay.f_getpaytariff.
 *	Values if they exist or "UNKNOWN" if no data exists.
 *
 * RESULT SET as output variables:
 *			@asgn_branch	varchar(12)
 *
 * PARAMETERS:  
 * 001	@ai_lgh_number int,
 * 002	@as_asgn_type	varchar(6)
 * 003	@as_asgn_id	varchar(13),
 * 004	@as_resourceTypeOnLeg char(1),
 * 005	@asgn_branch	varchar(12)	OUTPUT		-- vjh pts63018
 *  
 * REFERENCES:   None
 * REVISION HISTORY:
 * Date ? 		PTS# - 	AuthorName ? Revision Description
 * 10/26/2012	63018	vjh			Original code
 */ 

declare @calculated_asgn_branch			varchar(12)



If @as_resourceTypeOnLeg = 'Y'	
	IF @as_asgn_type = 'TPR'
		select @calculated_asgn_branch = tpa_branch from thirdpartyassignment
		where lgh_number=@ai_lgh_number and tpr_id=@as_asgn_id
	ELSE --all other asset types
		select @calculated_asgn_branch = asgn_branch from assetassignment
		where lgh_number=@ai_lgh_number and asgn_type=@as_asgn_type and asgn_id=@as_asgn_id

IF  @as_resourceTypeOnLeg = 'N' or @calculated_asgn_branch is null --vjh - if asset assignment value is null, then this order pre-dates the population code
BEGIN 	
	IF @as_asgn_type = 'TPR'
		select @calculated_asgn_branch =  tpr_branch from thirdpartyprofile
		where tpr_id=@as_asgn_id
	ELSE IF @as_asgn_type = 'DRV'
		select @calculated_asgn_branch = mpp_branch from manpowerprofile
		where mpp_id=@as_asgn_id
	ELSE IF @as_asgn_type = 'TRC'
		select @calculated_asgn_branch = trc_branch from tractorprofile
		where trc_number=@as_asgn_id
	ELSE IF @as_asgn_type = 'TRL'
		select @calculated_asgn_branch = trl_branch from trailerprofile
		where trl_number=@as_asgn_id
	ELSE IF @as_asgn_type = 'CAR'
		select @calculated_asgn_branch = car_branch from carrier
		where car_id=@as_asgn_id
END

------ Return Output:

SELECT	@asgn_branch =	@calculated_asgn_branch

GO
GRANT EXECUTE ON  [dbo].[get_asset_branch_sp] TO [public]
GO
