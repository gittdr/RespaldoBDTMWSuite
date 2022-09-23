SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_MakeOrderLevelInfoTab] 
					@OrderNumber		AS VARCHAR(12),
					@LDMiles			AS INT,
					@MTMiles			AS INT
							 
AS

-- =================================================================================================
-- Stored Proc: tmail_MakeOrderLevelInfoTab
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.11.10
-- Description: Collects data from the Notes table that are attached to the WF Trip Plan stop.
--              Any records found will be placed in the WF XML at the TripPlan stop level.
--      
--      Outputs:
--      --------------------------------------------------------------------------------------------
--      @XMLForStopNotes		VARCHAR(MAX)
--
--      Input parameters:
--      --------------------------------------------------------------------------------------------
--		@OrderNumber  			VARCHAR(12)
--
-- =================================================================================================
-- Modification Log:
-- PTS 83368 - VMS - 2014.11.10 - Created
--
-- =================================================================================================
-- Testing:
-- EXEC tmail_MakeOrderLevelInfoTab '626', 50, 10
-- =================================================================================================

	BEGIN

		CREATE TABLE #OrderNotes (
						sn				 int identity, 
						Notes			 varchar(255), 
						NotesNoWrap		 varchar(max),
						AttachedTo		 varchar(20), 
						Regarding		 varchar(50),
						RegardingAbbr	 varchar(20),
						AttachedToKey	 varchar(20), 
						NoteNum			 int
						)

		DECLARE @BegXML					AS VARCHAR(150)
		DECLARE @EndXML					AS VARCHAR(10)
		DECLARE @PrefixXML				AS VARCHAR(300)
		DECLARE @RefInfoXML				AS VARCHAR(MAX)
		DECLARE @XMLForOrderRefInfo		AS VARCHAR(MAX)
		DECLARE @OrderNotesXML			AS VARCHAR(MAX)
		DECLARE @XMLForOrderNotes		AS VARCHAR(MAX)
		DECLARE @LDMilesXML				AS VARCHAR(300)
		DECLARE @MTMilesXML				AS VARCHAR(300)
		DECLARE @XMLForOrderGenInfo		AS VARCHAR(MAX) 

		DECLARE @OrderLevelInfoXML		AS VARCHAR(MAX)
		-- -----------------------------------------------------------------------------------------
		SET @BegXML = '<data id ="InfoPlusForOrderRefsAndNotes"><datum name="type" value="info"/>'
		SET @EndXML = '</data>'

		-- =========================================================================================
		-- Adding loaded and empty miles to the Order Info Tab XML section.
		-- =========================================================================================
		SET @PrefixXML =   
   				'<data id="OrderInfoGenInfoHdr">' + 
   				'<datum name="type" value="customItem" />' +
				'<datum name="sortId" value="100" />' +
				'<datum name="customLabel" value=" [ General Information ] " />' +
				'<datum name="customValue" value=" " />' +
				'</data>'

		-- SET @LDMiles = 50
		
		SELECT @LDMilesXML = (
			SELECT 
					'InfoGeneralLDMiles' AS '@id',
					'type' AS 'datum/@name',
					'customItem' AS 'datum/@value',
					'',
					'sortId' AS 'datum/@name',
					 110 AS 'datum/@value',
					 '',
					'customLabel' AS 'datum/@name', 
					'LoadedMiles' AS 'datum/@value', 
					'',
					'customValue' AS 'datum/@name', 
					@LDMiles AS 'datum/@value' 
			   FOR XML PATH('data')
			)
			   
		-- SET @LDMiles = 0

		SELECT @MTMilesXML = (
			SELECT 
					'InfoGeneralMTMiles' AS '@id',
					'type' AS 'datum/@name',
					'customItem' AS 'datum/@value',
					'',
					'sortId' AS 'datum/@name',
					 120 AS 'datum/@value',
					 '',
					'customLabel' AS 'datum/@name', 
					'EmptyMiles' AS 'datum/@value', 
					'',
					'customValue' AS 'datum/@name', 
					@MTMiles AS 'datum/@value' 
			   FOR XML PATH('data')
			)
		-- -----------------------------------------------------------------------------------------
					
		SET @XMLForOrderGenInfo = @PrefixXML + @LDMilesXML + @MTMilesXML
		
		-- =========================================================================================
		-- Adding Reference Information to the Order Info Tab XML section.
		-- =========================================================================================
		SET @PrefixXML =   
   				'<data id="OrderInfoRefInfoHdr">' + 
   				'<datum name="type" value="customItem" />' +
				'<datum name="sortId" value="100" />' +
				'<datum name="customLabel" value=" [ Reference Information ] " />' +
				'<datum name="customValue" value=" " />' +
				'</data>'

		SELECT  @RefInfoXML = (
			SELECT 
					'InfoRefNbr' + convert(VARCHAR(9),REF.ref_id ) AS '@id',
					'type' AS 'datum/@name',
					'customItem' AS 'datum/@value',
					'',
					'sortId' AS 'datum/@name',
					 100 + ROW_NUMBER() OVER( ORDER BY REF.ref_sequence) AS 'datum/@value',
					 '',
					'customLabel' AS 'datum/@name', 
					LBL.name AS 'datum/@value', 
					'',
					'customValue' AS 'datum/@name', 
					REF.ref_number AS 'datum/@value' 
			  FROM dbo.referencenumber AS REF
			  JOIN dbo.labelfile AS LBL 
				ON REF.ref_type = LBL.abbr 
			 WHERE REF.ref_table = 'orderheader'
			   AND REF.ref_tablekey = @OrderNumber
				   ORDER BY REF.ref_sequence
			   FOR XML PATH('data')
			   )
		
		-- -----------------------------------------------------------------------------------------

		SET @XMLForOrderRefInfo = @PrefixXML + @RefInfoXML

		-- =========================================================================================
		-- Adding Notes information to the Order Info Tab XML section.
		-- =========================================================================================
		-- Use the existing stored proc tmail_get_notes2_sp to retrieve notes attached to the 
		-- order/TripPlan.
		-- -----------------------------------------------------------------------------------------
		INSERT INTO #OrderNotes (
						Notes , 
						NotesNoWrap ,
						AttachedTo , 
						Regarding,
						RegardingAbbr,
						AttachedToKey , 
						NoteNum )
			EXEC tmail_get_notes4_sp 'orderheader',@OrderNumber,'','4000'	

		-- -----------------------------------------------------------------------------------------
		-- Place any notes found into the output XML format.
		-- -----------------------------------------------------------------------------------------
		SET @PrefixXML =   
   				'<data id="OrderInfoNotesHdr">' + 
   				'<datum name="type" value="customItem" />' +
				'<datum name="sortId" value="300" />' +
				'<datum name="customLabel" value=" [ Notes ] " />' +
				'<datum name="customValue" value=" " />' +
				'</data>'

		SELECT @OrderNotesXML = (
			SELECT	
					'Notes' + CONVERT(VARCHAR(9), #OrderNotes.NoteNum) AS '@id',
					'type' AS 'datum/@name',
					'customItem' AS 'datum/@value',
					'',
					'sortId' AS 'datum/@name',
					300 + ROW_NUMBER() OVER( ORDER BY #OrderNotes.NoteNum) AS 'datum/@value',
					'',
					'customLabel' AS 'datum/@name', 
					'Note ' + CONVERT(VARCHAR(9),ROW_NUMBER() OVER( ORDER BY #OrderNotes.NoteNum)) AS 'datum/@value', 
					'',
					'customValue' AS 'datum/@name', 
					Notes AS 'datum/@value' 
			  FROM  #OrderNotes
			   FOR  XML PATH('data')
			)

		-- -----------------------------------------------------------------------------------------

		SET @XMLForOrderNotes = @PrefixXML + ISNULL(@OrderNotesXML,'')

		-- =========================================================================================

		SET @OrderLevelInfoXML = @BegXML + @XMLForOrderGenInfo + @XMLForOrderRefInfo + @XMLForOrderNotes + @EndXML

		-- =========================================================================================
		-- Clean up
		-- -----------------------------------------------------------------------------------------
		DROP TABLE #OrderNotes 
		SET @PrefixXML = ''
		SET @RefInfoXML = ''
		SET @OrderNotesXML = ''
		SET @LDMilesXML = ''
		SET @MTMilesXML = ''
		SET @XMLForOrderRefInfo = ''
		SET @XMLForOrderNotes = ''
		SET @XMLForOrderGenInfo = ''
		SET @BegXML = ''
		SET @EndXML = ''
		-- =========================================================================================
		-- Return XML
		-- =========================================================================================

		SELECT @OrderLevelInfoXML AS 'OrderLevelInfoXML'

		-- =========================================================================================
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_MakeOrderLevelInfoTab] TO [public]
GO
