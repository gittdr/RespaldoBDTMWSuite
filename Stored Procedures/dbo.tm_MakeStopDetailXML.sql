SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_MakeStopDetailXML] 
		@StopCmpID_P01			AS VARCHAR(8) = '',
		@StopCmpName_P02		AS VARCHAR(100) = '',
		@StopPhone_P03			AS VARCHAR(20) = '',
		@StopEventCode_P04		AS VARCHAR(6) = '',
		@StopEventText_P05		AS VARCHAR(50) = '',
		@StopType_P06			AS VARCHAR(6) = '',
		@StopEarliestDtTm_P07	AS VARCHAR(40) = '',
		@StopLatestDtTm_P08		AS VARCHAR(40) = '',
		@StopCount_P09			AS VARCHAR(6) = '0', --INT = 0,
		@StopCountUnit_P10		AS VARCHAR(10) = '',
		@StopWeight_P11			AS VARCHAR(12) = '0.0', --DECIMAL(10,4) = 0.0,
		@StopWeightUnit_P12		AS VARCHAR(6) = '',
		@StopCommodityCode_P13	AS VARCHAR(8) = '',
		@StopCommodityName_P14	AS VARCHAR(60) = '',
		@StopComment_P15		AS VARCHAR(254) = ''							 

AS

-- =================================================================================================
-- Stored Proc: tm_MakeStopDetailXML
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.11.10
-- Description: Uses data from Stop Info to populate the WF Stop Detail Tab XML.
--      
--      Outputs:
--      --------------------------------------------------------------------------------------------
--      @XMLForStopNotes		VARCHAR(MAX)
--
--      Input parameters:
--      --------------------------------------------------------------------------------------------
--		See above.
--
-- =================================================================================================
-- Modification Log:
-- PTS 83368 - VMS - 2014.11.10 - Created
--
-- =================================================================================================
-- Testing:
/*
EXEC tm_MakeStopDetailXML
		'CWRCLE',
		'Case Western&Reserve University',
		'2165551212',
		'LLD',
		'Live Load',
		'PUP',
		'2014-11-10T11:00:00',
		'2014-11-10 11:05:00',
		5,
		'',
		25.0,
		'',
		'EQUIP',
		'UNKNOWN',
		'two blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah' 
*/
-- =================================================================================================

	BEGIN

		DECLARE @PrefixXML AS VARCHAR(300)
		DECLARE @WorkXML AS VARCHAR(MAX)
		DECLARE @DetailNode AS VARCHAR(500)
		DECLARE @XMLForStopDetailTab AS VARCHAR(MAX) 
		DECLARE @NodeNbr AS INT 
		DECLARE @BegXML AS VARCHAR(100)
		DECLARE @EndXML AS VARCHAR(15)
		DECLARE @WorkWeightUnit AS VARCHAR(6)
		DECLARE @WorkCountUnit AS VARCHAR(10)
		DECLARE @WorkCommodityCode AS VARCHAR(8)
		DECLARE @WorkCommodityName AS VARCHAR(60)
		-- -----------------------------------------------------------------------------
		SET @NodeNbr = 0
		SET @WorkXML = ''
		SET @BegXML = '<data id="InfoPlus_Detail_Stop"><datum name="type" value="details" />'
		SET @endXML = '</data>'
		-- -----------------------------------------------------------------------------
		SET @PrefixXML =   
   				'<data id="StopDetailHdr">' + 
   				'<datum name="type" value="customItem" />' +
				'<datum name="sortId" value="100" />' +
				'<datum name="customLabel" value=" [ Detail ] " />' +
				'<datum name="customValue" value=" " />' +
				'</data>'
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopCmpID_P01,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Company ID' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						REPLACE(@StopCmpID_P01, '&', '') AS 'datum/@value' 
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopCmpName_P02,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Company Name' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						REPLACE(@StopCmpName_P02, '&', ' AND ') AS 'datum/@value' 
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopPhone_P03,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Phone' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						'('+ left(@StopPhone_P03,3)+ ') ' + substring(@StopPhone_P03,4,3) + '-' + substring(@StopPhone_P03,7,4)  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopEventCode_P04,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Stop Event Code' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopEventCode_P04  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopEventText_P05,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Stop Event Desc' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopEventText_P05  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopType_P06,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Stop Type' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopType_P06  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopEarliestDtTm_P07,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Earliest Time' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopEarliestDtTm_P07  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopLatestDtTm_P08,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Latest Time' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopLatestDtTm_P08  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		DECLARE @WorkINT AS INT
		
		IF (ISNULL(@StopCount_P09,'') = '') 
			BEGIN
				SET @WorkInt = '0'
			END
		ELSE
			BEGIN
				IF (ISNUMERIC(@StopCount_P09) = 1)
					SELECT @WorkINT = @StopCount_P09
				ELSE
					SELECT @WorkINT = '0'	
			END		

		IF (@WorkINT <> 0)
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Piece Count' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@WorkINT  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
				-- -----------------------------------------------------------------------------
				-- If Count is 0 then Count Unit node will not be created.
				-- If Count is not 0 but Count Unit is NULL or '' then default to 'PCS'

				SET @WorkCountUnit = ISNULL(@StopCountUnit_P10,'PCS') 
				IF (@WorkCountUnit =  '') SET @WorkCountUnit = 'PCS'

				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Piece Count Unit' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@WorkCountUnit  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		DECLARE @WorkWeight AS DECIMAL(10,4)
		
		IF (ISNULL(@StopWeight_P11,'') = '') 
			BEGIN
				SET @WorkWeight = '0.0'
			END
		ELSE
			BEGIN
				IF (ISNUMERIC(@StopWeight_P11) = 1)
					SELECT @WorkWeight = @StopWeight_P11
				ELSE
					SELECT @WorkWeight = '0.0'	
			END		

		IF (@WorkWeight <> 0.0)
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Weight' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@WorkWeight  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
				-- -----------------------------------------------------------------------------
				-- If weight is 0 then Weight Unit node will not be created.
				-- If weight is not 0 but Weight Unit is NULL or '' then default to 'LBS'

				SET @WorkWeightUnit = ISNULL(@StopWeightUnit_P12,'LBS') 
				IF (@WorkWeightUnit =  '') SET @WorkWeightUnit = 'LBS'
				
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Weight Unit' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@WorkWeightUnit  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		SET @WorkCommodityCode = ISNULL(@StopCommodityCode_P13,'')
		IF @WorkCommodityCode = 'UNKNOWN' SET @WorkCommodityCode = ''
		IF (@WorkCommodityCode <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Commodity Code' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopCommodityCode_P13  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		SET @WorkCommodityName = ISNULL(@StopCommodityName_P14,'')
		IF @WorkCommodityName = 'UNKNOWN' SET @WorkCommodityName = ''
		IF (@WorkCommodityName <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Commodity Name' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopCommodityName_P14  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		IF (ISNULL(@StopComment_P15,'') <> '')
			BEGIN
				SET @NodeNbr = @NodeNbr + 1
				SELECT @DetailNode = (				
					SELECT	
						'InfoSD' + CONVERT(VARCHAR(9), 100 + @NodeNbr) AS '@id',
						'type' AS 'datum/@name',
						'customItem' AS 'datum/@value',
						'',
						'sortId' AS 'datum/@name',
						@NodeNbr AS 'datum/@value',
						'',
						'customLabel' AS 'datum/@name', 
						'Comment' AS 'datum/@value', 
						'',
						'customValue' AS 'datum/@name', 
						@StopComment_P15  AS 'datum/@value'
					FOR  XML PATH('data')
				)
				SET @WorkXML = @WorkXML + @DetailNode
			END
		-- -----------------------------------------------------------------------------
		SELECT @XMLForStopDetailTab =  @BegXML + @PrefixXML + @WorkXML + @EndXML 
		-- -----------------------------------------------------------------------------
		SELECT @XMLForStopDetailTab 'XMLForStopDetailTab'
	END

GO
GRANT EXECUTE ON  [dbo].[tm_MakeStopDetailXML] TO [public]
GO
