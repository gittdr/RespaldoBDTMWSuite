SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Eric T. Hammel
-- Create date: 10/02/2015
-- Description:	Calculate Rating Ratios 
--              Using Custom SP Logic
-- PTS #:		95224
-- =============================================
CREATE PROCEDURE [dbo].[sp_CalculateAllocationByWeight]
( 
	@AllocationInputXML				XML
) AS
BEGIN

    DECLARE @nocount CHAR(1)
    DECLARE @arithabort CHAR(1)

    -- Determine current options and change for XQuery to work in any environment
    DECLARE @options INT
    SELECT @options = @@OPTIONS

    SELECT @nocount = 'N'
    IF ( (512 & @options) = 512 )
        SELECT @nocount = 'Y'

    SELECT @arithabort = 'N'
    IF ( (64 & @options) = 64 )
        SELECT @arithabort = 'Y'

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;
    SET ARITHABORT ON;

	DECLARE @AllocationInputs TABLE
	(
	  OrderId INT,
	  LegId INT,
	  Type varchar(25),
	  Weight DECIMAL(18,8),
	  WeightUnit varchar(25),
	  Count DECIMAL(18,8),
	  CountUnit varchar(25),
	  Volume DECIMAL(18,8),
	  VolumeUnit varchar(25),
	  Width DECIMAL(18,8),
	  WidthUnit varchar(25),
	  Height DECIMAL(18,8),
	  HeightUnit varchar(25),
	  Length DECIMAL(18,8),
	  LengthUnit varchar(25),
	  Distance DECIMAL(18,8)
	)

	DECLARE @AllocationOutputs TABLE
	(
	  OrderId INT,
	  LegId INT,
	  Numerator DECIMAL(18,8),
	  Denominator DECIMAL(18,8),
	  Ratio DECIMAL(18,8)
	)

	DECLARE @Denominators TABLE
	(
	  OrderId INT,
	  LegId INT,
	  Value DECIMAL(18,8)
	)

	DECLARE @Numerators TABLE
	(
	  OrderId INT,
	  LegId INT,
	  Value DECIMAL(18,8)
	)



	INSERT INTO @AllocationInputs
	SELECT 
				AllocationInput.value('(./OrderId)[1]', 'INT') AS OrderId,
				AllocationInput.value('(./LegId)[1]', 'INT') AS LegId,
				AllocationInput.value('(./Type)[1]', 'varchar(25)') AS Type,
				AllocationInput.value('(./Weight)[1]', 'DECIMAL(18,8)') AS Weight,
				AllocationInput.value('(./WeightUnit)[1]', 'varchar(25)') AS WeightUnit,
				AllocationInput.value('(./Count)[1]', 'DECIMAL(18,8)') AS Count,
				AllocationInput.value('(./CountUnit)[1]', 'varchar(25)') AS CountUnit,
				AllocationInput.value('(./Volume)[1]', 'DECIMAL(18,8)') AS Volume,
				AllocationInput.value('(./VolumeUnit)[1]', 'varchar(25)') AS VolumeUnit,
				AllocationInput.value('(./Width)[1]', 'DECIMAL(18,8)') AS Width,
				AllocationInput.value('(./WidthUnit)[1]', 'varchar(25)') AS WidthUnit,
				AllocationInput.value('(./Height)[1]', 'DECIMAL(18,8)') AS Height,
				AllocationInput.value('(./HeightUnit)[1]', 'varchar(25)') AS HeightUnit,
				AllocationInput.value('(./Length)[1]', 'DECIMAL(18,8)') AS Length,
				AllocationInput.value('(./LengthUnit)[1]', 'varchar(25)') AS LengthUnit,
				AllocationInput.value('(./Distance)[1]', 'DECIMAL(18,8)') AS Distance
			FROM 
				@AllocationInputXML.nodes('/*[local-name()="ArrayOfFlatAllocationInput"]/FlatAllocationInput') AS XMLData(AllocationInput);

	--SELECT * FROM @AllocationInputs;
	INSERT INTO @Numerators SELECT OrderId, LegId, SUM(Weight) AS Value FROM @AllocationInputs WHERE Type = 'Numerator' GROUP BY LegId, OrderId;
	INSERT INTO @Denominators SELECT OrderId, LegId, SUM(Weight) AS Value FROM @AllocationInputs WHERE Type = 'Denominator' GROUP BY LegId, OrderId;
	--SELECT * FROM @Numerators;
	--SELECT * FROM @Denominators;
	INSERT INTO @AllocationOutputs 
	SELECT n.OrderId, n.LegId, n.Value AS Numerator, d.Value as Denominator, (n.Value / d.Value) AS Ratio FROM @Numerators AS n JOIN @Denominators AS d ON d.LegId = n.LegId AND d.OrderId = n.OrderId;


	SELECT * FROM @AllocationOutputs;

    IF @nocount = 'N'
          SET NOCOUNT OFF

    IF @arithabort = 'N'
          SET ARITHABORT OFF
END
GO
GRANT EXECUTE ON  [dbo].[sp_CalculateAllocationByWeight] TO [public]
GO
