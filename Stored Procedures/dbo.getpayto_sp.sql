SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[getpayto_sp] (@asset_type varchar(3),
--BEGIN PTS 53067 SPN
--@asset_id varchar(8),
@asset_id varchar(13),
--END PTS 53067 SPN
@payto_id varchar(12) OUTPUT,
@actg_type varchar(1) OUTPUT)
AS

-- Get driver payto and accounting type
IF @asset_type = 'DRV'
	SELECT @payto_id = mpp_payto,
	       @actg_type = mpp_actg_type
	FROM manpowerprofile
	WHERE mpp_id = @asset_id

-- Get tractor payto and accounting type
IF @asset_type = 'TRC'
	SELECT @payto_id = trc_owner,
	       @actg_type = trc_actg_type
	FROM tractorprofile
	WHERE trc_number = @asset_id

-- Get carrier payto and accounting type
IF @asset_type = 'CAR'
	SELECT @payto_id = pto_id,
	       @actg_type = car_actg_type
	FROM carrier
	WHERE car_id = @asset_id

-- Get trailer payto and accounting type
IF @asset_type = 'TRL'
	SELECT @payto_id = trl_owner,
	       @actg_type = trl_actg_type
FROM trailerprofile
--BEGIN PTS 53067
--WHERE trl_number = @asset_id
WHERE trl_id = @asset_id
--END PTS 53067

-- Get third party payto and accounting type
IF @asset_type = 'TPR'
	SELECT @payto_id = tpr_payto,
	       @actg_type = tpr_actg_type
FROM thirdpartyprofile
WHERE tpr_id = @asset_id

GO
GRANT EXECUTE ON  [dbo].[getpayto_sp] TO [public]
GO
