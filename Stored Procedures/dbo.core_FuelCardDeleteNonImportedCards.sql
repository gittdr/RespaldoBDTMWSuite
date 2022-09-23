SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_FuelCardDeleteNonImportedCards]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_importbatch varchar(20)
AS
	UPDATE cashcard set crd_status = 'D' 
	WHERE crd_vendor = @fuelcard_crd_vendor 
	AND IsNull (crd_importbatch, '') <> @fuelcard_crd_importbatch

--	DELETE FROM cashcard 
--	WHERE crd_vendor = @fuelcard_crd_vendor 
--	AND IsNull (crd_importbatch, '') <> @fuelcard_crd_importbatch

	SELECT 1 As result


GO
GRANT EXECUTE ON  [dbo].[core_FuelCardDeleteNonImportedCards] TO [public]
GO
