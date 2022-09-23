SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_getTractorsByMobilCommTypeCodeArray]
(
-- =============================================
-- Author:		James Thompson
-- Create date: July 15, 2011
-- Description:	QHos Procedure to return the loads for instance
-- Instance is determined by [tblMobileCommType].[MobileCommType].
--   which represend QualComm Poller instances
-- @MobileCommTypeList may contain comma seperated list of MobileCommTypes
-- 
-- =============================================
	@MobileCommTypeList varchar(500)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @TempList table
	(
		MobileCommTypeCode varchar(50)
	)

	DECLARE @MobileCommTypeCode varchar(20), @Pos int

	SET @MobileCommTypeList = LTRIM(RTRIM(@MobileCommTypeList))+ ','
	SET @Pos = CHARINDEX(',', @MobileCommTypeList, 1)

	IF REPLACE(@MobileCommTypeList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @MobileCommTypeCode = LTRIM(RTRIM(LEFT(@MobileCommTypeList, @Pos - 1)))
			IF @MobileCommTypeCode <> ''
				BEGIN
					INSERT INTO @TempList (MobileCommTypeCode) VALUES (CAST(@MobileCommTypeCode AS varchar))
				END
			SET @MobileCommTypeList = RIGHT(@MobileCommTypeList, LEN(@MobileCommTypeList) - @Pos)
			SET @Pos = CHARINDEX(',', @MobileCommTypeList, 1)

		END
	END	

	-- Select rows from tblTrucks where the trucks mobile comm is assigned to one of the
	select tblTrucks.*,tblMobileCommType.MobileCommType,tblCabUnits.UnitID
		from tblTrucks
			inner join tblCabUnits on
				tblTrucks.DefaultCabUnit = tblCabUnits.SN
			inner join tblMobileCommType on
				tblMobileCommType.SN = tblCabUnits.[Type]
			inner join @TempList t on
				t.MobileCommTypeCode = tblMobileCommType.MobileCommType
			where DispSysTruckID is not null
	
END
GO
GRANT EXECUTE ON  [dbo].[tm_getTractorsByMobilCommTypeCodeArray] TO [public]
GO
