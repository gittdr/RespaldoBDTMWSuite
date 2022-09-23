SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[insert_tti_gls_data]
	@SN					INT = -1 OUT,
	@DeviceID				VARCHAR(20),
	@DTData				DATETIME,
	@AssetID				VARCHAR(20) = NULL,
	@ReportType				VARCHAR(100) = NULL,
	@EventSource				INT = NULL,
	@Latitude				DECIMAL(11,8) = NULL,
	@Longitude				DECIMAL(11,8) = NULL,
	@Quality				INT = NULL,
	@PowerStatus				VARCHAR(10) = NULL,
	@Landmark				VARCHAR(255) = NULL,
	@IdleStatus				VARCHAR(10) = NULL,
	@IdleDuration				DECIMAL(8,3) = NULL,
	@IdleGap				DECIMAL(8,3) = NULL
AS

BEGIN

	INSERT INTO tti_gls_data 
		(
		DeviceID,
		DTData,
		AssetID,
		ReportType,
		EventSource,
		Latitude,
		Longitude,
		Quality,
		PowerStatus,
		Landmark,
		IdleStatus,
		IdleDuration,
		IdleGap,
		DTCreated
		)
	values 	(
		@DeviceID,
		@DTData,
		@AssetID,
		@ReportType,
		@EventSource,
		@Latitude,
		@Longitude,
		@Quality,
		@PowerStatus,
		@Landmark,
		@IdleStatus,
		@IdleDuration,
		@IdleGap,
		getdate()
		)

SELECT @SN = @@identity

RETURN @@identity

END
GO
GRANT EXECUTE ON  [dbo].[insert_tti_gls_data] TO [public]
GO
