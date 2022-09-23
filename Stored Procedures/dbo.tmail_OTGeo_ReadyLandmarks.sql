SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OTGeo_ReadyLandmarks] @CMPID VARCHAR(8), @Instance INT
/*******************************************************************************************************************  
  Object Description:
  Checks the existance Status of Vendor Landmarks
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/07/08    Riley Wolfe     PTS94952	    init 
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF ISNULL(@Instance, 0) < 1
  SET @Instance = 1;

IF EXISTS (
		SELECT TOP 1 1
		FROM tblVendorLandmarks
		WHERE cmp_id = @CMPID
			AND vlm_instanceId = @Instance
			AND vlm_vendorId = 'Omnitracs'
			AND (vlm_Status = 2)
		)
BEGIN
	UPDATE tblVendorLandmarks
	SET vlm_Status = 0,
		vlm_pushdate = GETDATE()
	WHERE cmp_id = @CMPID
		AND vlm_instanceId = @Instance
		AND vlm_vendorId = 'Omnitracs';

	SELECT 2;
END
ELSE IF NOT EXISTS (
		SELECT TOP 1 1
		FROM tblVendorLandmarks
		WHERE cmp_id = @CMPID
			AND vlm_instanceId = @Instance
			AND vlm_vendorId = 'Omnitracs'
		)
BEGIN
	INSERT INTO tblVendorLandmarks (
		cmp_id,
		vlm_Status,
		vlm_vendorId,
		vlm_vendorLandmarkId,
		vlm_landmarkName
		)
	VALUES (
		@CMPID,
		1,
		'Omnitracs',
		'Undefined',
		'TMW:' + @CMPID
		);

	SELECT 1;
END
ELSE
	SELECT 0;
GO
GRANT EXECUTE ON  [dbo].[tmail_OTGeo_ReadyLandmarks] TO [public]
GO
